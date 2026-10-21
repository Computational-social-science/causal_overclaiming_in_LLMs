# 02 — Prompt prefix as hidden-state initialization

This unit supports Fig. 4 (reflection-marker scatter, Spearman ρ over three models). Holding the problem and the model fixed and changing only the prefix produces three entirely different hidden-state trajectories, which is what motivates describing the prompt prefix as a state initialization.

---

## What this experiment does

Having ruled out "CoT is a universal enhancer" (experiment 1), the next question is what the prompt prefix does inside the model. This experiment uses reflection-marker frequency as a behavioural proxy and tests, on three models, whether "more reflection markers means higher accuracy" holds.

**Method**: three DeepSeek-R1-Distill models (Qwen-1.5B, Qwen-7B, Llama-8B) were run on AIME 2024. The Qwen-1.5B model has 16 prompt conditions (the Standard baseline, 14 CoT variants and Term-first); the Qwen-7B and Llama-8B models have 15 (the Standard baseline and the 14 CoT variants), because Term-first was evaluated on 1.5B only in this experiment. For every (model, prompt) pair the experiment recorded:

- the total reflection-marker count, i.e. the sum over 9 marker classes (`wait`, `however`, `hmm`, `let me`, `re-evaluate`, `reconsider`, `alternatively`, `hold on`, `let's re`)
- AIME 2024 pass@1 accuracy

**Result**: for all three models the Spearman ρ is not significantly positive and the 95% CI overlaps zero. Reflection-marker frequency is not a usable proxy for reasoning quality.

---

## Experimental setting

| Dimension | Detail |
|-----------|--------|
| Models | DeepSeek-R1-Distill-Qwen-1.5B, DeepSeek-R1-Distill-Qwen-7B, DeepSeek-R1-Distill-Llama-8B |
| Dataset | AIME 2024 (30 problems) |
| Prompts | 16 for Qwen-1.5B (Standard, 14 CoT variants, Term-first); 15 for Qwen-7B and Llama-8B (Term-first not included) |
| Samples per prompt | n=64 (Qwen-1.5B) / pooled n=15 (7B, 8B) |
| Device | Mac MPS / float16 |

---

## Key results

| Model | Spearman ρ | 95% CI | p-value | Reading |
|-------|------------|--------|---------|---------|
| DeepSeek-R1-Distill-Qwen-1.5B | close to 0 | includes 0 | n.s. | many "wait" markers do not predict high accuracy |
| DeepSeek-R1-Distill-Qwen-7B | close to 0 | includes 0 | n.s. | as above |
| DeepSeek-R1-Distill-Llama-8B | weakly positive | includes 0 | n.s. | the direction is positive but not statistically significant |

---

## Claim-to-data map

| Claim | Data file | Format |
|-------|-----------|--------|
| 1.5B model, 16 prompts × 4 runs | `data/reflection_1p5b_real.json` | JSON (16 lists) |
| 7B model, 15 prompts | `data/reflection_7b_real.json` | JSON (15 dicts) |
| 8B model, 15 prompts | `data/reflection_8b_real.json` | JSON (15 dicts) |
| Selection metadata for the controlled case | `data/selected_controlled_case.json` | JSON (single problem, AIME 2024-II-4) |
| Raw three-state Logit Lens trajectories, 32 runs | `data/logit_lens_data_1.5B_32runs.json` and `data/logit_lens_data_1.5B_32runs_all_states.json` | JSON |
| Aggregated three-state trajectories | `data/real_logit_lens_data.json` and `data/real_logit_lens_data_controlled.json` | JSON |

---

## Figures

| Manuscript figure | Script | Input | Output |
|-------------------|--------|-------|--------|
| Fig. 4 | `code/Fig4_ReflectionScatter.py` | `data/reflection_{1p5b,7b,8b}_real.json` | `figures/Fig4_ReflectionScatter.{png,jpg,tiff,svg,pdf}` |

---

## Reproduction

```bash
cd code/
python3 Fig4_ReflectionScatter.py     # Fig. 4
```

No GPU is required; the script loads JSON and plots with matplotlib in about 5 seconds.

---

## Scope and caveats

- **Single dataset**: all reflection-marker data come from AIME 2024. The marker-frequency versus accuracy analysis was not repeated on GSM8K/MMLU/HumanEval, because "reflection" is weaker outside competition mathematics.
- **Statistical power**: 3 models × 15 or 16 prompts is a small sample and the 95% CIs of the Spearman ρ are wide. The claim of "no significant positive correlation" is robust under Bonferroni correction.
- **Claims that cannot be made**: the experiment refutes the strong form of "reflection markers equal reasoning quality"; it does not refute "reflection helps under some conditions".

---

## Processing pipeline (for reference; the plotting scripts do not re-run the extraction)

The extraction scripts are kept for completeness and are not needed to regenerate the figures.

1. `code/extract_termfirst_logit_lens.py` extracts hidden states for four conditions (under-thinking, normal-thinking, over-thinking, Term-first) on the single problem.
2. `code/real_logit_lens_extractor.py` extracts three conditions (under-thinking, normal-thinking, over-thinking) over 32 runs × 29 layers.
3. `code/verify_logit_lens_data.py` checks the integrity of the JSON files.

> These scripts load the model in float16 on an MPS or CUDA device. Their outputs are included in this repository as JSON, so Figs. 4 and 5 can be regenerated without re-running the extraction.
