# 9. Segmentation and compositional analysis of an EDS elemental map

## Physical question

An energy-dispersive X-ray spectroscopy (EDS) elemental map encodes five different chemical elements as five different colors overlaid on a single micrograph — calcium (red), silicon (green), magnesium (blue), aluminum (pale "paste"), and sulfur (yellow). Given only this color-coded image, can each element's spatial extent be recovered as a binary mask, and can those masks be turned into a defensible quantitative answer: what fraction of the analyzed area belongs to each element, and how large is a typical region of each?

This problem answers that by color-thresholding each element into its own mask, measuring areas via a scale-bar calibration, and cross-checking the masks' quality with an independent 3D color-clustering plot — while explicitly documenting where the method's assumptions could bias the result.

## Given data

A single annotated EDS micrograph (`EDS.JPG`) with a 0.5 mm scale bar, showing five color-coded elemental phases (Ca-red, Si-green, Mg-blue, Al-paste, S-yellow) plus two annotation arrows and two asterisks overlaid on the image. The micrograph is from a published SEM-EDS characterization of ancient Roman mortar from the Privernum city wall (Seymour et al., *Science Advances*, 2023), studying relict lime clasts and their reaction rims — **see the licensing note in Limitations before including this specific image file in a public repository.**

## Model and assumptions

**Reproducible cropping without a re-run popup.** Manually re-drawing a crop box every time the script runs would break the "runs from a clean clone with no interaction" goal. The script solves this with a cache-check pattern: the crop rectangle is computed interactively only once, then saved to `coordinates.mat`; every subsequent run loads the cached rectangle instead of re-prompting. This is a reasonable pattern for a fixed input image, but it does mean the cached crop is specific to *this* image's pixel dimensions — using the script on a different micrograph would require deleting `coordinates.mat` first, which is worth stating explicitly for a repo audience.

**Five independent, manually supervised color thresholds, each in whichever color space worked best for that color.** Rather than using one universal thresholding rule, each element's mask was built interactively (MATLAB's Color Thresholder app) in whichever of HSV, L\*a\*b\*, or YCbCr gave the cleanest visual separation for that specific color, then exported as a standalone function. This is a defensible engineering choice — different hues separate more cleanly in different color spaces — but it means the five masks are not built by one consistent, principled rule; each is its own hand-tuned decision, documented in the report's threshold tables rather than derivable from the code alone.

- **Ca (red), HSV:** hue tested with two windows near 0°/360° (since red wraps around the hue circle), combined with an OR — this correctly handles hue's circular topology, which a single linear H range could not.
- **Mg (blue) and Si (green), L\*a\*b\*:** separated primarily along the a\* (green–red) and b\* (blue–yellow) opponent axes — appropriate since Mg and Si are visually similar dark, saturated colors that HSV or RGB thresholding tends to confuse, while L\*a\*b\*'s perceptual axes separate them more cleanly.
- **Al (paste), YCbCr:** chosen specifically because L\*a\*b\* did not cleanly separate the pale paste region from the background in this case — a concrete, documented example of the "no single color space works for everything" principle.
- **S (yellow), L\*a\*b\*:** the broadest luminance window of all five masks (L\* from 7 to 90), since yellow appears at very different brightness levels across the image; b\* alone (strongly yellow) does most of the discriminating work.

**Physical-unit calibration via a single scale-bar measurement.** The pixel-to-mm² conversion factor is derived once, by manually measuring the known 0.5 mm scale bar as 173.5 px in Image Tool, then squaring the linear ratio since area scales as length²:

$$cf = \left(\frac{0.5\text{ mm}}{173.5\text{ px}}\right)^2 \approx 8.3\times10^{-6}\ \text{mm}^2/\text{px}$$

This single-measurement calibration is explicitly flagged (see Limitations) as a source of potential systematic error, since it wasn't repeated or averaged.

**Fraction computed relative to total *classified* area, not total image area.** This is a deliberately reasoned choice, stated explicitly in the report: pixels falling outside all five threshold windows aren't confidently assigned to any element, so including them in the denominator would mean reporting a percentage "of the image" using unclassified data. Dividing by the sum of the five classified areas instead makes a narrower, more defensible claim — composition *among the material that was successfully classified* — at the cost of not accounting for whatever fraction of the image (grain boundaries, background, unclassified overlap regions) fell outside every mask.

