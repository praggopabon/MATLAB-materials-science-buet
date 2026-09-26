# MATLAB for Materials Engineering Problem Solving

Problems from the course **Computer Applications to Materials Engineering**, solved in MATLAB and documented from first principles: heat conduction, crystallography, lattice-sum energy, dislocation kinetics, and mechanical/geochemical data analysis. Each problem README states the physical question, the model assumptions, and a validation check against an independent limit, analytical case, or reference value.

## Course context

These problems were assigned as take-home tasks in the undergraduate course **MME 208: Computer Applications to Materials Engineering**, Department of Materials and Metallurgical Engineering, Bangladesh University of Engineering and Technology (BUET).

**Instructor:** Sumit Bhowmick, Lecturer, Department of Materials and Metallurgical Engineering, BUET.
Profile: [https://www.buet.ac.bd/web/#/profile/sumitbhowmick](https://www.buet.ac.bd/web/#/profile/sumitbhowmick)

The solutions here are my own work unless otherwise noted. Where a problem statement, dataset, or figure was provided by the instructor, that material is credited in the corresponding problem folder and is not redistributed here without permission.

## Purpose of this repository

Most coursework repositories are a dump of `.m` files with no explanation. This one tries to be different in three ways:

1. Every problem has a README that starts with the **physical question in plain language**, not the MATLAB function names.
2. Every problem states its **model and assumptions explicitly**, including the ones that are questionable.
3. Every problem includes a **validation or sanity check** — an independent limit, an analytical case, a reference value, or a consistency check between two solution routes.

## Repository layout

```
.
├── README.md
├── LICENSE
├── 01-anisotropic-thermal-conductivity/
│   ├── README.md
│   └── mme_208_hw_1_2311002.m
├── 02-2D-plane-identification/
│   ├── README.md
│   └── mme_208_hw_2_2311002.m
├── 03-stress-strain-characterization/
│   ├── README.md
│   ├── mme_208_hw_3_2311002.m
│   ├── 15680_W_bcc_atoms_1108...
│   ├── 31360_Al_fcc_atoms_7468...
│   └── 32256_Pt_fcc_atoms_1837...
├── 04-NaCl-madelung-energy/
│   ├── README.md
│   ├── mme_208_hw_4_2311002.m
│   └── fig_convergence.png
├── 05-mechanical-characterization/
│   ├── README.md
│   ├── mme_208_hw_5_2311002.m
│   ├── fig0_raw_curves.png
│   ├── fig1_bar_properties.png
│   ├── fig2_loglog_pairs.png
│   └── fig3_ideal_curves.png
├── 06-imputing-missing-geochemical/
│   ├── README.md
│   └── mme_208_hw_6_2311002.m
├── 07-kocks-mecking-dislocation-density/
│   ├── README.md
│   ├── mme_208_hw_7_2311002.m
│   ├── fig1_kocks_mecking.png
│   └── fig2_temperature_dependence.png
├── 08-temperature-field-in-a-laser-heated-rod/
│   ├── README.md
│   ├── mme_208_hw_8_2311002.m
│   ├── fig1_shapeRatio_sweep.png
│   ├── fig2_spotFrac_sweep.png
│   ├── fig3_biotNum_sweep.png
│   └── fig4_powNum_sweep.png
└── 09-segmentation-and-compositional-mapping/
    ├── README.md
    ├── Assignment_ImageProcessing_...
    ├── ImageProcessingReport_23110...
    ├── CroppedEDS.jpg
    ├── EDSvsAl.jpg
    ├── EDSvsCa.jpg
    ├── EDSvsMg.jpg
    ├── EDSvsS.jpg
    ├── redMask.m
    ├── greenMask.m
    ├── blueMask.m
    ├── yellowMask.m
    ├── alMask.m
    └── coordinates.mat
```

Each problem folder contains a `README.md` explaining the physics and a single MATLAB script named after the assignment (`mme_208_hw_N_2311002.m`). Generated figures live in the same folder as the script.

## The problems

### 1. Anisotropic thermal conductivity of graphite

Given a diagonal conductivity tensor constrained by its trace and geometric mean, compute the RMS of the three principal conductivities, find the temperature-gradient components for a fixed heat flux along the [201] direction, determine the heat flux directions that maximize and minimize the gradient magnitude for fixed flux magnitude, and tabulate the gradient magnitude against two direction angles using `meshgrid` — no loops. The interesting part is that the maximum-gradient direction is unique (the c-axis) while the minimum is not (any direction in the basal plane), a direct consequence of hexagonal symmetry.

**Folder:** [`01-anisotropic-thermal-conductivity/`](01-anisotropic-thermal-conductivity/)
**Script:** `mme_208_hw_1_2311002.m`

### 2. Identification of 2D plane groups from symmetry operations

An interactive MATLAB program that asks the user a sequence of questions about a 2D pattern's symmetry operations — rotation order, mirrors, mirror angle, rotation center off mirrors, glide reflections — and identifies which of the 17 wallpaper groups the pattern belongs to. The program handles invalid inputs by warning and re-asking, and prints both the short and orbifold notation for each group. The decision tree is the standard identification flowchart, and the README verifies it by walking all 17 root-to-leaf paths and checking that every leaf is reached exactly once.

**Folder:** [`02-2D-plane-identification/`](02-2D-plane-identification/)
**Script:** `mme_208_hw_2_2311002.m`

### 3. Stress–strain analysis of Al AA2198 alloy

Four heat treatments of Al AA2198 alloy, each with true stress–true strain data. Extract yield strength, UTS, toughness, strength coefficient K, and strain-hardening exponent n via curve fitting, differentiation, and integration. Then find the property pair that best fits a straight line on a log–log plot, interpolate Toughness versus YS through the four processing conditions, use numerical optimization to find the YS that maximizes toughness within the data range, fit every other property as a function of YS, and finally construct a full synthetic stress–strain curve for the "optimal YS" and "maximum toughness" cases.

The folder also contains atomic-structure data files for W (bcc), Al (fcc), and Pt (fcc) used to compute theoretical moduli as cross-checks.

**Folder:** [`03-stress-strain-characterization/`](03-stress-strain-characterization/)
**Script:** `mme_208_hw_3_2311002.m`

### 4. NaCl Madelung energy by direct lattice summation

Compute the per-mole electrostatic potential energy of an infinite 3D NaCl-type crystal by direct lattice summation, determine how large the summation cube must be for two significant figures of accuracy, and fit the convergence trend to extrapolate the time required for three, four, and five significant figures. The README includes the fit equations and a comparison against the literature Madelung constant.

**Folder:** [`04-NaCl-madelung-energy/`](04-NaCl-madelung-energy/)
**Script:** `mme_208_hw_4_2311002.m`
**Key figure:** `fig_convergence.png`

### 5. Three-material stress–strain data import and plotting

Import a raw data table for three materials, programmatically strip headerless columns, add load and displacement columns computed from the specimen dimensions, and generate a four-subplot figure: three individual true (or engineering) stress–strain curves and one combined plot with a legend. The first three subplots are annotated with yield, UTS, and failure points, and the whole figure is saved from code — no manual screenshots.

**Folder:** [`05-mechanical-characterization/`](05-mechanical-characterization/)
**Script:** `mme_208_hw_5_2311002.m`
**Key figures:** `fig0_raw_curves.png`, `fig1_bar_properties.png`, `fig2_loglog_pairs.png`, `fig3_ideal_curves.png`

### 6. Geochemical water-sample imputation

A multi-site water chemistry dataset with missing values. Fill the missing entries using four imputation algorithms, each with and without a log-transform / exp-back-transform wrapper, giving eight trials. Report which trial leaves the fewest NaNs. On the best trial, compute pairwise correlations using `corr(..., 'rows', 'pairwise')` to avoid NaN contamination, and list every unique variable pair correlated at greater than 99.9 % confidence, sorted from strongest to weakest evidence.

**Folder:** [`06-imputing-missing-geochemical/`](06-imputing-missing-geochemical/)
**Script:** `mme_208_hw_6_2311002.m`

### 7. Kocks–Mecking dislocation density model

Form and solve the Kocks–Mecking ODE $d\rho/dt = \dot{\varepsilon}(k_1\sqrt{\rho} - k_2\rho)$ for commercially pure aluminium, convert dislocation density to stress via $\sigma = \alpha G b \sqrt{\rho}$, extract the Young's modulus and the flow stress (the saturation stress at very high strain) from the solution, and find the effective flow strain from where the tangent to the stress–strain curve at zero strain intersects the flow stress line. Then repeat the calculation across a range of $\alpha$ values with temperature-dependent steady-state dislocation density and shear modulus, tuning $k_1$ and $k_2$ so the predicted flow stresses and Young's moduli match physically reasonable trends.

**Folder:** [`07-kocks-mecking-dislocation-density/`](07-kocks-mecking-dislocation-density/)
**Script:** `mme_208_hw_7_2311002.m`
**Key figures:** `fig1_kocks_mecking.png`, `fig2_temperature_dependence.png`

### 8. Steady-state heat conduction in a laser-heated cylindrical rod

Axisymmetric steady-state heat conduction in a cylindrical rod, heated by a laser of radius $s$ at one end and cooled by convection on the cylindrical surface, with the far end held at $T_0$. Nondimensionalize the PDE and its mixed Neumann / Robin boundary conditions into four dimensionless groups — $R/L$, $s/R$, $\pi P R^3 / k T_0$, and $hR/k$ — then solve numerically and plot $T'(r', z')$ as a contour map for a range of those groups. The discontinuity in the $z'=0$ boundary condition at $r' = s/R$ is a real feature of the problem, not a numerical artefact.

**Folder:** [`08-temperature-field-in-a-laser-heated-rod/`](08-temperature-field-in-a-laser-heated-rod/)
**Script:** `mme_208_hw_8_2311002.m`
**Key figures:** `fig1_shapeRatio_sweep.png`, `fig2_spotFrac_sweep.png`, `fig3_biotNum_sweep.png`, `fig4_powNum_sweep.png`

## A note on datasets and figures

Some of these problems used instructor-provided datasets (the water chemistry table, the Al AA2198 stress–strain workbook, the raw three-material tensile data). Those files are **not** committed here without explicit permission. Where the raw input cannot be redistributed, the problem folder still contains the script, a description of the expected input schema, and the generated outputs, so the logic remains inspectable and reproducible from a substitute dataset.

If you are the instructor or rights holder for any of these materials and would like them included or excluded, please open an issue.

## Running the code

Tested on MATLAB R2024b. Toolboxes used across the set:

- Symbolic Math Toolbox (problems 1 and 3)
- Curve Fitting Toolbox (problems 3, 5, 7)
- Optimization Toolbox (problem 3)
- Statistics and Machine Learning Toolbox (problems 6, 8)
- Partial Differential Equation Toolbox (problem 8, optional — a finite-difference fallback is provided)
- Image Processing Toolbox (problem 9)

Run any problem by opening its folder and running the script:

```matlab
run('01-anisotropic-thermal-conductivity/mme_208_hw_1_2311002.m')
```

Or `cd` into a problem folder and run the script directly. Every script writes its figures into its own folder and uses relative paths, so the repo can be cloned anywhere and run without editing directory strings.

## License

Code and text in this repository are released under the MIT License (see `LICENSE`). Instructor-provided data and third-party figures retain their original ownership and are excluded unless explicitly noted.
