# 01 — Conditional nature of CoT gains

This unit supports Fig. 2 (task heterogeneity) and Fig. 3 (model scale). It compares a curated prompt suite across four datasets and five Qwen2.5 scales and shows that the effect of a CoT prefix depends on the task and on the scale, so the prefix cannot be described as a universal enhancer.

---

## What this experiment does

The experiment tests a widely assumed premise: whether "Let's think step by step" can be used without verification in every setting.

**Method**: the curated prompt suite was compared on four datasets (GSM8K, MMLU, HumanEval, AIME 2024) and across five Qwen2.5 scales (0.5B–32B). The task-heterogeneity panel holds 15 prompts: the Standard baseline plus 14 conventional zero-shot CoT variants, with Term-first excluded. The scale panel holds 16, the same 15 plus Term-first. The AIME 2024 experiment evaluates 16 prompt conditions in total, including the post-selected Term-first diagnostic probe.

**Results**:

1. The same prompt changes accuracy in opposite directions on different tasks: a template that gains on one dataset may degrade on another.
2. The scale effect is confounded with backend, dtype, token cap and offload, so it can only be described as a scale–implementation bundle and cannot be attributed to model capability.
3. A small change to a prompt (a different word) changes the set of problems that are answered correctly rather than shifting the score smoothly; this result is used as historical descriptive evidence.

**Role in the manuscript**: descriptive counter-evidence to the strong universal-enhancer hypothesis. It does not support "small models never gain" and does not establish any scale threshold.

---

## Experimental setting

| Dimension | Detail |
|-----------|--------|
| Model family | Qwen2.5 (0.5B, 1.5B, 3B, 7B, 32B) |
| Datasets | GSM8K (math reasoning), MMLU (knowledge QA), HumanEval (code generation), AIME 2024 (competition mathematics) |
| Prompts | 15 in the task-heterogeneity panel (Standard baseline plus 14 CoT variants); 16 in the scale panel (those 15 plus Term-first); 16 prompt conditions in the AIME 2024 panel, including the Term-first diagnostic probe |
| Evaluation | GSM8K/MMLU/HumanEval: mean pass@1 over four generations (n=4); AIME 2024: pass@1 (n=64, four batches pooled) |
| Framework | OpenCompass |

---

## Key results

| Finding | Value | Meaning |
|---------|-------|---------|
| Worst CoT variant on GSM8K | −2.11 to −1.29 pp (95% CI) | adding CoT does not always help and can reduce accuracy |
| Most CoT variants at Qwen2.5 1.5B/3B | negative | descriptive result at intermediate scale; does not extrapolate to "small models never gain" |
| Most CoT variants at Qwen2.5 32B | 9/14 positive (endpoints not significant) | non-monotonic scale pattern; not a stable threshold |
| Term-first on AIME 2024 | +0.10 pp (n=256) | close to zero; the manuscript describes it as near-neutral |
| Term-first on HumanEval | +10.82 pp | the only strongly positive benchmark; used as illustrative evidence |

---

## Claim-to-data map

| Claim | Data file | Format |
|-------|-----------|--------|
| CoT often degrades on GSM8K/HumanEval, and gains on MMLU/AIME 2024 are limited | `data/fig1_task_heterogeneity_scores.csv` | CSV (15 prompts × 4 datasets × 4 runs) |
| Non-monotonic effect distribution under the scale–implementation bundle | `data/fig2_model_scale_scores.csv` | CSV (16 prompts × 5 scales × 4 runs) |
| Term-first on AIME 2024, four batches pooled, n=256 | `data/aime2024_qwen25_3b_n64_16k_scores/termfirst_repeatCDEF_aggregate_summary.csv` | CSV |
| Standard baseline on AIME 2024, n=64 | `data/aime2024_qwen25_3b_n64_16k_scores/standard_baselineB_aggregate_summary.csv` | CSV |
| 14 CoT variants on AIME 2024, n=64 each | `data/aime2024_qwen25_3b_n64_16k_scores/prompts15_aggregate_summary.csv` | CSV |
| Combined panel data (4 datasets × 5 scales) | `data/Fig2_TaskHeterogeneity_data.csv` | CSV (read by the Fig. 2 script) |

---

## Figures

| Manuscript figure | Script | Input | Output |
|-------------------|--------|-------|--------|
| Fig. 2 | `code/Fig2_TaskHeterogeneity.py` | `data/fig1_task_heterogeneity_scores.csv` + `data/Fig2_TaskHeterogeneity_data.csv` + `data/aime2024_qwen25_3b_n64_16k_scores/` | `figures/Fig2_TaskHeterogeneity.{png,jpg,tiff,svg}` |
| Fig. 3 | `code/Fig3_ScalingLaws.py` | `data/fig2_model_scale_scores.csv` | `figures/Fig3_ScalingLaws.{png,jpg,tiff,svg}` |

---

## Reproduction

```bash
cd code/
python3 Fig2_TaskHeterogeneity.py    # Fig. 2: task heterogeneity
python3 Fig3_ScalingLaws.py          # Fig. 3: distribution of scale effects
```

No GPU is required; the scripts are pure Python data processing plus matplotlib and run in about 30 seconds.

---

## Scope and caveats

- **Origin of the Term-first prompt**: the Term-first prompt used here is `What is the query? Term first, then reasoning.`, post-selected from the rephrase-first prompt family, as described in the manuscript.
- **Why AIME 2024 uses multiple samples**: n=64 (baseline) and n=256 (Term-first pooled across four batches) reduce batch-to-batch chance variation. All AIME 2024 numbers in the manuscript are reported as pooled means.
- **Claims that cannot be made**: the scripts do not and cannot produce universal statements such as "CoT always wins on task X". The experiment is descriptive, not a falsification test.
