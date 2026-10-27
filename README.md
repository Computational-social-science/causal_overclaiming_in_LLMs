# Code and data for “Contingent Chain-of-Thought effects and causal overclaiming in LLMs”

> **Archived on Zenodo**: <https://zenodo.org/records/23541463>
> **Raw data**: the four large archives (raw inference logs and packaged run data) are attached to the release of this repository; see raw/README.md for the file list.

## What is here

    tables/      summary tables used in the manuscript (SI Tables S1-S5, per-run accuracies, AIME aggregates)
    evidence/    per-experiment code and the summary data it consumes (00 conceptual figure, 01 macro heterogeneity,
                 02 state divergence, 03 logit lens), each with its own README
    scripts/     shared plotting configuration (plot_config.py: style and export helper)
    tests/       smoke tests over the published data files
    formal/      Lean 4 formalization (GoldenRule, Instance, Witness_GR, Witness_ModelScale,
                 MethodologyCore, MethodologyWitness)
    figures/     the five manuscript figures in PNG, JPG, TIFF and SVG
    raw/         placeholder for the large raw artifacts distributed with the release (see raw/README.md)

Data dictionary: see DATA_DICTIONARY.md.

## Figures

The five files in `figures/` are the figures of the manuscript, in the four formats of the submission
(PNG, JPG, TIFF, SVG; bitmaps at 400 dpi, TIFF for uploading). Figures 2-5 are regenerated from data by
the scripts below, run from the repository root; each run rewrites its `figures/FigureN_*` files in all
four formats:

    python3 evidence/01-macro-heterogeneity/code/Fig2_TaskHeterogeneity.py # figures/Figure2_TaskHeterogeneity.*
    python3 evidence/01-macro-heterogeneity/code/Fig3_ScalingLaws.py       # figures/Figure3_ScalingLaws.*
    python3 evidence/02-state-divergence/code/Fig4_ReflectionScatter.py    # figures/Figure4_ReflectionScatter.*
    python3 evidence/03-logit-lens/code/Fig5_LogitLens.py                  # figures/Figure5_LogitLens.*

Figure 1 is a hand-drawn vector diagram rather than a data plot: `evidence/00-fig1-conceptual/data/`
holds its SVG source and `figures/Figure1_ConceptualFramework.*` the exported files used in the
manuscript. Each script documents its data sources at the top, and the per-folder README maps every
manuscript claim to its data file. Plots are exported through `scripts/plot_config.py`.

## Reproducing the Lean 4 formalization

    cd formal
    lake build

The proof scripts encode the finite-domain statements of the theory section; the module README describes
which theorem corresponds to which manuscript claim.

## Large raw data

Raw inference logs and packaged run data are attached to the release of this repository; see
raw/README.md for the download list and where to unpack each archive.

## Licenses

Code: MIT (LICENSE). Data and derived tables: CC BY 4.0 (LICENSE-DATA).
Third-party benchmarks (GSM8K, AIME 2024, MMLU, CMMLU, HumanEval) are not redistributed; only derived
statistics and prompts are included.

## Citation

See CITATION.cff. The archived release is deposited on Zenodo (DOI in CITATION.cff and the release page).
