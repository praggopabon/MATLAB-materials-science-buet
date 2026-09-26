# 5. Full mechanical characterization and optimal-property design for AA2198 alloy

## Physical question

An Al-Li alloy (AA2198) was tested in four heat-treatment conditions — As-Quenched, Under-aged, Peak-aged, Over-Aged — each producing a different precipitate microstructure and therefore a different stress-strain response. Three questions follow from the raw curves:

1. What are the standard mechanical properties (yield strength, UTS, toughness, strain-hardening behavior) of each condition, and how do they compare?
2. Do any two of these properties trade off against each other in a simple, predictable (power-law) way?
3. If toughness could be tuned continuously between these four discrete heat-treatment states, what heat-treatment "setting" — expressed as either the resulting yield strength or the resulting UTS — would maximize it, and what would that hypothetical optimal material's full stress-strain curve look like?

## Given data

True stress–true strain data for four AA2198 heat-treatment conditions (As Quenched, Under-aged, Over-Aged, Peak-aged), each as paired strain(%)/stress(MPa) arrays digitized from the source curves, embedded directly in the script.

## Model and assumptions

**Data cleaning before any calculation.** `prepare_data` converts strain from percent to a fraction, sorts points by ascending strain (digitized data isn't guaranteed to arrive in order), and collapses duplicate strain values by keeping the maximum stress at each unique strain (`accumarray(..., @max)`). This matters because both `polyfit` and `trapz` assume monotonically ordered, non-repeating x-values — skipping this step would silently corrupt every downstream fit and integral.

**Young's modulus via adaptive elastic-region fitting.** Rather than fitting a fixed number of initial points, `youngs_modulus` starts from all points below a strain cutoff (0.4%) and searches over every possible sub-range (3 points up to all of them), keeping the linear fit with the best R² among fits with a positive slope. This is a reasonable defense against digitization noise near zero strain (where a fixed 2-point secant would be unreliable), but it also means the reported "elastic modulus" is *the best-fitting straight segment within the truncated region*, not a fit anchored to a fixed, reproducible strain window — worth flagging, since re-running with a different cutoff could shift E somewhat.

**Yield strength via 0.2% offset, found by sign-change detection.** The standard method: draw a line of slope E through (0.002, 0), and find where it crosses the actual stress-strain curve. The code implements this by computing `diff = stress − E·(strain − 0.002)` and finding where consecutive `diff` values change sign, then linearly interpolating between those two bracketing points for the exact crossing coordinates. A closest-point fallback exists if no clean sign change is found (e.g., due to noisy or sparse data), which is a reasonable degradation rather than a silent NaN.

**UTS by converting to engineering stress internally.** Ultimate tensile strength is properly defined as the *maximum engineering stress*, not the maximum true stress (true stress keeps rising until necking-driven fracture even after the engineering curve has peaked). The code converts using $\sigma_{eng} = \sigma_{true} \cdot e^{-\varepsilon_{true}}$ — the standard relation under the assumption of constant volume — finds the index of maximum engineering stress, and reports the *true* stress and strain at that same index. This is the correct approach; a common student error here is to instead take the peak of the true stress curve directly, which does not correspond to physical necking onset.

**Hollomon fit computed twice, over two different domains.** $\sigma_T = K\varepsilon_T^n$ is fit by linearizing in log-log space (`polyfit(log(strain), log(stress), 1)`). The script does this fit twice: once (`K_full`, `n_full`) over the whole plastic region from the second data point to UTS, and again (`K_yield`, `n_yield`) starting specifically from the 0.2%-offset yield point to UTS. Reporting both is useful because the "true" strain-hardening exponent is sensitive to exactly where the elastic-to-plastic transition is assumed to start; the difference between `n_full` and `n_yield` is itself informative about how much the early plastic region deviates from a pure power law.

**Toughness by direct trapezoidal integration to the last recorded point.** `Tough = trapz(eps, sig)` integrates the *entire* recorded true stress-strain curve. As the code comment notes, this only equals the standard definition of toughness (energy absorbed up to fracture) under the assignment's stated assumption that each material fails shortly after UTS — since each dataset's last recorded point is treated as an implicit fracture point, no separate necking/fracture-region correction is applied.

**Best log-log property pair chosen by highest R².** All three combinations (YS–UTS, YS–Toughness, UTS–Toughness) are fit as power laws $y = ax^b$ in log-log space, and the pair with the highest R² is reported as showing the strongest power-law relationship — the comment in the code states this reasoning explicitly, which is the correct standard for "best fits a straight-line model on log-log axes."

**Toughness-vs-YS interpolation and optimization.** With only four discrete (YS, Toughness) data points, `find_optimal_x_for_max_toughness` builds a spline interpolant through the sorted points and uses `fminbnd` (bounded scalar minimization of the negated function) to find the interior YS value that maximizes the interpolated toughness. This searches only *within* the range spanned by the four heat treatments — it cannot report an optimum outside the tested YS range, by construction. See Limitations for what this optimum actually represents.

**Predicting other properties at the optimal YS via independent linear fits.** Once the optimal YS is found, every other property (UTS, elongation, E, K, n) is predicted at that YS using its own separate linear regression against YS across the four conditions — five independent 2-parameter fits, each with only 4 data points. This is explicitly a first-order approximation: with 4 points and 2 fit parameters, each fit has only 2 residual degrees of freedom, so the reported R² values should be read as descriptive, not as strong statistical evidence.

**Constructing the synthetic "ideal" stress-strain curve.** `build_stress_strain_curve` builds a two-segment curve: a linear elastic segment from 0 to the predicted yield strain (YS/E), followed by a Hollomon power-law segment from yield to the predicted elongation. Because the linear-fit-predicted K and n are independent of each other and of YS, the raw Hollomon segment $K\varepsilon^n$ generally does *not* pass through the predicted yield stress at the transition point — the code corrects this by rigidly shifting the entire plastic segment up or down by a constant offset so it meets the elastic line exactly at yield (`shift = YS - sig_pl_hollomon(1)`). This guarantees continuity of *stress* at the transition (C0 continuity) but not continuity of *slope* — there is generally a kink in the synthetic curve at the elastic-plastic transition, which is a direct and visible consequence of fitting K, n, and YS as independent linear functions of the optimization variable rather than as a jointly consistent model.

**The whole process is repeated with UTS as the independent variable.** Exactly the same optimization → linear-fit-prediction → curve-construction pipeline is run a second time using UTS (rather than YS) as the x-axis for both the toughness interpolation and the secondary property fits, producing a second, independently-derived "ideal" curve.

## Solution — what the script does, step by step

1. Cleans and sorts each condition's raw digitized data.
2. Computes E, YS (0.2% offset), UTS (via engineering-stress peak), full-range and post-yield Hollomon K/n, toughness (trapezoidal integral), and elongation for all four conditions; prints a formatted table.
3. Plots the four raw true stress-strain curves for a visual data-integrity check.
4. **Figure 1:** five bar-chart subplots (YS, true stress at UTS, toughness, K, n) across the four conditions, each bar labeled with its value.
5. **Figure 2:** three log-log subplots (YS–UTS, YS–Toughness, UTS–Toughness), each with a fitted power law, its equation, and R² shown on the plot; identifies and reports the best-fitting pair.
6. Interpolates Toughness vs. YS through the four points, optimizes to find the YS maximizing toughness, predicts UTS/elongation/E/K/n at that YS via independent linear fits, and constructs a synthetic "ideal" stress-strain curve (Curve A).
7. Repeats step 6 entirely using UTS as the independent variable instead of YS, producing Curve B.
8. **Figure 3:** plots Curve A and Curve B together, annotated with each curve's maximum-toughness value.
9. Prints a final summary block with the best log-log pair, both optimal values, and both curves' toughness.

## Key result figures

- `output/fig0_raw_curves.png` — the four raw experimental true stress-strain curves overlaid, for a visual sanity check against the source data before any property extraction.
- `output/fig1_bar_properties.png` — five-subplot bar chart of YS, true stress at UTS, toughness, K, and n across the four heat treatments.
- `output/fig2_loglog_pairs.png` — three log-log subplots (YS–UTS, YS–Toughness, UTS–Toughness) with fitted power laws and R² values, identifying the strongest straight-line relationship.
- `output/fig3_ideal_curves.png` — the two synthetic "maximum toughness" stress-strain curves (one derived via optimal YS, one via optimal UTS), each annotated with its toughness value.

## Validation and sanity checks

1. **Elastic modulus plausibility.** All four conditions should return an E broadly consistent with aluminum alloys (~65–75 GPa); a value far outside that range for any condition signals a bad elastic-region fit, likely from too aggressive or too narrow a strain cutoff for that particular dataset's early-point spacing.
2. **UTS-from-engineering-peak vs. naive true-stress-peak.** Explicitly compare `sigmaT_UTS` (from the correct engineering-stress-peak method) against simply taking `max(stress)` for each condition — for any condition where the true stress is still rising at the last recorded point (no visible softening), these two will differ, and that difference is worth reporting since it demonstrates the method is doing real work, not just returning the trivial maximum.
3. **Ranking consistency across conditions.** Peak-aged should show the highest strength (YS, UTS) and generally the lowest ductility/elongation, while As-Quenched should show the opposite — this ordering reflects standard Al-Li aging behavior and is a domain-knowledge check independent of the code itself.
4. **Elastic-plastic transition kink in Figures 3.** Explicitly note (or better, quantify) the slope discontinuity at the elastic-to-plastic transition in the synthetic curves — plotting the local slope near that point, or simply stating the two slopes numerically, turns the limitation noted above into a displayed, checkable fact rather than a hidden approximation.
5. **Optimum sits strictly inside the tested range.** Report both YS_opt and UTS_opt alongside the min/max YS and UTS actually observed across the four conditions, to confirm the reported optima are genuine interior maxima of the interpolant and not artifacts sitting at (or just inside) the boundary.
6. **R² honesty for the 4-point linear fits.** Since each secondary-property fit (UTS, elongation, E, K, n vs. YS or UTS) has only 4 points and 2 fit parameters, report R² for all five fits used in each optimal-curve construction, and flag any fit with a low R² as a weak basis for its corresponding prediction — a low-R² input directly weakens confidence in the resulting synthetic curve.

## Known limitations and interpretation traps

- **The "optimal YS" belongs to the interpolant, not the alloy.** With only four data points, a spline (or any smooth interpolant) through them will always have *some* interior maximum somewhere between the points — this location depends on the interpolation method's mathematical behavior between data points at least as much as on the material's actual behavior. Trying `pchip` or a low-order polynomial instead of `spline` and checking whether the reported optimal YS moves substantially is the direct way to demonstrate this sensitivity, and is worth doing and reporting rather than presenting one interpolant's answer as definitive.
- **Independent per-property linear fits ignore correlations between properties.** UTS, elongation, E, K, and n are each fit separately as functions of YS (or UTS), rather than as a jointly consistent model — this is why the synthetic curve needs an artificial shift to reconnect its elastic and plastic segments. A more physically consistent approach would fit K and n jointly (e.g., recognizing that K and YS are related through the yield condition $\sigma_y = K\varepsilon_y^n$) rather than as independent linear functions of the optimization variable.
- **4-point regressions are fragile.** Every "predicted at optimal YS/UTS" number rests on a 2-parameter linear fit to only 4 points. Small changes in any one of the four measured conditions (e.g., re-digitizing a curve slightly differently) could visibly shift the predicted "ideal" properties — this should be stated plainly rather than presenting Figure 3 as if it were a robust, low-uncertainty prediction.
- **Toughness assumes failure shortly after UTS**, as explicitly noted in the code's own comment — for any condition where substantial post-UTS strain was actually recorded before fracture, integrating only to the last recorded point may understate true fracture toughness, or, if that last point is well past UTS, could actually be reasonably accurate. This assumption should be checked against how far past UTS each dataset's last recorded strain actually falls.
- **Digitized data, not raw instrument output.** These strain/stress arrays already exist as embedded numeric literals in the script rather than being read from an external file — confirm with the instructor whether this digitized data may be redistributed before including it verbatim in a public repo, or note its provenance (source figure/paper) instead.

## Files

- `main.m` — the full pipeline: property extraction, Figures 1–3, optimization, and synthetic curve construction, plus all helper functions (`prepare_data`, `youngs_modulus`, `yield_strength_02`, `ultimate_tensile`, `hollomon_fit`, `fit_power_law`, `find_optimal_x_for_max_toughness`, `predict_property`, `build_stress_strain_curve`).
- `input/` — none required; data is embedded directly in the script.
- `output/` — `fig0_raw_curves.png`, `fig1_bar_properties.png`, `fig2_loglog_pairs.png`, `fig3_ideal_curves.png`, and the printed properties/fits/summary tables (as a captured text log).
