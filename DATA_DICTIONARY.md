# Data dictionary

All accuracies are pass@1 in percent. Differences (Δ) are in percentage points relative
to the Standard baseline. SD denotes the sample standard deviation (n - 1) across
run-level evaluations.

## tables/si_table_s1.csv — SI Table S1

Scale dependence of Term-first on GSM8K (five Qwen2.5 scales).

    Measure              text, one of: Standard (mean %), Standard (SD %),
                         Term-first (mean %), Term-first (SD %), (pp) [delta]
    Qwen2.5 0.5B … 32B   accuracy in percent, or SD in percent, or Δ in pp

## tables/si_table_s2.csv — SI Table S2

Behavioral outcomes for the five-problem Logit Lens analysis
(DeepSeek-R1-Distill-Qwen-1.5B, five AIME 2024 problems, four conditions).

    Problem        question identifier (Q1–Q5) and domain
    Condition      Premature convergence / Delayed commitment / Persistent oscillation / Term-first
    Correct        Yes/No, graded against the gold answer
    Tokens         number of generated tokens
    Wait count     number of reflection-marker matches (nine categories)

## tables/si_table_s3.csv — SI Table S3

First-token peak-layer distribution for 15 AIME 2024 problems.

    Condition           the four reasoning-state conditions
    Peak-layer (L26:L27)  count of problems peaking at layer 26 vs 27
    Accuracy (%)        accuracy for that condition
    Agreement with Term-…  agreement of the peak-layer split with Term-first

## tables/si_table_s4.csv — SI Table S4 (Figure 2)

Per-cell replicate summary for the four benchmark panels.

    Variant              panel | prompting strategy (Standard, 14 CoT variants, Term-first)
    Mean pass@1 (%)      mean over four run-level evaluations (AIME 2024: 64 or 256 runs)
    SD (%)               sample standard deviation across those evaluations
    Δ vs Standard (pp)   difference from the panel's Standard baseline
    SD(Δ) (pp)           sqrt(SD_variant^2 + SD_Standard^2)

## tables/si_table_s5.csv — SI Table S5 (Figure 3)

Per-cell replicate summary for the five model scales (GSM8K).

    Variant, Mean pass@1 (%), SD (%), Δ vs Standard (pp), SD(Δ) (pp)   as in Table S4;
    the Standard baseline per scale is in Table S1.

## tables/fig2_task_heterogeneity_scores.csv

Raw per-run accuracies behind Figure 2 for GSM8K, MMLU and HumanEval (four run-level
evaluations per prompt). The file also carries CMMLU columns from an early exploratory run;
they are kept for completeness and are not used in the manuscript.

    Instruction    prompting strategy
    <dataset>_R1 … R4   pass@1 in percent for each of four run-level evaluations

## tables/fig2_aime2024_scores.csv

AIME 2024 per-prompt aggregates (Qwen2.5-3B-Instruct, n = 64 samples per run).

    dataset, prompt, included_in_four_panel_plot, mean_accuracy, std_accuracy,
    std_definition, sem_accuracy, relative_delta_vs_standard_percent,
    relative_sem_vs_standard_percent, absolute_delta_vs_standard_pp, runs,
    total_correct_over_1920, pass_at_64_accuracy, source, selection_role

## tables/fig3_model_scale_scores.csv

Raw per-run accuracies behind Figure 3 (GSM8K, five Qwen2.5 scales).

    Instruction         prompting strategy
    <scale>_R1 … R4     pass@1 in percent for each of four run-level evaluations

## Code and formalization (not tabular)

    evidence/00-fig1-conceptual/      conceptual figure (Figure 1): svg source and exported files
    evidence/01-macro-heterogeneity/  prompt-variant accuracy code and summary CSVs behind Figures 2-3
    evidence/02-state-divergence/     reflection-marker code and hidden-state JSON behind Figure 4
    evidence/03-logit-lens/           Logit Lens trajectories, peak-layer computation, Figure 5
    scripts/plot_config.py            shared style and 400-dpi export helper
    tests/                            smoke tests over the published data files
    formal/                           Lean 4 formalization; see formal/README.md
    raw/                              download instructions for release-attached raw artifacts
    figures/                          the five manuscript figures (PNG, JPG, TIFF, SVG)