**Two different noise-filtering choices for two different purposes, applied deliberately unevenly.** The area/fraction calculation (Section 4) uses the raw, unfiltered masks — no minimum region size is removed, because choosing a cutoff was judged to be an arbitrary decision the report didn't want to make unjustified. The 3D color-clustering check (Section 6), by contrast, *does* apply a `minArea = 30` px filter before computing per-region mean colors, specifically to keep small threshold-noise fragments from cluttering the visual clustering check. This inconsistency between the two sections is intentional and explicitly documented, not an oversight — it's worth highlighting in the repo README precisely because it looks, at first glance, like it might be a bug.

**3D color-clustering as an independent mask-quality check, not a new measurement.** For each mask, connected regions are found via `regionprops`, and each region's *mean RGB in the original (unthresholded) image* is computed and scattered in 3D RGB space, colored by its own measured color. This is a clever validation design: if the five masks are genuinely separating five distinct colors, the resulting scatter should show five tight, well-separated clusters — and critically, this check uses the *original* image's colors, so it can catch cases where a mask's binary boundary doesn't actually track a real color boundary, which the binary mask alone couldn't reveal.

## Solution — what the script does, step by step

1. Reads and displays the raw micrograph, including its overlaid annotation text/arrows.
2. Crops to the region of interest, caching the crop rectangle so later runs don't require re-interaction.
3. Applies five independently-tuned color-threshold functions to produce binary masks for S, Ca, Si, Al, and Mg, displaying each as a montage against the cropped original.
4. Sums each mask's pixel area via `regionprops`, converts to mm² using the scale-bar calibration factor, and computes each element's percentage of the total classified area.
5. Splits the cropped image into R/G/B channels once, then for each mask (with small regions ≥30 px filtered) computes each connected region's mean color and scatters all regions from all five elements together in one 3D RGB plot, colored by their own measured color, to visually verify the masks correspond to genuinely separated colors.
6. Prints the count of valid (≥30 px) regions found per element.

## Key result figures

- `output/fig1_original.png` — the raw, uncropped micrograph with annotations intact.
- `output/fig2_cropped.png` — the cropped region of interest (`EDS2`), the basis for everything downstream.
- `output/fig3_yellow_S.png` / `fig4_red_Ca.png` / `fig5_green_Si.png` / `fig6_paste_Al.png` / `fig7_blue_Mg.png` — montage comparisons (original vs. binary mask) for each of the five elements.
- `output/fig8_rgb_clustering.png` — the 3D scatter of per-region mean colors, colored by their own measured value, showing five clusters if the masking is working as intended.

