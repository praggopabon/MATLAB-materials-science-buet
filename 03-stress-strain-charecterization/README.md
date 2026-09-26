# 3. Stress-strain characterization of BCC W, FCC Al, and FCC Pt from atomistic simulation data

## Physical question

Three metals with different crystal structures — BCC tungsten, FCC aluminum, FCC platinum — were strained in molecular dynamics simulations at different strain rates and temperatures. How do their stress-strain responses compare, where do yielding and failure occur on each curve, and what does the raw simulation output need to become before those questions can even be plotted?

This problem is less about the plotting itself and more about turning raw, differently-shaped simulation output into a consistent, labeled, comparable set of curves.

## Given data

Three CSV files, one per material, each containing per-timestep atomistic simulation output: engineering strain, true stress (GPa), and box dimensions Lx, Ly, Lz (Å) evolving as the simulation cell deforms.

- BCC W: strain rate 0.005 ps⁻¹, 1108.5 K, loaded along [110]
- FCC Al: strain rate 0.002 ps⁻¹, 746.8 K, loaded along [110]
- FCC Pt: strain rate 0.02 ps⁻¹, 1837.35 K, loaded along [111]

The three materials are deliberately not directly comparable in a materials-science sense — different crystal structures, different loading directions, different rates and temperatures — so the combined plot is a visual overlay, not a controlled comparison.

## Model and assumptions

**Strain conversion.** The raw column is engineering strain, converted to true strain via

    true_strain = log(1 + engineering_strain)

This assumes the reported engineering strain is a decimal fraction, not a percentage — if the source data were in percent, this formula would be wrong by two orders of magnitude. That should be confirmed against the CSV header before trusting the plotted x-axis.

**Load from stress and geometry.** Since the raw data has no direct "load" column, it's reconstructed from true stress and the deforming cross-section:

    load = stress .* Ly .* Lz .* 1e-11

The `1e-11` factor is a unit reconciliation, not an arbitrary fudge: stress is in GPa (10⁹ Pa) and Ly, Lz are in Å (10⁻¹⁰ m each), so

    Pa · m² = (GPa · 1e9) × (Å² · 1e-20) = 1e-11 × (GPa · Å²)

confirming the exponent. This treats Ly and Lz as the load-bearing cross-section and Lx as the loading (transverse) direction — correct only if the simulation cell was actually set up that way, which should be checked against each file's loading-direction metadata rather than assumed uniform across all three materials.

**Displacement from box length.** Displacement is computed as the change in Lx relative to its first recorded value, i.e. absolute elongation of the simulation cell along the loading axis:

    displacement = Lx - Lx(1)

**Data cleaning.** Columns MATLAB auto-names `Var1`, `Var2`, etc. (from missing headers in the original CSV) are dropped programmatically by matching the `Var` prefix, rather than by hardcoding column indices — this makes the cleaning step robust to the exact original column layout.

**Yield, UTS, and failure points.** These are read off the plotted curve by eye and hardcoded as literal coordinates for each material (e.g. `(0.0975803, 34.3216)` for W's yield point). This is the single biggest methodological weak point in the script — worth being upfront about in the repo rather than presenting it as if it were computed. See Limitations below.

## Solution — what the script does, step by step

1. Reads the three CSVs and extracts strain (col. 1) and true stress (col. 2) as numeric arrays.
2. Converts engineering strain to true strain for each material.
3. Plots each material's true stress–true strain curve in its own subplot, manually annotating yield point, UTS, and (where visible) failure point.
4. Plots all three curves together in a fourth subplot for visual comparison.
5. Cleans each data table by removing headerless (`Var*`) columns.
6. Computes and appends displacement and load columns to each table.
7. Writes the cleaned, augmented tables out as new CSVs.

## Key result figure

`output/Stress_Strain_Plots.png` — a 2×2 figure: BCC W, FCC Al, FCC Pt individually (each annotated with yield/UTS/failure where identifiable), and all three overlaid with a legend in the fourth panel.

## Validation and sanity checks

1. **Unit dimensional check on load.** Verified above: GPa·Å² → N requires exactly the `1e-11` factor used in the code. This is the kind of check that should live in a comment next to the calculation, not just in a README — it is currently only in the README.
2. **Displacement sign and magnitude.** `displacement = Lx - Lx(1)` should be positive throughout a tensile pull and roughly track the true-strain curve's shape; if displacement ever goes negative before failure, that's a sign the loading axis assumption is wrong for that file.
3. **Column-cleaning check.** After running `startsWith(col, 'Var')`, print `data.Properties.VariableNames` for each table and confirm no genuinely-named column was accidentally dropped and no `Var*` column survived.
4. **Physical plausibility of yield stresses.** W yielding near 34 GPa true stress is very high for tungsten (bulk yield strength is on the order of ~1 GPa), which is expected here since this is a defect-free nanoscale MD simulation at high strain rate — not bulk polycrystalline tungsten. Worth stating this explicitly in the repo so a reader doesn't mistake simulated ideal-strength values for engineering material properties.

## Known limitations and interpretation traps — please read before reusing this

- **Bug: mislabeled subplot title.** The third subplot (FCC Pt) is titled `'FCC Aluminum'` in the original script — copy-paste leftover from the Al subplot above it. This needs to be fixed to `'FCC Platinum'` before this goes in the repo; as written it silently mislabels a whole panel.
- **Hardcoded, machine-specific absolute paths.** The script reads and writes using `C:\Users\Praggo\Desktop\...`. This will not run on any other machine, including a fresh clone of the repo, or even the same machine after a folder move. For the repo version, replace every hardcoded path with something built from `fileparts(mfilename('fullpath'))`, so the script locates its own folder and reads/writes `input/` and `output/` relative to that, regardless of who runs it or where the repo lives.
- **Yield/UTS/failure points are manually read, not computed.** The coordinates are literal numbers typed in after visually inspecting the plot — meaning if the input CSVs change even slightly, these annotations become wrong silently, with no error thrown. A more robust version would detect yield via a 0.2% offset rule or a deviation-from-linearity threshold, and UTS as the stress maximum via `max()` — both straightforward to automate and worth doing before calling this "portfolio-ready."
- **No failure point found for FCC Al.** The script's comment notes this rather than fabricating one — correct instinct, but the repo README should say explicitly why (e.g., simulation ended before fracture, or fracture wasn't visually distinguishable) rather than leaving a silent gap in the figure.
- **True-strain formula assumes engineering strain is already a fraction.** Not verified against the source file's units in the script itself — should be checked once and noted.
- **Data licensing.** These CSVs are third-party or instructor-provided atomistic simulation output; confirm you're allowed to redistribute them before committing them to `input/`. If not, keep the script and note the expected file format/columns instead.

## Files

- `main.m` — reads, cleans, plots, annotates, and re-exports the three materials' data.
- `input/` — the three material CSVs (subject to the licensing note above).
- `output/` — `Stress_Strain_Plots.png`, `new_W_data.csv`, `new_Al_data.csv`, `new_Pt_data.csv`.
