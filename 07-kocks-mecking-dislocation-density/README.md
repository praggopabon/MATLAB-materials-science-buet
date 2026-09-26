# 7. Kocks–Mecking dislocation density evolution and its temperature dependence

## Physical question

When a metal is plastically deformed, dislocations multiply (more strain creates more dislocations) but also annihilate through recovery processes — the two effects compete until the dislocation density settles at a steady-state value. Since flow stress in a metal comes directly from dislocations obstructing each other's motion, that competition also sets the metal's flow stress and, less obviously, an "effective flow strain" — the strain at which the material's behavior transitions from apparently elastic to fully plastic, extracted geometrically rather than measured directly.

This problem answers two related questions: for pure aluminum at a fixed temperature and strain rate, how does dislocation density (and therefore stress) evolve with strain, and what are the resulting Young's modulus, flow stress, and effective flow strain? Then, more ambitiously: if this same physical picture has to hold at *any* temperature (with G and steady-state dislocation density known to vary with temperature), what values must the model's fit constants (k1, k2) take, and is the model's free parameter α at all constrained by requiring physically sensible behavior?

## Given data

- Room-temperature-equivalent parameters for annealed, commercially pure aluminum: ρ₀ = 10¹¹ m⁻², G = 26 GPa, Burgers vector b = 2.86 Å, α ≈ 0.3.
- Constant strain rate ε̇ = 10⁻³ s⁻¹, k1 ≈ 10⁸, k2 ≈ 10 (Part 1).
- Target Young's modulus for aluminum ≈ 70 GPa (Part 2).
- A candidate set of α values {0.01, 0.03, 0.1, 0.3, 1, 3} and a temperature range from room temperature (298 K) to just below aluminum's melting point (933 K), with given empirical temperature dependences for G and the steady-state dislocation density.

## Model and assumptions

**Governing equation.** The Kocks–Mecking evolution law describes storage (multiplication, proportional to √ρ — dislocations multiply on existing dislocation lines, so the rate scales with how much dislocation line length is already present) competing against recovery (proportional to ρ itself — annihilation/rearrangement scales with how many dislocations are around to interact):

$$\frac{d\rho}{d\varepsilon} = k_1\sqrt{\rho} - k_2\rho \quad\Rightarrow\quad \frac{d\rho}{dt} = \dot\varepsilon\,(k_1\sqrt{\rho} - k_2\rho)$$

with the corresponding flow stress $\sigma = \alpha G b \sqrt{\rho}$ (the classic Taylor hardening relation — flow stress scales with the square root of dislocation density, since dislocations act as obstacles whose spacing scales as $1/\sqrt{\rho}$).

**Why `ode45`, not `dsolve`.** The equation is nonlinear (the $\sqrt{\rho}$ term), so no closed-form symbolic solution is being sought, and `ode45` (explicit adaptive Runge–Kutta) is chosen rather than a stiff solver — a reasonable default, and the results converging smoothly to the analytic steady-state value (see Validation) confirms stiffness isn't actually a problem for these particular parameter values.

**Part 1 — steady-state dislocation density from the equilibrium condition.** At large strain, $d\rho/dt \to 0$, giving $k_1\sqrt{\rho} = k_2\rho$, i.e.

$$\rho_{ss} = (k_1/k_2)^2$$

and correspondingly a maximum ("flow") stress $\sigma_{flow} = \alpha G b \sqrt{\rho_{ss}} = \alpha G b (k_1/k_2)$. This is used directly, without needing to solve the ODE numerically to find the asymptote — a nice cross-check against the numerically integrated curve's plateau.

**Young's modulus extracted from the first two solved points.** Rather than fitting a full initial linear segment (as would be appropriate for noisy experimental data), the code uses a two-point secant on the very first ODE solution step: $E = (\sigma_2-\sigma_1)/(\varepsilon_2-\varepsilon_1)$. Since this is a smooth, noise-free numerical solution rather than real digitized data, this simplification is defensible — but it does make the reported E somewhat sensitive to `ode45`'s automatically chosen first time step, a detail worth stating rather than assuming away.

