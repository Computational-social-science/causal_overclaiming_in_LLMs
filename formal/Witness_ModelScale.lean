import GoldenRule

/-!
Witness_ModelScale.lean — data instantiation of the model-dependence of the effect
(generated numeric literals; do not edit by hand).

Data binding: evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
              (Qwen2.5 across model sizes, mean over 4 runs, GSM8K)

Encoding convention: the effect is the difference between the four-run means, rounded
half away from zero to two decimals and multiplied by 100, so exact Int literals are
used for every scale.

Instantiation of GoldenRule.effect_depends_on_model:
  term-first has effect -810/100 (negative) on Qwen2.5-1.5B and effect 368/100 (positive) on
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
      | 0 => -810   -- 1.5B: Δ = -8.10 pp (negative)
      | _ => 368  -- 3B: Δ = 3.68 pp (positive)
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
