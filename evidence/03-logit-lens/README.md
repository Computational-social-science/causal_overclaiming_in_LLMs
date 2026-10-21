# 03 — Logit Lens: prompt-associated tracked-token trajectories

This unit supports Fig. 5 (tracked-token probability trajectories over five problems × four conditions) and Table S3 (first-token peak-layer distribution over 15 problems). On five selected AIME 2024 problems the four prompt conditions produce tracked-token trajectories of different shape. The results describe representation organization only and are not used to establish a mechanism.

---

## What this experiment does

02-state-divergence found three hidden-state trajectories on a single problem. This experiment extends the same analysis to five problems × four conditions and tests two questions:

1. Do the three trajectory types found on one problem reproduce on other problems?
2. Which trajectory type does the Term-first hidden state belong to?

**Method**: five AIME 2024 problems (one each from logarithms, geometry, number theory, combinatorics and algebra) were each run once under each of the four prefixes, and the Logit Lens probability trajectory was tracked.

---

## Experimental setting

| Dimension | Detail |
|-----------|--------|
| Model | DeepSeek-R1-Distill-Qwen-1.5B (29 layers) |
| Problems | AIME 2024 × 5 (one each from logarithms, geometry, number theory, combinatorics, algebra) |
| Conditions | 4 (under_thinking / normal_thinking / over_thinking / term_first) |
| Analysis | Logit Lens |
| Device | Mac MPS / float16 |

---

## The four conditions

| Manuscript condition | Prompt | Tracked token |
|----------------------|--------|---------------|
| Premature convergence | `"Wait, think."` | `<end_of_sentence>` |
| Delayed commitment | `"Let's reason through this step by step."` | `<end_of_sentence>` |
| Persistent oscillation | `"Let's think step by step."` | `Wait` |
| Term-first | `"What is the query? Term first, then reasoning."` | `<end_of_sentence>` |

---

## Key results

| Finding | Value | Reading |
|---------|-------|---------|
| Delayed-commitment convergence layer (5 problems) | L20 throughout | descriptive observation inside this selected setup, not a proof of cross-problem stability |
| Term-first convergence layer (4 of 5 problems) | L20 | same layer index as delayed commitment in this sample |
| Term-first exception (Q4, combinatorics) | L26, fallback token used | not directly comparable with the EOS-tracked trajectories |
| Premature-convergence peak-layer range | L19–L27 (scattered) | cannot be read as a stable commitment timing |
| Persistent-oscillation tracked probability | 0.002–0.594 | absolute values are not comparable to the EOS-tracked conditions, which use a different target token |
| Model accuracy | 11 of 12 conditions correct on the decidable Q1–Q3 | the trajectories cover both correct and incorrect reasoning |

---

## Claim-to-data map

| Claim | Data file |
|-------|-----------|
| Logit Lens probability trajectories, five problems × four conditions | `data/logit_lens_5q_4cond.json` |
| Accuracy, five problems × four conditions | `data/accuracy_summary.json` |
| First-token peak-layer distribution over 15 problems (Table S3) | `data/logit_lens_1.5b_full.json` |
| Derived statistics for Table S3 | `data/table_s3_peak_layers.json` |

---

## Figures

| Manuscript figure | Script | Input | Output |
|-------------------|--------|-------|--------|
| Fig. 5 | `code/Fig5_LogitLens.py` | `data/logit_lens_5q_4cond.json` | `figures/Fig5_LogitLens.{png,jpg,tiff,svg,pdf}` |
| Table S3 | `code/compute_peak_layers.py` | `data/logit_lens_1.5b_full.json` | `data/table_s3_peak_layers.json` |

---

## Reproduction

```bash
cd code/
python3 Fig5_LogitLens.py             # Fig. 5
python3 compute_peak_layers.py        # derived statistics for Table S3
```

No GPU is required; the scripts load JSON and plot with matplotlib in about 5 seconds.

---

## Scope and caveats

- **Tracked tokens are not directly comparable across conditions**: three conditions track `<end_of_sentence>`, while persistent oscillation tracks `Wait`. Absolute probability magnitudes are therefore not comparable across conditions.
- **Five problems**: the sample is small, each cell is a single generation and the conditions are post hoc; no stable taxonomy or mechanism can be inferred.
- **Single model**: only DeepSeek-R1-Distill-Qwen-1.5B is used, so no cross-model generalization is claimed.
- **Wait counts**: the `wait` field of `data/logit_lens_5q_4cond.json` counts only the generated continuation and excludes the prompt. The single-problem `1/1/21` Wait values reported in the manuscript come from `evidence/02-state-divergence/data/selected_controlled_case.json` and are also continuation-only.
