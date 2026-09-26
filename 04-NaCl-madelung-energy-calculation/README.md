# 4. Madelung energy of an infinite 3D NaCl crystal via symmetry-reduced lattice summation

## Physical question

The electrostatic (Madelung) energy of an ionic crystal comes from summing the Coulomb interaction of one reference ion with every other ion in an infinite lattice — a conditionally convergent alternating sum, since each ion attracts oppositely charged neighbors and repels like-charged ones at increasing distance. How large does the summation region have to be before this sum has converged to a trustworthy number, and how does the cost of getting more digits of accuracy scale?

This problem answers that by computing the per-mole electrostatic energy of NaCl, characterizing the convergence rate, and extrapolating the computational cost of higher precision.

## Given data

- Lattice parameter: a = 5.6413 × 10⁻¹⁰ m (the conventional cubic cell edge of NaCl).
- A precomputed physical scaling constant, C_scale = 2.46285 × 10⁵ J/mol, representing the prefactor N_A·Z₁·Z₂·e²/(4πε₀·d), where d is the nearest-neighbor ion spacing.
- Summation carried out to N = 1000 concentric cubic shells.

## Model and assumptions

**Lattice structure and sign convention.** NaCl's rock-salt structure places Na⁺ and Cl⁻ ions on a single combined simple-cubic lattice, alternating by parity: if the reference ion sits at the origin, the ion at integer grid position (i, j, k) — measured in units of the nearest-neighbor spacing — is the same species as the reference when i + j + k is even, and the opposite species when i + j + k is odd. This is exactly why the code uses

    sign = (-1)^(i + j + k)

as the interaction sign: unlike species attract (negative energy contribution), like species repel (positive contribution). This matches the physical assumption that the underlying grid spacing corresponds to the nearest-neighbor Na–Cl distance, not the full conventional cell edge — worth double-checking against how C_scale itself was derived, since getting this factor wrong shifts every distance, and hence the whole sum, by an incorrect scale.

**Concentric cubic shells, not spherical shells.** The outer loop index `i` is a Chebyshev ("cube") shell: on iteration i, the code sums only the new lattice points added when growing the cube from half-width i−1 to half-width i, i.e. points where max(|x|,|y|,|z|) = i. This is precisely what the assignment calls "how large the summation cube has to be" — the natural unit of cutoff for a cubic lattice sum, matching the geometry of the problem rather than an arbitrary spherical cutoff.

**Reducing to 1/48th of space by symmetry.** A cube has full octahedral (Oₕ) point-group symmetry, with 48 symmetry operations (rotations and reflections) mapping the cube onto itself. Instead of visiting every lattice point in a shell, the code sums only over the irreducible wedge 0 ≤ k ≤ j ≤ i and multiplies each term by how many of the 48 symmetry images of that point are physically distinct:

- **Interior wedge points** (strictly inside the wedge, not on any of its bounding planes k=0, j=k, or j=i) map to 48 distinct lattice points each.
- **Points on exactly one bounding plane** (a face of the wedge, e.g. j = k) are shared between two adjacent wedges, so each maps to 24 distinct points.
- **Points on the outer shell face** (j = i, the newly-added shell surface) are similarly halved to 24.
- **Vertices where two or three symmetry planes intersect** (the point (i,0,0), (i,i,0), (i,i,i)) are shared by even more wedges, and get the smallest weights — 6, 12, and 8 respectively — matching how many of the 48 total operations actually leave that specific point fixed or map it onto a genuinely distinct image.

This weighting scheme is the computational heart of the script: it turns an O(N³) enumeration over a full cubic volume into an O(N³/48) enumeration over one wedge, roughly a 48-fold speedup, which is exactly why this script's reported step counts for a given accuracy (66, 660, 6651, 66980 for 2–5 significant figures) are far smaller than a brute-force, unreduced version's would be.

**Accelerating convergence via "probable sum."** Because the series is alternating, its partial sums oscillate around the true value rather than approaching it monotonically. Averaging two consecutive partial sums cancels most of the leading oscillation, giving a much faster-converging estimate — this is the "probable sum" `E_prob`, and its final value is taken as the best estimate of the true converged energy, `E_true`.

**Bounding the true value from above and below.** Because the odd-shell partial sums sit consistently above `E_true` and the even-shell partial sums sit consistently below it (or vice versa, depending on sign convention), fitting a power law to each — after discarding the first ~20 shells to avoid the initial transient — gives an upper-bound and lower-bound envelope that both converge to `E_true` as x → ∞.