**Measured composition** (from the report's Table 7):

| Element | Mask color | Area (mm²) | Fraction of classified area |
|---|---|---|---|
| S | Yellow | 0.0513 | 2.43% |
| Ca | Red | 0.8650 | 40.89% |
| Si | Green | 0.5874 | 27.77% |
| Al | Paste | 0.4391 | 20.76% |
| Mg | Blue | 0.1723 | 8.15% |
| **Total (classified)** | — | **2.1151** | **100.00%** |

**Region counts** (≥30 px): S = 24, Ca = 48, Si = 41, Al = 52, Mg = 6.

## Validation and sanity checks

1. **Comparison to the published source's own interpretation.** The measured Ca-rich core (~41%) with sulfur confined to thin boundary rims (~2.4%) is consistent with Seymour et al.'s description of a relict lime clast and its reaction rim — this is a genuine, independent validation, since the composition pattern was derived here purely from image thresholding, not copied from the source paper's own numbers.
2. **3D clustering as the primary internal validity check.** Five tight, mutually separated clusters in Figure 8 is direct visual evidence that the five color spaces/threshold windows are doing what they claim; a cluster that's diffuse, split into two lobes, or overlapping with a neighboring element's cluster would indicate that mask's threshold window needs revisiting.
3. **Quantify the flagged yellow/green overlap.** The report explicitly flags, but does not verify, that the S (yellow) and Si (green) L\*a\*b\* windows overlap slightly at their boundary. A one-line check — `sum(bwEDS(:) & bwEDS3(:))`, counting pixels that satisfy *both* the S and Si masks — turns this from an "unverified assumption" (the report's own words) into a concrete number, and should be added and reported before calling this validated.
4. **Region-count plausibility.** Mg's very low region count (6) relative to the others (24–52) is worth explicitly commenting on — is that because Mg genuinely occupies fewer, larger, more contiguous regions in this micrograph, or because the Mg threshold window is under-inclusive relative to the visible blue area? The existing masks and montage figures (Figure 4) can answer this directly by inspection.
5. **Sensitivity of the scale-bar calibration.** Since the mm² conversion rests on a single 173.5 px measurement, remeasuring the scale bar 2–3 times and checking how much `cf` (and therefore every reported area/fraction) shifts would turn the report's stated assumption ("I judged the subpixel placement error to be small") into a quantified uncertainty bound.

## Known limitations and interpretation traps

*(These are stated explicitly and thoughtfully in the original report's Section 7 — reproduced and lightly expanded here, since this is exactly the kind of honest self-assessment that should carry over into the repo.)*

- **Annotation arrows and asterisks were not masked out.** The report's own reasoning — that manual exclusion would break automation, and that the resulting bias is likely small and partially self-canceling (annotations turning some colored pixels black cancels against genuine dark grain-boundary material) — is a judgment call, explicitly *not* verified quantitatively. If this pipeline is reused on images with larger or more numerous annotations, this assumption should be revisited.
- **No minimum region size filter in the area/fraction calculation** (unlike the clustering step, which does filter). Small threshold-noise regions from JPEG compression artifacts or anti-aliased grain boundaries are included in the reported areas; the report judges this contribution as likely minor for large-area elements (Ca, Si) but doesn't quantify it — comparing filtered vs. unfiltered area sums directly would turn "likely minor" into a measured percentage difference.
- **Fraction is relative to classified area, not the whole image** — a deliberate and well-justified choice (see Model above), but one that means these percentages answer "composition among successfully classified material," not "composition across the entire field of view." Any reuse of these numbers should preserve that distinction rather than presenting them as whole-image composition.
- **Overlapping threshold windows between yellow (S) and green (Si)**, flagged but not quantified in the original report — see Validation point 3 above for the direct fix.
- **Inconsistent color spaces across the five masks** (HSV for Ca, L\*a\*b\* for Mg/Si/S, YCbCr for Al) — a deliberate per-color choice for segmentation quality, but it means there's no single, transferable "recipe" here; applying this pipeline to a *different* EDS image with different element colors would likely require re-tuning some or all five threshold windows from scratch in the Color Thresholder app, not just re-running the existing functions.
- **Single-measurement pixel-to-mm calibration**, not averaged over repeated measurements (see Validation point 5).
- **Copyright and redistribution.** This micrograph is from a specific published paper (Seymour et al., *Science Advances*, 2023) — a peer-reviewed journal image, not the student's own data. Confirm the paper's license (many *Science Advances* articles are open-access under CC-BY, which would permit reuse with attribution) before committing `EDS.JPG` itself to a public GitHub repo; if the license doesn't clearly permit it, keep the script, masks, and output figures, cite the paper in the README, and link to the source image rather than redistributing the original file.

## Files

- `main.m` — the full pipeline: read, crop (with coordinate caching), five-element masking, area/fraction calculation, and the 3D clustering check.
- `redMask.m`, `blueMask.m`, `greenMask.m`, `alMask.m`, `yellowMask.m` — the five standalone thresholding functions exported from the Color Thresholder app, one per element, each following read → threshold-in-its-chosen-color-space → return-binary-mask.
- `input/` — `EDS.JPG` (subject to the licensing note above) and, if regenerated, `coordinates.mat`.
- `output/` — the eight figures listed above, plus the printed area/fraction/region-count tables (captured as a text log).
- `report/ImageProcessingReport_2311002.pdf` — the full written report this README is derived from, with detailed per-mask threshold tables and the complete Sources of Error discussion.
