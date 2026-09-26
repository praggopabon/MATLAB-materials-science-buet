# 6. Imputing missing geochemical data and testing chemistry correlations

## Physical question

Water samples from ten very different geological settings — seawater, spreading centers, back-arc basins, volcanic and geothermal systems, an epithermal gold deposit, a river — were analyzed for temperature, pH, and the concentrations of 27 chemical species. Not every species was measured (or measurable) at every site, leaving gaps in the dataset.

Two questions follow from that: first, given that the *locations* have no natural ordering (there's no reason "Sea water" should sit next to "Spreading center" on a number line), which numerical filling strategy actually recovers the missing values best? Second, once the gaps are filled, which chemical species genuinely vary together across these very different geochemical environments — reflecting real chemistry, like "low pH goes with more dissolved metal cations" — rather than location by coincidence?

## Given data

A 28-variable × 10-location table (temperature, pH, and 26 dissolved species/ions in mm, μm, ppm, or ppb as appropriate), embedded directly in the script as a cell array with missing entries marked `NaN`. The ten locations are Sea water, Spreading center, Back-arc basin, Arc, Rotokawa, Salton Sea, Cerro Prieto, Reykjanes, Ladolam gold deposit, and Mississippi.

## Model and assumptions

**Building the numeric matrix.** The raw cell array mixes text labels with numeric and missing entries. The script separates the header row and label column, then walks every remaining cell, converting numeric-looking entries (including numbers accidentally stored as text) to `double` and leaving everything else as `NaN`, rather than assuming the spreadsheet was perfectly clean. This is a defensive parsing step, not just a format conversion — it means a stray text artifact in the source table fails safe (becomes `NaN`) instead of silently corrupting the matrix.

**The four imputation algorithms.** As specified by the assignment, the four `fillmissing` methods used are `linear`, `spline`, `makima`, and `pchip` — all one-dimensional interpolation schemes, differing in how much smoothness/overshoot they allow between known points. None of these is a "smart," multivariate imputer that uses other chemical variables to predict a missing one; each fills a single variable's gaps using *only that variable's own other location values*, treated as points along an implicit 1-to-10 index axis.

**Why the matrix gets transposed before filling.** `M` is stored as variables (rows) × locations (columns). MATLAB's `fillmissing` interpolates *down each column* by default. To fill each chemical variable's missing values *using its own values across the ten locations*, the code transposes M so that each variable becomes one column (`M'`), applies `fillmissing` down that column, then transposes back:

    M2_normal = (fillmissing(M', alg))';

Doing this without the transpose would instead interpolate each variable's neighbors *across other variables at a fixed location* — a physically meaningless operation, since concentration units and scales differ wildly between species (comparing K in mm to Pb in ppm point-for-point makes no sense). The transpose is what makes this problem statement correct, not a stylistic choice.

**The location axis has no real meaning — this is the central caveat.** Interpolation methods like spline, pchip, and makima are built on the assumption that the x-axis positions carry information (e.g., time, distance) and that neighboring points are physically related. Here, "neighboring" locations (columns 3 and 4, say) are only adjacent because of how the table happened to be ordered — Back-arc basin next to Arc is arbitrary, not geochemically meaningful. This is exactly the point behind the assignment's hint that "location might not be correlated, but chemistry might be": the imputation step is expected to be a fairly crude, order-dependent guess, while the *correlation* step afterward is the one that can find genuine chemistry-driven relationships, because correlation is computed across all locations at once and doesn't depend on their arbitrary ordering.

**Why log/exp transformation is tried separately.** Concentrations span many orders of magnitude (e.g., Mn ranges from 0.01 to 52,000 in the same column) and are strictly non-negative. Interpolating in linear space treats a jump from 10 to 100 the same as a jump from 100,010 to 100,100, and can produce a negative interpolated value, which is physically impossible for a concentration. Interpolating `log(M)` instead and exponentiating back:

    M2_log = exp(fillmissing(log(M)', alg))';

treats proportional changes symmetrically and guarantees a positive result after exponentiating. `log(0)` produces `-Inf`, so the code briefly disables the corresponding warning rather than letting the console fill with noise — the actual handling of infinite/complex values in the interpolation happens implicitly via `fillmissing` and is checked for afterward (see below), not fixed by the warning suppression itself.

**Selecting the "best" trial by NaN count.** All 8 trials (4 algorithms × normal/log) are run, and the one leaving the fewest remaining `NaN` values is kept for the correlation analysis. Note what this criterion actually measures: interpolation methods generally cannot fill values *outside* the range of a variable's known data (they can't extrapolate past the first or last known point along the fill axis), so "fewest NaNs remaining" mostly reflects which method's assumptions allowed it to bridge the largest number of gaps — not which method's filled values are most accurate. Coverage and correctness are different things, and only coverage is directly measured here.

**Guarding against complex results.** Interpolating `log(M)` can, in principle, produce complex intermediate values in edge cases (e.g., extrapolating a spline through negative log-space regions), which would become complex again after `exp`. The script checks `isreal(best_fill)` and takes the real part if not, so the correlation step downstream never silently operates on complex numbers.

**Correlation with pairwise NaN handling.** Even after imputation, any remaining `NaN`s are handled by `corr(..., 'rows', 'pairwise')`, which computes each pairwise correlation using only the locations where *both* variables in that pair have real values, rather than discarding an entire location for one missing entry elsewhere.

**Statistical significance threshold.** "More than 99.9% likely to be correlated" is implemented as p < 0.001 — the standard link between a p-value and a confidence level (100% − 0.1% = 99.9%). Pairs are collected only from the upper triangle of the correlation matrix (`j = i+1 to num_vars`) to avoid double-counting a pair as both (A,B) and (B,A), and to skip the meaningless self-correlation (i,i).

## Solution — what the script does, step by step

1. Parses the embedded table into a clean numeric matrix with `NaN` for missing values.
2. Runs all 8 fillmissing trials (4 algorithms × with/without log transform), recording the remaining `NaN` count for each.
3. Picks the trial with the fewest remaining `NaN`s as `best_fill`.
4. Computes pairwise correlation coefficients and p-values across all 28 chemical variables on `best_fill`.
5. Filters to unique variable pairs with p < 0.001, sorts them by ascending p-value (highest certainty first), and prints them.

## Key result

The printed, sorted table of variable pairs meeting the >99.9% correlation-certainty threshold, in the format:

```
"Cl (mm) - Ca (mm); r = 0.9922 , p = 1.6043e-08"
```

with one line per qualifying pair, most certain first. This table is the actual answer to "which chemistry variables move together across very different geochemical environments" — worth saving to `output/correlated_pairs.txt` alongside a note of which of the 8 trials was selected as `best_fill` and its NaN count.

## Validation and sanity checks

1. **Report the actual winning trial, not just its NaN count.** The homework explicitly asks to display which of the 8 trials had the fewest NaNs; the script computes `best_idx` internally but never prints `trial_names(best_idx)`. Add one line — `fprintf('Best trial: %s (%d NaNs remaining)\n', trial_names(best_idx), min_nans);` — both to satisfy the assignment and so the README's claims about the chosen method are independently checkable.
2. **Known physical correlation as a positive control.** The assignment itself flags that low pH should correlate with higher metallic cation concentrations. Checking that pH shows a significant *negative* correlation with at least one major cation (Fe, Mn, or similar) in the output table is a direct, physically-motivated sanity check — if that expected relationship doesn't show up at all, something upstream (imputation or the sign convention) likely needs a second look.
3. **NaN-count monotonicity across algorithms.** Since `linear` interpolation typically leaves the same boundary gaps as the other three methods (none can extrapolate past a variable's first/last known value), all 4 algorithms within the "Normal" or "Log/Exp" group should report very similar (often identical) remaining-NaN counts. If one algorithm's count is a dramatic outlier, that's worth investigating rather than accepting silently.
4. **Sample-size sensitivity of the p-values.** With only 10 locations, correlation p-values are statistically fragile — a single imputed (not measured) value going into a pair's correlation can noticeably shift both r and p. It's worth noting in the write-up how many of the reported "highly significant" pairs involve at least one imputed value versus pairs built entirely from originally-measured data.

## Known limitations and interpretation traps

- **Missing display requirement.** As noted above, the script never explicitly displays which trial won — this is a gap against the assignment's own instructions and should be fixed before final submission or repo publication.
- **The location axis is arbitrary, and imputation quietly depends on it.** Because `fillmissing`'s interpolation methods treat the location index (1 through 10) as if it carried ordering information, the *specific column order* of the ten locations in the original table can change which values get filled and what they're filled to. Reordering the columns would very likely change the imputed values — this is not a bug, but a fundamental characteristic of applying 1-D interpolation to unordered categorical data, and it's the main reason imputed values here should be read as "a plausible smooth guess," not "the true missing measurement."
- **Imputed correlations partly reflect the imputation method, not just nature.** Once a missing value has been filled by interpolating from a variable's own other values, that filled value cannot introduce new *cross-variable* information — but it can still change the apparent strength of a correlation involving that variable, since interpolation smooths out what would otherwise be a gap. Pairs whose apparent significance depends heavily on imputed (rather than measured) points deserve to be flagged rather than presented at face value.
- **"Fewest NaNs" is a coverage metric, not an accuracy metric** (explained above) — the repo README should not claim the winning trial produced the *most correct* imputed values, only that it filled the most gaps.
- **Units are heterogeneous across variables** (mm, μm, ppm, ppb) and the correlation is computed on raw concentrations rather than standardized/z-scored values — Pearson correlation is scale-invariant, so this doesn't bias the correlation coefficients themselves, but it's worth noting explicitly since the variables are not on comparable numeric scales.
- **Instructor-provided data.** This dataset originates from course material; confirm redistribution is permitted before committing the embedded table to a public repo, or keep the script and note the expected format instead.

## Files

- `main.m` — parses the embedded table, runs all 8 imputation trials, selects the best, computes correlations, and prints significant pairs.
- `input/` — none required; data is embedded directly in the script.
- `output/` — `correlated_pairs.txt` (the printed table) and, ideally, a short log noting the winning trial and its NaN count.