**Extrapolating cost for higher precision.** The absolute error |E_cum − E_true| is fit to a power law in log-log space, `error ≈ exp(b)·x^m`. Inverting this fit gives the number of shells needed to reach a target relative error (defined as half a unit in the last significant place, the standard definition of "k significant figures"). Because the triple-nested-loop cost scales as O(N³), the wall-clock time is separately fit as `time ≈ c·x³`, and combining the two fits gives the time estimate printed for 3, 4, and 5 significant figures — these are extrapolations well beyond the N = 1000 actually computed, not measurements.

## Key result figures

`output/fig_convergence.png` — two-panel figure:

- **Left panel:** cumulative energy sum vs. shell count (log x-axis), with the fitted upper and lower power-law bounds overlaid, plus the absolute error and its power-law fit on a secondary log axis. Fit equations and the target values (E_true) appear directly in the legend, as required.
- **Right panel:** the "probable sum" (zoomed near E_true) showing rapid stabilization, plus cumulative computation time with its cubic fit overlaid on a secondary log axis.

Printed accuracy/cost table (from the script's own output):

| Significant figures | Shells needed | Estimated time |
|---|---|---|
| 2 | ~66 | ~0.01 s |
| 3 | ~660 | ~6.57 s |
| 4 | ~6,651 | ~6,707 s |
| 5 | ~66,980 | ~6.85 × 10⁶ s |

## Validation and sanity checks

1. **Cross-check the symmetry weights against brute force for small shells.** For a small cutoff (e.g. i up to 3–5), enumerate every lattice point in the full cube directly with `ndgrid`, apply the sign and 1/distance formula without any weighting, and sum. This unreduced sum should exactly match the weighted 1/48th-wedge calculation for the same shells. This is the most important check to run before trusting the accelerated large-N result — a small error in any one of the six weight values (48, 24, 24, 6, 12, 8) would silently bias every subsequent shell.

2. **Recovered Madelung constant vs. literature.** Dividing the converged energy magnitude by C_scale should recover a dimensionless constant comparable to the accepted Madelung constant for the rock-salt structure, M ≈ 1.747565. If the recovered value differs substantially, that points to either a unit mismatch between C_scale and the lattice spacing used in the sum, or an error in the symmetry weights.

3. **Goodness-of-fit of the power-law fits.** All three fits (upper bound, lower bound, absolute error) should show R² close to 1 over the fitted range (shells 20–1000) — this is a direct, checkable number that should be displayed on the plot, not just assumed.

4. **Self-consistency of the extrapolation.** The fitted cubic time law should closely match the *actually measured* time at N = 1000 (not just the extrapolated points) — if it doesn't, the O(N³) assumption or the fit itself needs revisiting before trusting the fitted times for 4–5 significant figures.

5. **Sign and magnitude plausibility.** The final energy should be negative (net attractive, since the alternating near/far ion shells sum to a stable ionic crystal) and of the right order of magnitude for an alkali halide lattice energy (hundreds of kJ/mol), not, say, off by a factor of 10³ from a unit error.

## Known limitations and interpretation traps

- **Extrapolated times, not measured times.** The 4- and 5-significant-figure step counts (6,651 and 66,980 shells) are extrapolations from a power-law fit calibrated on data only up to 1,000 shells — they should be reported as estimates, not verified measurements, and the README/figure should say so explicitly.
- **The nearest-neighbor spacing assumption is load-bearing.** The entire sign convention and symmetry structure depend on the grid spacing in the sum being the nearest-neighbor Na–Cl distance (a/2), not the full conventional cell edge a. If C_scale was derived assuming a different spacing than the code's implicit grid, the whole result is off by a fixed, hard-to-notice factor — this is the single most important thing to re-verify by hand before publishing the result.
- **Conditional convergence.** This is a conditionally convergent series — its value in principle depends on the *order and shape* of summation (cubic shells here). A different cutoff shape (spherical, for instance) can converge to a different apparent limit for a finite cutoff, though all should agree in the infinite limit. The "uncertainty of the approximation" the assignment asks for is fundamentally about this shape-dependence, not just floating-point truncation.
- **O(N³) cost assumption may break down at very large N** due to memory allocation overhead, or improve due to caching effects — the cubic time fit is only as good as its calibration range, and pushing it to N in the tens of thousands (as the 5-sig-fig extrapolation implies) is a significant extrapolation outside the tested range.

## Files

- `main.m` — computes the symmetry-reduced lattice sum, fits convergence and timing trends, extrapolates accuracy/cost, and generates the convergence figure.
- `input/` — none required; all parameters (a, C_scale, N) are set in-script.
- `output/` — `fig_convergence.png` and the printed accuracy/cost table (captured as a text file or left as in-code comments, per the assignment's "text output as comments" requirement).
