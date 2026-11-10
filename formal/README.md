# Lean 4 formalization

Machine-checked formalization of the manuscript's methods section. The Lean 4 sources
turn the mathematical notation of the methods section into definitions and theorems that
the proof checker verifies: Definition 6 (strict and weak monotonicity of a surface
metric with respect to accuracy), Theorems 1-4, and the three finite data examples
linked to the theorems in Table 2.

This is the version aligned with the submitted manuscript: the theorems carry the same
numbering as the manuscript methods (Theorems 1-4), and the data instances use the
numbers printed in Table 2. The cross-batch generation-length row of Table 2 is marked
as auxiliary in the manuscript and is not formalized.

## Files

| File | Contents | Provenance |
|---|---|---|
| `GoldenRule.lean` | **Abstract theorems**: no global optimum, no universal enhancer, effect depends on task and model, combined statement, strict/weak order-preservation lemmas (manuscript Theorems 1 and 4), plus the mediation and term-first layer | hand-written |
| `Witness_GR.lean` | **H1 instantiation on real data**: the eight evaluated settings (four Qwen2.5-3B benchmarks and four additional GSM8K scales) are encoded as `accTable`; the premises are checked with `decide` | `evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv`, `fig2_model_scale_scores.csv`, `Fig1_BarChart_TaskHeterogeneity_AIME2024_data.csv` |
| `Instance.lean` | **Manuscript Theorems 1 and 4, data instantiation**: reflection-marker frequency and accuracy exhibit an order reversal (`¬ H_marker`, `¬ H_marker_weak`) | `evidence/02-state-divergence/data/reflection_1p5b_real.json` |
| `Witness_ModelScale.lean` | **Model-dependence instantiation**: term-first has a negative effect at 1.5B and a positive effect at 3B on GSM8K | `evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv` |
| `MethodologyCore.lean` | **Abstract methodology lemmas**: manuscript Theorem 2 (same metric value, different accuracy, so no deterministic function proxy) and Theorem 3 (three-point sequence is neither non-increasing nor non-decreasing) | hand-written |
| `MethodologyWitness.lean` | **Data instantiation of Theorems 2 and 3**: peak-layer distribution L26 = 10 for both conditions with accuracies 1330/100 vs 2670/100; term-first gain sequence +1694, -810, +368 (percent x 100) | `evidence/03-logit-lens/data/logit_lens_1.5b_full.json`, `evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv` |
| `lakefile.lean`, `lean-toolchain` | Lean 4 project configuration (Lean 4.31.0, no Mathlib) | hand-written |

## Build

Run the build from the `formal/` directory of this repository, after installing the
toolchain described in `formal/INSTALL.md`:

```bash
# requirements: elan toolchain (Lean 4.31.0, see INSTALL.md in this directory)
cd formal/
lake build
```

`lake build` compiles all six Lean libraries declared in `lakefile.lean` and does not
download Mathlib.

## Correspondence with the manuscript

| Manuscript object | Lean object | Data instance |
|---|---|---|
| Definition 6, Theorem 1 | `GoldenRule.no_universal_metric` (strict monotonicity) | `Instance.not_H_marker` |
| Definition 6, Theorem 4 | `GoldenRule.no_universal_weak_metric` (weak monotonicity) | `Instance.not_H_marker_weak` |
| Theorem 2 | `MethodologyCore.not_function_of` | `MethodologyWitness.not_function_of_peaklayer` |
| Theorem 3 | `MethodologyCore.not_monotone_sequence` | `MethodologyWitness.not_monotone_scale` |

The four theorems are conditional: each states an implication whose premise is the
observed counterexample, so the finite data enter only through the instances.

## Verification principles

- **The proofs do not read data files.** Data enter through exact `Int` literals encoded in
  the instantiation files, which rules out transcription errors in the proof input.
- **The witnesses are self-contained.** Each instantiation file records its data source and
  the integer literals copied from it; if the data change, the literals and the build have
  to be updated together.
- **Finite-domain boundary.** `Model` / `Task` / `Prompt` are `Fin` enumerations, so the
  proofs cover the finite family actually evaluated in the paper. They do not claim that a
  golden rule is absent for arbitrary future models.
- **No Mathlib dependency.** Only the core library shipped with Lean 4.31.0 is used, which
  avoids pulling in several hundred MB of dependencies.
- **Encoding.** Accuracies and reflection-marker frequencies are represented as `Int` at a
  scale of 100 (percent x 100); the H1 instance uses a common exact scale for its table.
  The model-scale effect is the difference of the four-run means, rounded half away from
  zero to two decimals and multiplied by 100, giving -810/368 for the 1.5B/3B pair shown in
  Table 2.

## Reproducibility chain (claim to data to Lean)

```
manuscript claim: prompt performance depends on dataset, task and model, so no golden rule
  +- formal/GoldenRule.lean              (abstract theorems: H1 core + strict/weak order + mediation)
       +- formal/Witness_GR.lean        (H1 instantiation, data = task-heterogeneity and model-scale CSVs)
       |    +- evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv
       |    +- evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
       +- formal/Witness_ModelScale.lean (model-dependence instantiation, data = model-scale CSV)
       |    +- evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
       +- formal/Instance.lean          (Theorems 1 and 4, data = reflection JSON)
            +- evidence/02-state-divergence/data/reflection_1p5b_real.json

manuscript methods: surface metrics are not monotone proxies of accuracy
  +- formal/MethodologyCore.lean         (Theorems 2 and 3, abstract)
       +- formal/MethodologyWitness.lean  (data instances)
            +- evidence/03-logit-lens/data/logit_lens_1.5b_full.json
            +- evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
```

Note: the 1.5B and 3B effects used in `Witness_ModelScale.lean` and `MethodologyWitness.lean`
are computed from the four-run means in `fig2_model_scale_scores.csv` with the rounding rule
above; the resulting effect sequence on GSM8K is +16.94, -8.10, +3.68 percentage points at
0.5B, 1.5B and 3B, so the 1.5B value is a trough.