**Effective flow strain as the intersection of two idealized lines.** The construction models the real curve with two straight-line asymptotes: purely elastic loading, $\sigma = E\varepsilon$, and the flat flow-stress plateau, $\sigma = \sigma_{flow}$. Their intersection,

$$\varepsilon_{cut} = \sigma_{flow}/E$$

defines a strain that has no single direct physical meaning on its own (real curves round smoothly through yielding rather than having a sharp corner) — it is a standard graphical construction (a "proportional limit" analog) used to extract a single characteristic strain scale from an otherwise curved transition, and its physical plausibility has to be checked against known aluminum yield strains rather than assumed.

**Part 2 — closing the system with two boundary conditions instead of guessing k1, k2.** Rather than treating k1 and k2 as free-floating fit parameters at every temperature, the script derives them from two physical constraints that must hold simultaneously:

1. **Steady-state consistency:** $k_1 = k_2\sqrt{\rho_{ss}(T)}$, from the same equilibrium condition as Part 1, now evaluated at the temperature-dependent $\rho_{ss}(T)$.
2. **Matching a fixed target Young's modulus** (70 GPa) via the model's *initial* hardening rate. Substituting condition 1 into the stress-vs-strain relation near $\rho = \rho_0$ and linearizing gives

$$Y_{target} = \frac{\alpha G(T) b}{2}\Big(k_1 - k_2\sqrt{\rho_0}\Big)$$

Solving this for $k_2$ (and then $k_1$ from condition 1) means k1 and k2 become *outputs* of the model, for each temperature and each candidate α, rather than inputs guessed by hand — turning the model from "given k1, k2, predict Y and σ_flow" (Part 1) into "given Y and the physical temperature dependences, back out what k1 and k2 must have been" (Part 2). This inversion is the conceptual core of Part 2 and is what lets the six α values be compared on equal footing.

**Temperature dependence of G and ρ_ss.** Both are taken as given empirical relations: shear modulus decreasing roughly linearly with temperature, and steady-state dislocation density decreasing roughly exponentially as temperature rises toward the melting point (physically sensible — thermal recovery becomes more effective at higher T, lowering the density at which multiplication and annihilation balance).

## Solution — what the script does, step by step

**Part 1:**
1. Solves the Kocks–Mecking ODE for ρ(t) at fixed strain rate, α, k1, k2 via `ode45`.
2. Converts time to strain (ε = ε̇·t) and dislocation density to stress via Taylor hardening.
3. Plots ρ vs. time and σ vs. ε side by side (Figure 1).
4. Extracts Young's modulus (two-point secant), analytic maximum flow stress (from $\rho_{ss}=(k_1/k_2)^2$), and effective flow strain (intersection of elastic and flow-stress lines), overlaying both construction lines on the stress-strain plot.

