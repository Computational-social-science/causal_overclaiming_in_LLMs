# Lean 4 formalization

Machine-checked formalization of the manuscript claim that no prompt is a golden rule.
The Lean 4 sources turn the mathematical notation used in the manuscript into definitions
and theorems that the proof checker verifies.

## Files

| File | Contents | Provenance |
|---|---|---|
| `GoldenRule.lean` | **H1 abstract theorems**: no global optimum, no universal enhancer, effect depends on task and model, combined statement. Purely constructive proofs, valid for arbitrary `acc` and `noPrompt` | hand-written |
| `Witness_GR.lean` | **H1 instantiation on real data**: the Qwen2.5-3B scores of the task-heterogeneity table are encoded as `accTable`; the premises are checked with `decide`, and `effect_depends_on_task_witness` / `no_global_dominance_witness` are instantiated | `evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv` |
| `Instance.lean` | **H2 counterexample**: the implication from reflection-marker frequency to accuracy is falsified by real data (`¬ H_marker`, including the theory-layer T9/T10 bridge) | `evidence/02-state-divergence/data/reflection_1p5b_real.json` |
| `Witness_ModelScale.lean` | **Model-dependence instantiation**: term-first has a negative effect at 1.5B and a positive effect at 3B on GSM8K (model-scale data) | `evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv` |
| `MethodologyCore.lean` | **Abstract methodology lemmas**: a measure-type-agnostic layer for the non-monotonicity of surface metrics (M.2 same value, different quality; M.3 non-monotone sequence) | hand-written |
| `MethodologyWitness.lean` | **Data instantiation of the methodology lemmas**: three counterexamples (the peak layer is not a function, the model-scale sequence, generation length) | `evidence/03-logit-lens/data/logit_lens_1.5b_full.json`, `evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv`, `evidence/02-state-divergence/data/selected_controlled_case.json` |
| `lakefile.lean`, `lean-toolchain` | Lean 4 project configuration (Lean 4.31.0, no Mathlib) | hand-written |

This is the final version of the formalization.

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

## Verification principles

- **The proofs do not read data files.** Data enter through exact `Int` literals
  (accuracies in percent x 100) encoded in the instantiation files, which rules out
  transcription errors in the proof input.
- **The witnesses are self-contained.** Each instantiation file records its data source and
  the integer literals copied from it; if the data change, the literals and the build have
  to be updated together.
- **Finite-domain boundary.** `Model` / `Task` / `Prompt` are `Fin` enumerations, so the
  proofs cover the finite family actually evaluated in the paper. They do not claim that a
  golden rule is absent for arbitrary future models.
- **No Mathlib dependency.** Only the core library shipped with Lean 4.31.0 is used, which
  avoids pulling in several hundred MB of dependencies.

## Reproducibility chain (claim to data to Lean)

```
manuscript claim: prompt performance depends on dataset, task and model, so no golden rule
  └─ formal/GoldenRule.lean              (abstract theorems: H1 core + H2 metric + mechanism layer)
       ├─ formal/Witness_GR.lean        (instantiation, data = task-heterogeneity CSV)
       │    └─ evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv
       ├─ formal/Witness_ModelScale.lean (instantiation, data = model-scale CSV; 3B from group48)
       │    └─ evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
       └─ formal/Instance.lean          (H2 counterexample, data = reflection JSON)
            └─ evidence/02-state-divergence/data/reflection_1p5b_real.json
```

Note: the 1.5B and 3B effects in `Witness_ModelScale.lean` both use re-run values
(2026-08-06):

- 1.5B: -8.09 pp (-809/100, re-run value, mean pass@1 over four generations, seeds 44-47, vLLM)
- 3B: +3.67 pp (+367/100, independent group48 data, mean pass@1 over four generations)
- 0.5B / 7B / 32B: mean over four runs from the model-scale CSV.
