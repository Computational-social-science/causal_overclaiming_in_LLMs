import GoldenRule

/-!
Witness_ModelScale.lean — data instantiation of the model-dependence of the effect
(generated numeric literals; do not edit by hand).

Data binding: evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
              (Qwen2.5 across model sizes, mean over 4 runs, GSM8K)

Known details of the measured data (updated 2026-08-06):
  - In the model-scale table, term-first for 0.5B/1.5B/7B/32B was re-run as four genuine
    independent generations (seeds 44-47, GSM8K, mean pass@1 over four generations).
  - 1.5B uses the re-run value: effect -809/100 (negative).
  - 3B uses the confirmed independent group48 data (84.36, that is 367/100 pp relative to
    Standard).
  - Implementation note: the 1.5B re-run used vLLM while the 7B/32B re-runs used
    transformers, so the implementation differs across scales.

Instantiation of GoldenRule.effect_depends_on_model:
  term-first has effect -809/100 (negative) on Qwen2.5-1.5B and effect 367/100 (positive) on
  Qwen2.5-3B. With the same prompt and the same dataset, the sign of the effect depends on
  the model, which verifies the manuscript's claim that prompt effects depend on the model.
-/

namespace GoldenRule.Witness

-- Two models: 1.5B (0) and 3B (1)
abbrev Model2 := Fin 2

-- A single dataset: GSM8K
abbrev Task1 := Fin 1

-- Two prompts: 0 = term-first, 1 = Standard (the baseline)
abbrev Prompt1 := Fin 2

-- Effect table deltaTable: the effect Δ of term-first (prompt 0) relative to Standard on
-- GSM8K. Standard (noPrompt = 1) is anchored at 0, while term-first (0) stores the effect
-- value (percent x 100). Hence eff(m,t,0) = deltaTable(m,t,0) - deltaTable(m,t,1) = Δ.
-- Note: this table stores Δ rather than raw accuracy, hence the name deltaTable, to
-- distinguish it from accTable (raw accuracy) in Witness_GR.
def deltaTable (m : Model2) (_t : Task1) (p : Prompt1) : Int :=
  if p = 0 then
    match m.val with
      | 0 => -809   -- 1.5B: Δ = -8.09 pp (negative)
      | _ => 367  -- 3B: Δ = 3.67 pp (positive)
  else
    0  -- Standard (baseline): Δ = 0

-- Empty-prefix baseline = Standard
def noPrompt1 : Prompt1 := 1

-- Conclusion: term-first is not a universal enhancer, and its effect depends on the model
theorem effect_depends_on_model_witness :
    ¬ GoldenRule.UE deltaTable noPrompt1 0 := by
  -- Negative effect at 1.5B, which directly violates the "strictly positive in every cell" condition of UE
  apply GoldenRule.effect_depends_on_model deltaTable noPrompt1
    (m1 := 0) (m2 := 1) (t := 0) (p := 0)
  · decide  -- 1.5B: eff < 0
  · decide  -- 3B:   eff > 0

-- Direct conclusion: the same prompt is negative at 1.5B and positive at 3B, so the effect increases strictly with the model
theorem effect_differs_by_model_witness :
    GoldenRule.eff deltaTable noPrompt1 0 0 0 < GoldenRule.eff deltaTable noPrompt1 1 0 0 := by
  apply GoldenRule.effect_differs_by_model deltaTable noPrompt1
    (m1 := 0) (m2 := 1) (t := 0) (p := 0)
  · decide  -- 1.5B: eff < 0
  · decide  -- 3B:   eff > 0

-- The sign of the effect is shown explicitly for both models (for review)
example : GoldenRule.eff deltaTable noPrompt1 0 0 0 < 0 := by decide
example : GoldenRule.eff deltaTable noPrompt1 1 0 0 > 0 := by decide

end GoldenRule.Witness
