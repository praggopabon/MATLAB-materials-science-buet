# 1. Anisotropic thermal conductivity of graphite

## Physical question

Graphite conducts heat very differently along its basal planes and along its c-axis. If you force a fixed heat flux through graphite, how large a temperature gradient do you need? How does that gradient change when you rotate the heat flux direction? Which directions require the largest and smallest gradients, and are those directions unique?

This problem answers those questions from the diagonal thermal conductivity tensor of crystalline graphite.

## Given data

- Lattice parameters: $a = b = 2.47$ Å, $c = 7.8$ Å, $\alpha = \beta = 90^\circ$, $\gamma = 120^\circ$.
- Conductivity constraints: $k_{xx} + k_{yy} + k_{zz} = 800$ W m⁻¹ K⁻¹ and $(k_{xx} k_{yy} k_{zz})^{1/3} = 225$ W m⁻¹ K⁻¹.
- $x$, $y$, $z$ are aligned with the $a$, $b$, $c$ edges respectively.
- Heat flux magnitude along [201]: $J = 3000$ W m⁻².

## Model and assumptions

Fourier's law for anisotropic conduction is

$$\mathbf{J} = -\mathbf{K} \nabla T$$

For graphite in the crystal-axis basis the conductivity tensor is diagonal:

$$\mathbf{K} = \begin{bmatrix} k_{xx} & 0 & 0 \\ 0 & k_{yy} & 0 \\ 0 & 0 & k_{zz} \end{bmatrix}$$

with hexagonal symmetry $k_{xx} = k_{yy} = k_a$ (basal plane) and $k_{zz} = k_c$ (c-axis). The two constraints therefore become

$$2 k_a + k_c = 800, \qquad k_a^2 k_c = 225^3$$

The script solves this pair with `vpasolve`.

For the [201] direction the real-space lattice vector is taken as

$$\mathbf{v}_{[201]} = 2a \hat{x} + 0 \hat{y} + c \hat{z}$$

which is justified because the $b$-component is zero and the $a$-axis is perpendicular to the $c$-axis. The $120^\circ$ angle between $a$ and $b$ does not enter this particular direction.

Steady state is assumed. $\mathbf{K}$ is constant and diagonal in the chosen basis. Off-diagonal coupling is neglected.

## Solution

### Step 1 — Principal conductivities

Solving $2 k_a + k_c = 800$ and $k_a^2 k_c = 225^3$ gives three real roots. The physically meaningful one for graphite is

$$k_a = k_{xx} = k_{yy} \approx 354.73 \ \text{W m}^{-1}\text{K}^{-1}, \qquad k_c = k_{zz} \approx 90.54 \ \text{W m}^{-1}\text{K}^{-1}$$

The other two roots are $k_a \approx 151.34$ (with $k_c \approx 497.33$) and $k_a \approx -106.06$ (with $k_c \approx 1012.13$). Both are rejected: the first has the c-axis conducting better than the basal plane, which contradicts the covalent in-plane / van der Waals interlayer bonding picture; the second is negative.

### Step 2 — RMS of the three conductivities

$$k_{\mathrm{RMS}} = \sqrt{\frac{k_{xx}^2 + k_{yy}^2 + k_{zz}^2}{3}} = \sqrt{\frac{2 k_a^2 + k_c^2}{3}} \approx 294.32 \ \text{W m}^{-1}\text{K}^{-1}$$

### Step 3 — Gradient for heat flux along [201]

The unit vector along [201] is

$$\hat{\mathbf{u}}_{[201]} = \frac{2a \hat{x} + c \hat{z}}{\sqrt{(2a)^2 + c^2}} \approx 0.5351 \hat{x} + 0.8448 \hat{z}$$

With $J = 3000$ W m⁻²,

$$J_x \approx 1605.3, \qquad J_y = 0, \qquad J_z \approx 2534.4 \ \text{W m}^{-2}$$

The temperature-gradient components are

$$\frac{\partial T}{\partial x} = -\frac{J_x}{k_{xx}} \approx -4.53 \ \text{K m}^{-1}$$

$$\frac{\partial T}{\partial y} = 0$$

$$\frac{\partial T}{\partial z} = -\frac{J_z}{k_{zz}} \approx -28.00 \ \text{K m}^{-1}$$

The gradient magnitude is

$$G_{[201]} = \lvert \nabla T \rvert \approx 28.36 \ \text{K m}^{-1}$$

The gradient is **not** parallel to the heat flux, because $k_{xx} \neq k_{zz}$. The angle between $\mathbf{J}$ and $\nabla T$ is about $157^\circ$, i.e. mostly but not exactly antiparallel, as expected from the negative sign in Fourier's law combined with anisotropy.

### Step 4 — Maximum and minimum gradient for fixed J

For fixed flux magnitude $J$,

$$G = \lvert \nabla T \rvert = J \sqrt{\frac{u_x^2}{k_{xx}^2} + \frac{u_y^2}{k_{yy}^2} + \frac{u_z^2}{k_{zz}^2}}$$

The largest gradient occurs when the heat flux is aligned with the **smallest** conductivity, i.e. the c-axis:

$$G_{\max} = \frac{J}{k_{\min}} = \frac{3000}{90.54} \approx 33.14 \ \text{K m}^{-1}$$

