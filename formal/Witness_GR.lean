import GoldenRule

/-!
Witness_GR.lean — H1 instantiation on real data (generated numeric literals; do not edit
by hand).

Data binding: evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv
              (Qwen2.5-3B, mean over 4 runs on each of 4 datasets)

This file instantiates three abstract theorems from GoldenRule.lean: it verifies the
hypotheses against real data and thereby derives that no golden rule exists within the
finite family evaluated in the paper. The acc table uses an exact Int scale
(accuracy in percent x 100).
-/

namespace GoldenRule.Witness

-- Prompts: the Standard baseline (index 0) plus 14 CoT variants (indices 1-14),
-- represented as the finite enumeration Fin 15. term-first is outside this table:
-- it is verified separately in Witness_ModelScale.lean (model-scale CSV: negative at
-- 1.5B, positive at 3B).
abbrev Prompt := Fin 15

-- Datasets: Fin 4
abbrev Task := Fin 4

-- Models: this table is fixed to Qwen2.5-3B, represented by the single member Fin 1
abbrev Model := Fin 1


-- Accuracy table (Qwen2.5-3B, 4 datasets x 15 prompts, mean over 4 runs, percent x 100)
def accTable (_m : Model) (t : Task) (p : Prompt) : Int :=
  match t.val, p.val with
    | 0, 0 => 8069
    | 1, 0 => 6507
    | 2, 0 => 5936
    | 3, 0 => 6113
    | 0, 1 => 7994
    | 1, 1 => 6534
    | 2, 1 => 6204
    | 3, 1 => 6356
    | 0, 2 => 7974
    | 1, 2 => 6536
    | 2, 2 => 6331
    | 3, 2 => 6402
    | 0, 3 => 7915
    | 1, 3 => 6546
    | 2, 3 => 6375
    | 3, 3 => 6220
    | 0, 4 => 7798
    | 1, 4 => 6405
    | 2, 4 => 6117
    | 3, 4 => 5945
    | 0, 5 => 7896
    | 1, 5 => 6420
    | 2, 5 => 6150
    | 3, 5 => 5732
    | 0, 6 => 7890
    | 1, 6 => 6434
    | 2, 6 => 6220
    | 3, 6 => 5824
    | 0, 7 => 7944
    | 1, 7 => 6458
    | 2, 7 => 6236
    | 3, 7 => 5900
    | 0, 8 => 7913
    | 1, 8 => 6432
    | 2, 8 => 6124
    | 3, 8 => 6022
    | 0, 9 => 7866
    | 1, 9 => 6497
    | 2, 9 => 6183
    | 3, 9 => 6296
    | 0, 10 => 7739
    | 1, 10 => 6348
    | 2, 10 => 6078
    | 3, 10 => 6052
    | 0, 11 => 7970
    | 1, 11 => 6535
    | 2, 11 => 6243
    | 3, 11 => 6250
    | 0, 12 => 7832
    | 1, 12 => 6448
    | 2, 12 => 6145
    | 3, 12 => 6418
    | 0, 13 => 7924
    | 1, 13 => 6425
    | 2, 13 => 6098
    | 3, 13 => 6250
    | 0, 14 => 7932
    | 1, 14 => 6505
    | 2, 14 => 6156
    | 3, 14 => 5961
    | _, _ => 0

-- Empty-prefix baseline = Standard
def noPromptW : Prompt := 0
def accW : Model → Task → Prompt → Int := accTable
def effW (m : Model) (t : Task) (p : Prompt) : Int := accTable m t p - accTable m t noPromptW

-- Premise A: every prompt has a cell with non-positive effect (relative to the Standard
-- baseline). Checked mechanically with decide over the finite types.
theorem premise_no_universal_enhancer :
    ∀ p : Prompt, ∃ (m : Model) (t : Task), effW m t p ≤ 0 := by
  decide

-- Premise B: for every prompt there is another prompt that is strictly better in some
-- evaluated cell.
theorem premise_no_global_optimum :
    ∀ p : Prompt, ∃ (m : Model) (t : Task) (p' : Prompt), accTable m t p' > accTable m t p := by
  decide

-- Conclusion: within the finite family evaluated in the paper there is neither a globally optimal prompt nor a universal enhancer
theorem no_golden_rule_witness :
    ¬ (∃ p : Prompt, GoldenRule.GR accTable p ∨ GoldenRule.UE accTable noPromptW p) := by
  exact GoldenRule.no_golden_rule accTable noPromptW premise_no_global_optimum premise_no_universal_enhancer

-- T3 data instantiation: Think. has a negative effect on GSM8K and a positive effect on MMLU
def pThink : Prompt := 1
def tGSM8K : Task := 0
def tMMLU : Task := 1
example : effW 0 tGSM8K pThink < 0 := by decide
example : effW 0 tMMLU pThink > 0 := by decide
theorem effect_depends_on_task_witness :
    ¬ GoldenRule.UE accTable noPromptW pThink := by
  apply GoldenRule.effect_depends_on_task accTable noPromptW (m := 0) (p := pThink) (t1 := tGSM8K) (t2 := tMMLU)
  · decide
  · decide

-- Direct conclusion: the same prompt is negative on GSM8K and positive on MMLU, so the effect increases strictly with the task
theorem effect_differs_by_task_witness :
    GoldenRule.eff accTable noPromptW 0 tGSM8K pThink < GoldenRule.eff accTable noPromptW 0 tMMLU pThink := by
  apply GoldenRule.effect_differs_by_task accTable noPromptW (m := 0) (p := pThink) (t1 := tGSM8K) (t2 := tMMLU)
  · decide
  · decide

-- T6 data instantiation: Standard and Think. reverse their order between GSM8K and MMLU
def pStandard : Prompt := 0
example : accTable 0 tGSM8K pStandard > accTable 0 tGSM8K pThink := by decide
example : accTable 0 tMMLU pThink > accTable 0 tMMLU pStandard := by decide
theorem no_global_dominance_witness :
    ¬ (∀ t : Task, t = tGSM8K ∨ t = tMMLU → GoldenRule.dominates accTable 0 t pStandard pThink) ∧
    ¬ (∀ t : Task, t = tGSM8K ∨ t = tMMLU → GoldenRule.dominates accTable 0 t pThink pStandard) := by
  have h1 : accTable 0 tGSM8K pStandard > accTable 0 tGSM8K pThink := by decide
  have h2 : accTable 0 tMMLU pThink > accTable 0 tMMLU pStandard := by decide
  exact GoldenRule.no_global_dominance accTable (m := 0) (t1 := tGSM8K) (t2 := tMMLU) (p := pStandard) (q := pThink) h1 h2

end GoldenRule.Witness
