# Code and data for “Contingent Chain-of-Thought effects and causal overclaiming in LLMs”

This repository is the single public home for the code, summary data and formalization of the
manuscript:

> Contingent Chain-of-Thought effects and causal overclaiming in LLMs
> Submitted to *Patterns* (Cell Press).

Contact: Zhiwen Hu (huzhiwen@zjgsu.edu.cn); Minxuan Liu.

## What is here

    tables/      summary tables used in the manuscript (SI Tables S1-S5, per-run accuracies, AIME aggregates)
    evidence/    per-experiment code and the summary data it consumes (00 conceptual figure, 01 macro heterogeneity,
                 02 state divergence, 03 logit lens), each with its own README
    scripts/     shared plotting configuration (plot_config.py: style and export helper)
    tests/       smoke tests over the published data files
    formal/      Lean 4 formalization (final version r13-final: GoldenRule, Instance, Witness_GR,
                 Witness_ModelScale, MethodologyCore, MethodologyWitness)
    raw/         placeholder for the large raw artifacts distributed with the release (see raw/README.md)

Data dictionary: see DATA_DICTIONARY.md.

## Reproducing figures

Each evidence folder contains the plotting script and a README mapping every claim of the manuscript to
its data file. From the repository root, for example:

    python3 evidence/01-macro-heterogeneity/code/Fig3_ScalingLaws.py

Plots are exported by scripts/plot_config.py (PNG, JPG, TIFF, SVG at 400 dpi).

## Reproducing the Lean 4 formalization

    cd formal
    lake build

The proof scripts encode the finite-domain statements of the theory section; the module README describes
which theorem corresponds to which manuscript claim.

## Large raw data

Raw inference logs and packaged run data are attached to the release v1.0.0 of this repository; see
raw/README.md for the download list and where to unpack each archive.

## Licenses

Code: MIT (LICENSE). Data and derived tables: CC BY 4.0 (LICENSE-DATA).
Third-party benchmarks (GSM8K, AIME 2024, MMLU, CMMLU, HumanEval) are not redistributed; only derived
statistics and prompts are included.

## Citation

See CITATION.cff. The archived release is deposited on Zenodo (DOI in CITATION.cff and the release page).
