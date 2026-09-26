# 8. Steady-state temperature field in a laser-heated cylindrical rod (finite difference solution)

## Physical question

A cylindrical rod is heated on one end by a laser focused onto a spot smaller than the rod's face, while the far end is clamped at ambient temperature and the lateral surface loses heat by convection. Where does the front face lose more heat — through the laser-heated spot or through the surrounding convective ring — and how does the resulting steady-state temperature field depend on the rod's aspect ratio, the laser spot size, the strength of convective cooling, and the laser power itself?

This problem builds a general-purpose 2D finite-difference solver for that geometry and boundary conditions, then uses it to answer those questions by systematically sweeping each of the four governing dimensionless numbers in turn.

## Given data

Physical setup: rod radius $R_{rod}$, length $L_{rod}$; laser of total optical power $P_{pow}$ focused onto a spot of radius $s_{spot} \le R_{rod}$ on the $z=0$ face; the $z=L_{rod}$ face held at ambient temperature $T_{amb}$; convective cooling (coefficient $h_{conv}$) on the outer curved surface and on the un-lit portion of the front face.

Nondimensionalized with $r' = r/R_{rod}$, $z' = z/L_{rod}$, $T' = T/T_{amb}$, the problem reduces to four dimensionless groups:

- **shapeRatio** $\alpha = R_{rod}/L_{rod}$ — geometric aspect ratio
- **spotFrac** $\beta = s_{spot}/R_{rod}$ — fraction of the face lit by the laser
- **biotNum** $Bi = h_{conv}R_{rod}/k_{cond}$ — ratio of convective to conductive heat transport
- **powNum** $\Phi = P_{pow}L_{rod}/(k_{cond}T_{amb}\pi R_{rod}^2)$ — dimensionless laser power

## Model and assumptions

**Governing PDE.** The dimensionless, axisymmetric steady-state heat equation:

$$\frac{1}{r'}\frac{\partial}{\partial r'}\left(r'\frac{\partial T'}{\partial r'}\right) + \alpha^2\frac{\partial^2 T'}{\partial z'^2} = 0, \qquad 0 \le r', z' \le 1$$

with five boundary conditions: a Neumann laser-flux condition and a Robin convective condition split across the two regions of the $z'=0$ face (with a genuine discontinuity in $\partial T'/\partial z'$ right at $r' = \beta$), a Dirichlet condition at $z'=1$, a symmetry (zero-flux) condition at $r'=0$, and a Robin convective condition at $r'=1$.

**Why finite differences rather than `pdepe`.** The mixed Neumann/Robin condition that switches discontinuously at $r'=\beta$ on the same boundary edge is awkward to express in `pdepe`'s boundary-condition function interface, which expects a single boundary condition per edge. Building the sparse linear system directly gives full control over exactly where that discontinuity is enforced, at the cost of writing the discretization by hand.

**Handling the coordinate singularity at $r'=0$.** The term $\frac{1}{r'}\frac{\partial}{\partial r'}\left(r'\frac{\partial T'}{\partial r'}\right)$ is a $0/0$ indeterminate form at $r'=0$. Applying L'Hôpital's rule (using $\partial T'/\partial r' = 0$ at the axis, from symmetry) reduces this term to $2\,\partial^2 T'/\partial r'^2$ at $r'=0$. The code implements this using a ghost node ($T_{0,j} = T_{2,j}$, enforcing the symmetry condition directly), giving the discretized axis equation

$$\frac{4(T_{2,j}-T_{1,j})}{\Delta r'^2} + \alpha^2\frac{T_{1,j+1}-2T_{1,j}+T_{1,j-1}}{\Delta z'^2} = 0$$

This is the trickiest part of the discretization to get right, and is exactly the kind of step that benefits from an independent check (see Validation).