**Part 2:**
1. Sweeps temperature from 298 K to 933 K and, for each of six α values, computes temperature-dependent G(T) and ρ_ss(T).
2. Solves the two boundary conditions (steady-state consistency + target Young's modulus) for k1(T) and k2(T) at each α.
3. Computes the resulting flow stress and effective flow strain at each temperature.
4. Plots k1, k2, and effective flow strain vs. temperature (log y-axis), one curve per α, in three subplots (Figure 2), to compare which α value(s) give physically sensible trends.

## Key result figures

- `output/fig1_kocks_mecking.png` — dislocation density vs. time and the resulting stress-strain curve, with the analytic flow-stress plateau and the elastic-tangent line overlaid, annotated with the extracted E, σ_flow, and ε_cut.
- `output/fig2_temperature_dependence.png` — three subplots (k1, k2, effective flow strain, all log-scale y-axes) vs. temperature, one line per α value, used to identify which α gives the most physically reasonable temperature trends.

## Validation and sanity checks

1. **Numerical steady-state vs. analytic steady-state.** The ODE-solved ρ(t) should plateau, as t → large, at a value matching $(k_1/k_2)^2$ computed directly from the algebraic equilibrium condition — plotting the analytic $\rho_{ss}$ as a horizontal reference line on the ρ-vs-time subplot makes this an immediate visual check rather than something left implicit.
2. **Order-of-magnitude plausibility of Part 1 outputs.** Report the extracted Young's modulus against aluminum's accepted value (~70 GPa) — this is the single most direct check on whether the two-point-secant E extraction is behaving reasonably for these particular ODE parameters, and the assignment itself asks whether the values obtained are "physically feasible."
3. **k1 must stay positive across the whole temperature sweep, for every α tested.** Since $k_2 = 2Y_{target}/(\alpha G(T) b (\sqrt{\rho_{ss}(T)}-\sqrt{\rho_0}))$, if $\rho_{ss}(T)$ ever drops below $\rho_0$ at high temperature (physically odd, but possible depending on the empirical formula's exact numbers), $k_2$ — and consequently $k_1$ — could go negative or blow up. Explicitly checking `all(k2 > 0)` and `all(k1 > 0)` for each α, and reporting the result, turns "is this physically feasible" from a subjective plot-reading exercise into an explicit boolean check.
4. **Which α gives the most realistic k1/k2 magnitudes and trends** is exactly what the assignment asks the script to determine — the README (and ideally the script's own printed output) should explicitly state the conclusion (e.g., "α = 0.3 gives k1, k2 magnitudes closest to typical literature values and the smoothest ε_cut trend, while α = 3 produces implausibly large/negative recovery coefficients") rather than leaving that judgment entirely to a reader squinting at the log-scale plot.
5. **Effective flow strain, ε_cut, should stay small (well under 1%) at all temperatures for the realistic α** — a large or non-monotonic ε_cut trend across temperature is a signal that the corresponding α value is not physically sound for this model.

## Known limitations and interpretation traps

- **Two-point Young's modulus is sensitive to solver step size.** Because `E` is computed from only the first two points `ode45` happens to return, changing `ode45`'s tolerances (`odeset('RelTol', ...)`) could change the reported E even though the underlying physics hasn't changed. A more robust version would fit a line to several of the earliest points, or use the analytic initial slope $d\sigma/d\varepsilon|_{\varepsilon=0} = \frac{\alpha G b}{2}\frac{k_1\dot\varepsilon}{\sqrt{\rho_0}}\big/\dot\varepsilon$ (from differentiating the closed-form relation at ρ₀) rather than relying on the numerical solver's arbitrary first step.
- **Effective flow strain is a geometric construction, not a measured quantity.** As noted above, ε_cut is where two idealized straight lines cross, not a point on the actual smooth ρ(t)-derived stress-strain curve — this needs to be stated plainly rather than implying it is directly extracted "from the ODE solution" the way the assignment's phrasing might suggest.
- **Part 2's boundary-condition derivation assumes a particular linearization of the stress-strain relation near ρ₀** — the exact algebraic relation used to connect Young's modulus to k1, k2, α, and G should be double-checked against the derivation in the code's comments (or independently re-derived) before trusting the resulting k1(T), k2(T) curves, since a subtle sign or factor-of-2 error here would propagate through every subsequent Part 2 result without necessarily producing an obviously wrong-looking plot.
- **The empirical G(T) and ρ_ss(T) formulas are given, not derived** — their validity outside the stated temperature range (298–933 K) is not established, and extrapolating this model beyond that window (e.g., to liquid-state temperatures) would not be meaningful.
- **No single α is claimed correct without justification.** The assignment explicitly asks which α is "more realistic" — this is a judgment call that should be argued for explicitly in the README/report (via check 4 above), not left as an open question after presenting the plot.

## Files

- `main.m` — Part 1 (single-temperature ODE solution, property extraction) and Part 2 (temperature sweep across six α values, boundary-condition-derived k1/k2).
- `input/` — none required; all parameters and empirical relations are defined in-script.
- `output/` — `fig1_kocks_mecking.png`, `fig2_temperature_dependence.png`, and the printed E/σ_flow/ε_cut values from Part 1 (captured as a text log).