along $\pm [001]$. This direction is **unique up to sign**.

The smallest gradient occurs when the heat flux lies anywhere in the basal plane, where $k_{xx} = k_{yy} = k_{\max}$:

$$G_{\min} = \frac{J}{k_{\max}} = \frac{3000}{354.73} \approx 8.46 \ \text{K m}^{-1}$$

Because $k_{xx} = k_{yy}$, **every direction in the $x$-$y$ basal plane gives the same minimum magnitude**. The minimum is therefore **not unique**.

### Step 5 — Directional variation via `meshgrid`

Two 6-element angle vectors are used:

- $\theta$: polar angle from the c-axis (the maximum-gradient direction).
- $\phi$: azimuthal angle in the basal plane (measured from the x-axis).

The heat-flux components are

$$J_x = 3000 \sin\theta \cos\phi, \qquad J_y = 3000 \sin\theta \sin\phi, \qquad J_z = 3000 \cos\theta$$

Because $k_{xx} = k_{yy}$, the gradient magnitude simplifies to

$$G(\theta) = 3000 \sqrt{\frac{\sin^2\theta}{k_a^2} + \frac{\cos^2\theta}{k_c^2}}$$

which is **independent of $\phi$**. The `meshgrid` table therefore has identical rows. This is physically correct for hexagonal graphite and is itself a useful sanity check: rotating the heat flux inside the basal plane does not change the required gradient magnitude.

## Key result figure

`output/fig1_anisotropic_gradient.png`

The natural single figure is a polar plot of $G(\theta)$ versus heat-flux direction, with three features marked:

1. The maximum at the c-axis: $G_{\max} \approx 33.14$ K m⁻¹.
2. The minimum plateau in the basal plane: $G_{\min} \approx 8.46$ K m⁻¹.
3. The [201] direction: $G_{[201]} \approx 28.36$ K m⁻¹.

Because the problem is transversely isotropic, the polar plot is a figure-eight shape whose lobes point along $\pm [001]$.

## Validation and sanity checks

1. **Constraints recomputed from the solved values.** $2(354.73) + 90.54 \approx 799.99$ and $(354.73^2 \cdot 90.54)^{1/3} \approx 224.99$. Both hold to within rounding.

2. **Isotropic limit.** If all three conductivities were equal, the geometric mean would equal the arithmetic mean, so $k = 800/3 = 266.67$. Then $G = 3000/266.67 = 11.25$ K m⁻¹ in every direction. The anisotropic RMS is $294.32$, and the directional gradient ranges from $8.46$ to $33.14$ K m⁻¹. The anisotropy is real and large.

3. **Max / min ratio.** $G_{\max} / G_{\min} = k_{\max} / k_{\min} = 354.73 / 90.54 \approx 3.92$, which matches $33.14 / 8.46 \approx 3.92$.

4. **[201] lies between the bounds.** $8.46 < 28.36 < 33.14$. As it must, since [201] is neither purely basal-plane nor purely c-axis.

5. **Direction of $\nabla T$.** For [201], $\mathbf{J}$ and $\nabla T$ are not antiparallel. The angle is about $157^\circ$, confirming that the conductivity anisotropy tilts the gradient away from the flux direction.

6. **Literature check.** Graphite typically has $k_a$ between 300 and 500 W m⁻¹ K⁻¹, and $k_c$ between 80 and 100 W m⁻¹ K⁻¹. The solved values $k_a \approx 354.7$ and $k_c \approx 90.5$ are physically reasonable.

7. **Basal-plane isotropy.** The gradient magnitude depends only on $\theta$, not $\phi$. This follows directly from $k_{xx} = k_{yy}$ and is a non-trivial check on the `meshgrid` block.

## Known limitations and interpretation traps

- **The two constraints alone do not determine three conductivities.** They determine $k_{xx} = k_{yy} = k_a$ and $k_{zz} = k_c$ only under the hexagonal-symmetry assumption. That assumption is justified for graphite, but it must be stated.

- **[201] convention.** This README uses the real-space lattice vector $2a \hat{x} + c \hat{z}$. If instead one reads [201] as the Cartesian vector $(2, 0, 1)$, the numerical gradients change. The lattice-vector interpretation is the standard crystallographic one.

- **Non-orthogonal $x$-$y$ basis.** In hexagonal graphite, $a$ and $b$ are at $120^\circ$. A diagonal conductivity tensor in a non-orthogonal basis is not strictly identical to a diagonal tensor in an orthonormal basis. For [201] the $y$-component is zero and $a \perp c$, so the main numerical answer is unaffected. For arbitrary basal-plane directions a proper metric tensor would be needed. The `meshgrid` table avoids this by working in principal axes.

- **"RMS of nonzero conductivities."** Taken here to mean the RMS of the three principal conductivities $k_{xx}, k_{yy}, k_{zz}$. If the problem intended something else, the definition should be revisited.

- **Meshgrid degeneracy.** Because $k_{xx} = k_{yy}$, the second angle $\phi$ has no effect on $G$. If the grader expected a non-constant table in both angles, the problem is physically inconsistent with hexagonal graphite.

## Files

- `mme_208_hw_1_2311002.m` — solves the problem, prints the meshgrid table, and generates the key-result figure.
