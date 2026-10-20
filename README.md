# Data for “Contingent Chain-of-Thought effects and causal overclaiming in LLMs”

This repository holds the summary data, accuracy tables and per-experiment documentation
for the manuscript:

> Contingent Chain-of-Thought effects and causal overclaiming in LLMs
> Submitted to *Patterns* (Cell Press).

Contact: Zhiwen Hu (huzhiwen@zjgsu.edu.cn); Minxuan Liu.

## Contents

    tables/si_table_s1.csv                     SI Table S1 — scale dependence of Term-first (GSM8K)
    tables/si_table_s2.csv                     SI Table S2 — behavioral outcomes, five-problem analysis
    tables/si_table_s3.csv                     SI Table S3 — first-token peak-layer distribution
    tables/si_table_s4.csv                     SI Table S4 — replicate variability, Figure 2
    tables/si_table_s5.csv                     SI Table S5 — replicate variability, Figure 3
    tables/fig2_task_heterogeneity_scores.csv  per-run accuracies, 14 CoT variants x GSM8K/MMLU/HumanEval (4 runs)
    tables/fig2_aime2024_scores.csv            AIME 2024 aggregate per prompt (mean, SD, n)
    tables/fig3_model_scale_scores.csv         per-run accuracies, 14 variants x 5 model scales (GSM8K, 4 runs)

See DATA_DICTIONARY.md for columns, units and replicate definitions.

## Raw data

The full raw inference logs and the packaged AIME 2024 run data are attached to the
release “v1.0-data” in this repository:

    raw_inference_logs.tar.gz     OpenCompass per-question outputs (3057 files)
    aime2024_all_data.tar.gz      packaged AIME 2024 run data

## Code

All analysis and figure code is at https://github.com/Miyan0Shiho/patterns-repro
and archived at Zenodo: https://doi.org/10.5281/zenodo.23410783

## Replicate structure

Benchmark and scale experiments use four independent run-level evaluations per cell
(GSM8K / MMLU / HumanEval / scale reruns). The AIME 2024 experiment uses 64 full-benchmark
runs for the Standard prompt and 256 runs for Term-first (four pooled batches of 64).
All reported SDs are sample standard deviations (n - 1).

## License

Data: Creative Commons Attribution 4.0 International (CC BY 4.0).
