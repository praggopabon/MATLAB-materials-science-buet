# 2. Identification of 2D plane groups from symmetry operations

## Physical question

A 2D periodic material (a crystal, a wallpaper pattern, an atomic monolayer) can only repeat itself in space in 17 distinct ways — the 17 plane groups. Which one a given pattern belongs to is decided entirely by its symmetry operations: what rotations it has, whether it has mirrors, whether those mirrors sit at special angles or off the rotation centers, and whether it has glide reflections.

This program answers that identification question interactively: it asks a user a sequence of yes/no questions about the pattern's symmetry operations and returns the correct plane group, in both short and full (orbifold) notation.

## Given data

The question sequence is not invented ad hoc — it follows the standard identification flowchart (reproduced from Wikipedia in the assignment), which branches first on rotation order, then on mirror presence, then on finer distinctions (mirror angle, rotation-center-off-mirror, glide reflection). The task requires that the script:

- correctly identify all 17 plane groups,
- handle invalid user entries with a warning and re-ask, and
- allow either text or GUI interaction.

## Model and assumptions

The flowchart is a decision tree, so the script is structured as one: a top-level `switch` on rotation order (60°, 90°, 120°, 180°, 360°), with each branch nested-`switch`-ing on the next distinguishing feature until a unique group is reached. This mirrors the mathematical fact that these five questions (rotation order, reflection, mirror angle/off-center, glide) are together *sufficient* to distinguish all 17 groups — no case in the tree is redundant, and no case is left undetermined.

The GUI element is handled with a small wrapper function:

    function choice = ask(prompt, options)
        choice = menu(prompt, options{:});
        while choice == 0
            msgbox('Invalid Entry: Please pick an option');
            choice = menu(prompt, options{:});
        end
    end

`menu()` returns 0 if the user closes the dialog without selecting anything, which is the only way to produce an "invalid" input in a menu-based interface (there's no free-text entry to sanitize). The `while` loop turns that into the assignment's required warning-and-reask behavior — the user cannot proceed until they pick a real option.

## Solution — how the tree maps to the code

**Step 1 — Rotation order.** `ask('What rotation does it have?', {'60°','90°','120°','180°','360°'})` sorts the pattern into one of five rotation-order families. This is the single largest split: it immediately separates hexagonal, square, and lower-symmetry cases.

**Step 2 — 6-fold branch (case 1).** Only one further question is needed: reflection present or not. This directly resolves to `p6m` (*632) or `p6` (632) — 6-fold rotation leaves no room for finer subdivision beyond mirror presence.

**Step 3 — 4-fold branch (case 2).** Reflection present or not, and if present, whether a mirror sits at 45° to the main axes. This is the step that separates `p4m` (*442) from `p4g` (4*2) — both have 4-fold rotation and reflection, but differ in mirror orientation relative to the rotation axes. No reflection collapses directly to `p4` (442).

**Step 4 — 3-fold branch (case 3).** Reflection present or not, and if present, whether the rotation center sits off the mirror lines. This distinguishes `p31m` (3*3) from `p3m1` (*333) — a subtlety that trips up manual identification, since both groups have mirrors and 3-fold rotation, but the mirrors' relationship to the rotation centers differs.

**Step 5 — 2-fold branch (case 4).** This is the largest branch (6 groups) because 2-fold rotation is the least restrictive symmetry, so more configurations survive. It asks reflection → perpendicular reflection → rotational center off mirrors (for the reflective side: `cmm`, `pmm`, `pmg`), or reflection → glide reflection (for the non-reflective side: `pgg`, `p2`).

**Step 6 — 1-fold branch (case 5).** No rotation beyond identity. Reflection → glide axis off mirrors resolves `cm` vs `pm`; no reflection → glide reflection resolves `pg` vs `p1`.

Every one of the 17 `msgbox` calls in the script corresponds to exactly one leaf of this tree, and every leaf is reached by exactly one path of answers — which is what the assignment means by "identify all 17 plane groups accurately."

## Key result / how to verify it works

There's no numerical figure here — the "output" is the interactive dialog sequence and a final `msgbox` naming the group. The meaningful verification is a manual traversal test: walk all 17 root-to-leaf paths by hand and confirm each produces the correct standard notation.

| Path (Rotation → …) | Result |
|---|---|
| 60° → Yes | p6m (*632) |
| 60° → No | p6 (632) |
| 90° → Yes → Yes | p4m (*442) |
| 90° → Yes → No | p4g (4*2) |
| 90° → No | p4 (442) |
| 120° → Yes → Yes | p31m (3*3) |
| 120° → Yes → No | p3m1 (*333) |
| 120° → No | p3 (333) |
| 180° → Yes → Yes → Yes | cmm (2*22) |
| 180° → Yes → Yes → No | pmm (*2222) |
| 180° → Yes → No | pmg (22*) |
| 180° → No → Yes | pgg (22×) |
| 180° → No → No | p2 (2222) |
| 360° → Yes → Yes | cm (*×) |
| 360° → Yes → No | pm (**) |
| 360° → No → Yes | pg (××) |
| 360° → No → No | p1 (0) |

That's exactly 17 rows with no duplicates — a direct count check that the tree is complete and non-redundant.

## Validation and sanity checks

1. **Count check.** 17 leaves reached, matching the 17 known plane groups exactly — confirmed by the table above.
2. **Notation cross-check.** Both short (`p4m`) and orbifold (`*442`) notations are printed together, and they can be checked independently against the standard reference table — if they disagree for any case, that path has a bug.
3. **Invalid-entry test.** Closing the `menu()` dialog without a selection (clicking the window's close button) at any question should trigger the warning and re-display the same question, never crash or silently default to an option.
4. **Symmetry-count sanity.** The branch sizes are not arbitrary: 6-fold and 3-fold each split into only 2–3 leaves, while 2-fold splits into 6. This matches the general crystallographic fact that lower rotational symmetry permits more independent mirror/glide configurations.

## Known limitations and interpretation traps

- **GUI dependency.** `menu()` and `msgbox()` require a graphical MATLAB session (they don't work headlessly or in some CI/batch environments). If you want this runnable in a non-interactive test harness, a text-interface twin using `input()` and `disp()` would need to sit alongside it, since the assignment allows either but this version commits to GUI only.
- **No automated self-test.** The 17-path verification above was done by manual traversal, not by a script that programmatically drives all 17 answer sequences. A `runtests`-style harness that feeds each path and asserts the correct `msgbox` string would be a stronger validation artifact for the repo than manual inspection.
- **Decision tree hardcoded, not data-driven.** The tree structure lives in nested `switch` statements rather than being built from the "provided question table" as a lookup structure. This is easy to read but harder to prove correct against the source table directly — the README's manual cross-check exists to bridge that gap.
- **No handling of ambiguous or contradictory real-world input.** The tree assumes the user answers accurately and consistently; it cannot detect if someone reports symmetries that don't co-occur in any real plane group (e.g., 6-fold rotation with a 45° mirror), because the tree structure itself prevents reaching such a combination — this is a feature, not a gap, but worth stating.

## Files

- `main.m` — the plane-group identification script.
- `input/` — none required; all input is interactive.
- `output/` — none generated; result is displayed via `msgbox`. If you add the text-interface twin, its transcript could be logged here.