**Discretization scheme, by region.**
- **Interior nodes:** standard second-order central differences in both $r'$ and $z'$, including the first-derivative term $\frac{1}{r'}\partial T'/\partial r'$ via a central difference (giving the asymmetric $\pm\frac{1}{2r'\Delta r'}$ coefficients on the neighboring radial nodes).
- **$z'=1$ (Dirichlet):** trivial — the row is just $T_{i,N_{ax}} = 1$.
- **$z'=0$, $r' \le \beta$ (BC1, laser flux):** one-sided (forward) difference approximating $\partial T'/\partial z' = -\Phi/\beta^2$.
- **$z'=0$, $r' > \beta$ (BC2, convective front face):** one-sided difference approximating a Robin condition, $\partial T'/\partial z' = (Bi/\alpha)(T'-1)$.
- **$r'=1$ (BC5, lateral convection):** one-sided (backward) difference approximating $\partial T'/\partial r' = -Bi(T'-1)$.

Each boundary row assembles a small number of nonzero entries directly into the sparse matrix $A$ and right-hand side $b$, rather than modifying a dense system after the fact — appropriate given the grid here has $121 \times 121 \approx 14{,}600$ unknowns, where a dense solve would be needlessly slow and memory-heavy.

**Numerical safeguard.** `spotFrac` is clamped away from exactly zero (`max(params.spotFrac, 1e-12)`) before being used in a $1/\beta^2$ term in BC1, since a literal $\beta=0$ (an infinitesimally small laser spot) would make that boundary condition blow up — a reasonable defensive choice, though $\beta=0$ is also not physically meaningful (a spot with zero radius delivers zero total flux times infinite intensity).

**Study design: baseline plus four one-at-a-time sweeps.** Following the assignment's explicit request, all four dimensionless numbers are first set to 1 and solved as a baseline (Case 0). Then each of the four numbers is swept independently across 5 levels (spanning roughly one to two orders of magnitude on either side of 1, depending on the parameter), with the other three held fixed at 1 — a standard one-factor-at-a-time sensitivity design that isolates each parameter's individual effect on the temperature field, at the cost of not capturing any interaction effects between parameters (see Limitations).

**Sweep ranges chosen to be physically informative, not just arbitrary.** `biotNum` is swept from 0.05 to 50 specifically because this spans the conduction-dominated ($Bi \ll 1$, uniform internal temperature) to convection-dominated ($Bi \gg 1$, sharp surface gradients) regimes recognized in heat-transfer theory. `spotFrac` is swept down to 0.1, deliberately including small values where the flux discontinuity at $r'=\beta$ is most visually and physically pronounced.

## Solution — what the script does, step by step

1. `solveRodTemperature` assembles the sparse matrix and vector encoding the PDE and all five boundary conditions for a given parameter set, then solves the linear system directly (`Amat \ bvec`) and reshapes the flat solution into a 2D grid.
2. Case 0 solves the all-parameters-equal-to-1 baseline as a single reference case.
3. Cases 1–4 each call `runSweepCase`, which solves the field at 5 levels of one parameter (holding the others at 1), plots each as a filled contour subplot (with the laser-spot boundary marked when relevant), and computes summary statistics (max, mean, standard deviation of the temperature rise $T'-1$) at each level via `computeRiseStats`.
4. Each sweep's sixth subplot plots those three summary statistics against the swept parameter on a semilog-x axis, since the sweeps span more than one order of magnitude — turning four grids of contour plots into an at-a-glance trend for how the parameter drives overall heating.

## Key result figures

- `output/fig0_baseline.png` — the temperature field for the case where every dimensionless number equals 1, established explicitly before any sweeps as the reference point every other figure is compared against.
- `output/fig1_shapeRatio_sweep.png` — five contour maps across shapeRatio = 0.25 to 4, plus the max/avg/std trend panel.
- `output/fig2_spotFrac_sweep.png` — five contour maps across spotFrac = 1 down to 0.1, plus trend panel; this is the case where the flux discontinuity at the spot edge is most visible.
- `output/fig3_biotNum_sweep.png` — five contour maps across Bi = 0.05 to 50 (conduction- to convection-dominated), plus trend panel.
- `output/fig4_powNum_sweep.png` — five contour maps across Φ = 0.2 to 100, plus trend panel.

## Validation and sanity checks

1. **Independent check of the axis (r'=0) discretization.** This is the single most error-prone part of the code. Verify it by comparing the FDM solution's temperature profile along the axis ($r'=0$) against a solution from MATLAB's `pdepe` for a *simplified* version of the problem where the boundary condition doesn't switch at $r'=\beta$ (e.g., spotFrac = 1, so the whole face is laser-heated and BC1 applies everywhere) — `pdepe` handles the coordinate singularity internally via its own m-parameter, giving an independent cross-check on whether the ghost-node L'Hôpital treatment here was implemented correctly.
2. **Energy balance.** In steady state, the total heat entering through the laser spot must equal the total heat leaving through the far end (conduction) plus all convective losses (front face outside the spot, and the lateral surface). Numerically integrating the flux across each of these boundaries from the solved temperature field and checking they sum to (approximately) zero is a strong, physically meaningful validation that doesn't depend on comparing against any other solver.
3. **Monotonicity checks on the sweep trends.** Increasing `powNum` (more laser power in) should monotonically increase the max/avg temperature rise; increasing `biotNum` (stronger cooling) should monotonically decrease it. These are simple, checkable expectations that a bug in the boundary condition assembly would likely violate.
4. **Grid-convergence check.** Re-running the baseline case (Case 0) at a coarser grid (e.g., 41×41) and a finer grid (e.g., 241×241) and confirming the solution changes only slightly (not qualitatively) between them confirms 121×121 is a resolution where the solution has actually converged, rather than an arbitrary choice.
5. **Symmetry/limiting-case sanity check.** In the limit $Bi \to 0$ (no convective losses anywhere), the rod becomes purely conduction-limited between the fixed-flux laser end and the fixed-temperature far end — the steady-state solution should reduce to (very nearly) a simple 1D linear temperature profile along $z'$, independent of $r'$, since there's no mechanism left to create radial variation. Running a very small `biotNum` and checking the contour lines become nearly vertical (constant along $r'$) is a good qualitative check of this.

## Known limitations and interpretation traps

- **One-factor-at-a-time sweeps miss interaction effects.** Because only one dimensionless number is varied at a time while the others sit at 1, the results cannot reveal, for example, whether the effect of a small laser spot (low `spotFrac`) becomes more or less severe when convection is already strong (high `biotNum`). A full factorial sweep, or at least a couple of two-parameter sweeps at extreme combinations, would be needed to check for such interactions before generalizing any single-parameter conclusion.
- **First-order (one-sided) differences at all boundaries.** The interior discretization is second-order accurate, but the boundary conditions use first-order one-sided differences. This is a common and defensible simplification, but it means the overall global accuracy of the scheme is limited to first order near the boundaries — worth noting rather than assuming the whole solution is uniformly second-order accurate.
- **The discontinuous boundary condition at $r'=\beta$ is not resolved with any special mesh refinement** near that point — the uniform 121-point grid treats it the same as everywhere else, meaning the sharp feature there is only as well-resolved as the nearest grid points happen to fall. A locally refined mesh near $r'=\beta$ would give a cleaner picture of that discontinuity if it becomes a focus of further analysis.
- **Sweep ranges were chosen for physical interest, not derived from any specific rod's real material properties** — before treating any specific sweep endpoint (e.g., Bi = 50) as representative of a real material and cooling scenario, its corresponding physical $h_{conv}$, $R_{rod}$, $k_{cond}$ combination should be checked for reasonableness.
- **No mesh-independence study is included in the base script** (see Validation point 4) — this should be run and its result stated explicitly before treating the 121×121 solution as fully converged.

## Files

- `mme_208_hw_8_2311002.m` — defines `solveRodTemperature` (the FDM assembly and solve), `runSweepCase`, `computeRiseStats`, `plotRiseTrend`, `plotTempContour`, `plotTempSurface`, and the top-level script that runs the baseline and all four sweeps.
- `input/` — none required; all parameters are set in-script.
- `output/` — `fig1_shapeRatio_sweep.png`, `fig2_spotFrac_sweep.png`, `fig3_biotNum_sweep.png`, `fig4_powNum_sweep.png`.
