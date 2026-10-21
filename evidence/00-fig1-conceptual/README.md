# 00 — Figure 1: conceptual framework

Figure 1 is the conceptual diagram of the manuscript and the entry point of its argument. It is a
structured picture of causal overclaiming in AI research, drawn in three bands: (1) a popular strategy
is accepted without verification, (2) the re-examination performed in this work (two instantiations and
one mechanism analysis), and (3) the take-away. This unit contains the diagram source and its exported
files.

## What this figure does

- It shows no experimental data; it is the roadmap of the manuscript.
- It leads the reader from the general pattern in AI research to the examination performed here.
- It is read together with the "Bigger picture" paragraph of the manuscript.

## Files

| File | Purpose |
|------|---------|
| `data/ConceptualFramework.svg` | vector source of the figure, as drawn |
| `figures/Figure1_ConceptualFramework.png` | raster export used for reading and review |
| `figures/Figure1_ConceptualFramework.tiff` | TIFF export, the format required for submission |
| `figures/Figure1_ConceptualFramework.jpg` | JPEG export for quick viewing |
| `figures/Figure1_ConceptualFramework.svg` | SVG copy of the same drawing |

## Reproduction

Figure 1 is a hand-drawn vector diagram, not a data-driven plot, so it has no generating script. The
editable source is `data/ConceptualFramework.svg`; the files in `figures/` are the exports used in the
manuscript. To change wording or layout, edit the SVG and export it again. Figures 2-5 are regenerated
from data by the scripts in their own evidence folders (see the table in `evidence/README.md`).

## Design constraints

- 3872 x 1973 px at export (about 2:1), which matches the width of a full-width manuscript figure
- readable in 30 seconds: each component carries one claim
- palette shared with the other manuscript figures (Figures 2-5), taken from the Okabe-Ito palette in
  `scripts/plot_config.py`
- fonts: Arial / Helvetica, as in the manuscript

## Scope of claims

- Highest: Figure 1 is a roadmap and no other experiment depends on it.
- Editing Figure 1 changes no number in Figures 2-5.
- The only constraint is that its wording agrees with the "Bigger picture" paragraph of the manuscript.
