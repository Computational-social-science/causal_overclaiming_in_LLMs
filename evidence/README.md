# Experimental evidence (self-contained units)

> This directory contains the evidence chain for every experiment in the manuscript. Each subfolder is a self-contained experiment unit (code + data + README).

## Overview

The manuscript does not treat chain-of-thought prompting as a settled source of gains. It examines two assumptions that are often adopted without verification, and then asks what a prompt prefix does inside the model. The experiments in this directory test the two assumptions and the mechanism question in sequence, and each unit can be read and reproduced on its own.

Experiment 01 works at the level of accuracy. It compares a curated prompt suite on four datasets and five model scales, and finds that the effect of the same CoT prefix changes direction across tasks and is not monotonic in scale. The result is descriptive counter-evidence to the strong universal-enhancer hypothesis; it does not establish a scale threshold.

Experiments 02 and 03 work at the level of hidden states. Experiment 02 holds the problem and the model fixed and changes only the prefix, and finds three distinct trajectories, which supports describing the prefix as an initialization of the model state rather than as a carrier of solution steps. Experiment 03 repeats the analysis on five problems and places the Term-first condition among the three trajectory types. Both units are limited to one dataset (AIME 2024) and one model family, and the claims are stated at that scope.

| Experiment | Folder | Question | Main result | Manuscript figure |
|------------|--------|----------|-------------|-------------------|
| 1. Conditional nature of CoT gains | [`01-macro-heterogeneity/`](01-macro-heterogeneity/) | Should "Let's think step by step" be adopted as a default prefix without verification? | No. The effect depends on task type and model scale; most variants degrade below 32B. | Fig. 2, Fig. 3 |
| 2. Prefix as hidden-state initialization | [`02-state-divergence/`](02-state-divergence/) | What happens inside the model when only the prompt prefix changes? | Three prefixes produce three entirely different hidden-state trajectories. The prefix does not encode solution steps; it sets the initial conditions of the computation. | Fig. 4 |
| 3. Term-first across problems | [`03-logit-lens/`](03-logit-lens/) | Is the single-problem finding stable, and which trajectory type does Term-first belong to? | Delayed commitment shares convergence layer L20 exactly on the five problems; Term-first agrees with it on 4 of 5. | Fig. 5 |

## Argument chain

1. Experiment 1 shows that CoT is not a universal enhancer, which removes the first assumption.
2. With that assumption removed, the question becomes what the prefix is actually doing. Experiments 2 and 3 show that changing only the prefix changes the hidden-state trajectory; the prefix does not encode solution steps, and reflection-marker counts are not the signal.
3. Once the trajectory types are described, a lighter strategy can be designed against them: Term-first reaches or exceeds the heavy CoT conditions with 12 tokens.

## Structure of each experiment folder

```
<experiment>/
├── README.md     experiment card (claim-to-data map, reproduction commands, scope of claims)
├── code/         reproduction scripts
└── data/         reproduction data (CSV / JSON / NPY)
```

## Mapping to manuscript figures

| Manuscript figure | Experiment | Script | Input data |
|-------------------|------------|--------|------------|
| Fig. 2 (task heterogeneity) | 1 | `evidence/01-macro-heterogeneity/code/Fig2_TaskHeterogeneity.py` | `evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv` + `evidence/01-macro-heterogeneity/data/aime2024_qwen25_3b_n64_16k_scores/` |
| Fig. 3 (model scale) | 1 | `evidence/01-macro-heterogeneity/code/Fig3_ScalingLaws.py` | `evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv` |
| Fig. 4 (reflection markers) | 2 | `evidence/02-state-divergence/code/Fig4_ReflectionScatter.py` | `evidence/02-state-divergence/data/reflection_{1p5b,7b,8b}_real.json` |
| Fig. 5 (Logit Lens, four conditions) | 3 | `evidence/03-logit-lens/code/Fig5_LogitLens.py` | `evidence/03-logit-lens/data/logit_lens_5q_4cond.json` |

Fig. 1 is a conceptual diagram and has no script of its own.

## Scope of claims

- **Figs. 2 and 3 (experiment 1)**: reproducible data from OpenCompass over four datasets and five model scales. The task-heterogeneity panel holds 15 prompts (Standard baseline plus 14 CoT variants); the scale panel adds Term-first as a 16th prompt. The CSV files are the direct output.
- **Fig. 4 (experiment 2)**: reflection-marker counts for DeepSeek-R1-Distill-Qwen-1.5B, DeepSeek-R1-Distill-Qwen-7B and DeepSeek-R1-Distill-Llama-8B on AIME 2024, aggregated at prompt level. The JSON files are the direct output.
- **Fig. 5 (experiment 3)**: Logit Lens probability trajectories for five problems × four conditions. The JSON file is the direct output.
