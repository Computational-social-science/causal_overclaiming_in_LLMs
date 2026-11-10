import GoldenRule

/-!
Witness_GR.lean — H1 instance over the eight evaluated settings of Figures 2–3 (generated file; see README.md for provenance).

The configuration index contains the four Qwen2.5-3B benchmarks and the
four additional GSM8K scales. The shared GSM8K/3B configuration appears once.
The generic theorem's Task argument indexes these eight observed settings.
-/

namespace GoldenRule.Witness

-- 15 prompts plus the separate Standard baseline.
abbrev Prompt := Fin 16

-- Setting order: GSM8K, MMLU, HumanEval, AIME2024, 0.5B, 1.5B, 7B, 32B
abbrev Task := Fin 8
abbrev Model := Fin 1

-- Source accuracy in units of 10^(-15) percent.

def accTable (_m : Model) (t : Task) (p : Prompt) : Int :=
  match t.val, p.val with
    | 0, 0 => 80687500000000000
    | 1, 0 => 65072500000000000
    | 2, 0 => 61132500000000000
    | 3, 0 => 5989583333333334
    | 4, 0 => 19865000000000000
    | 5, 0 => 57182500000000000
    | 6, 0 => 80707500000000000
    | 7, 0 => 88817500000000000
    | 0, 1 => 79945000000000000
    | 1, 1 => 65337500000000000
    | 2, 1 => 63565000000000000
    | 3, 1 => 6094062500000000
    | 4, 1 => 20072500000000000
    | 5, 1 => 56935000000000000
    | 6, 1 => 81217500000000000
    | 7, 1 => 88360000000000000
    | 0, 2 => 79740000000000000
    | 1, 2 => 65365000000000000
    | 2, 2 => 64022500000000000
    | 3, 2 => 5833750000000000
    | 4, 2 => 19920000000000000
    | 5, 2 => 56995000000000000
    | 6, 2 => 80687500000000000
    | 7, 2 => 89365000000000000
    | 0, 3 => 79150000000000000
    | 1, 3 => 65465000000000000
    | 2, 3 => 62195000000000000
    | 3, 3 => 5520312500000000
    | 4, 3 => 20867500000000000
    | 5, 3 => 56500000000000000
    | 6, 3 => 80327500000000000
    | 7, 3 => 88762500000000000
    | 0, 4 => 77977500000000000
    | 1, 4 => 64047500000000000
    | 2, 4 => 59452500000000000
    | 3, 4 => 5885156250000000
    | 4, 4 => 20165000000000000
    | 5, 4 => 56577500000000000
    | 6, 4 => 79642500000000000
    | 7, 4 => 87757500000000000
    | 0, 5 => 78962500000000000
    | 1, 5 => 64205000000000000
    | 2, 5 => 57320000000000000
    | 3, 5 => 5728593750000000
    | 4, 5 => 20812500000000000
    | 5, 5 => 56842500000000000
    | 6, 5 => 79985000000000000
    | 7, 5 => 87470000000000000
    | 0, 6 => 78902500000000000
    | 1, 6 => 64340000000000000
    | 2, 6 => 58235000000000000
    | 3, 6 => 5989843750000000
    | 4, 6 => 20432500000000000
    | 5, 6 => 56425000000000000
    | 6, 6 => 80857500000000000
    | 7, 6 => 88967500000000000
    | 0, 7 => 79435000000000000
    | 1, 7 => 64582500000000000
    | 2, 7 => 58997500000000000
    | 3, 7 => 6249375000000000
    | 4, 7 => 19655000000000000
    | 5, 7 => 57505000000000000
    | 6, 7 => 80457500000000000
    | 7, 7 => 89217500000000000
    | 0, 8 => 79130000000000000
    | 1, 8 => 64317500000000000
    | 2, 8 => 60217500000000000
    | 3, 8 => 6145937500000000
    | 4, 8 => 19807500000000000
    | 5, 8 => 57185000000000000
    | 6, 8 => 80060000000000000
    | 7, 8 => 89762500000000000
    | 0, 9 => 78657500000000000
    | 1, 9 => 64967500000000000
    | 2, 9 => 62957500000000000
    | 3, 9 => 6146406250000000
    | 4, 9 => 20432500000000000
    | 5, 9 => 56332500000000000
    | 6, 9 => 81650000000000000
    | 7, 9 => 91075000000000000
    | 0, 10 => 77387500000000000
    | 1, 10 => 63475000000000000
    | 2, 10 => 60520000000000000
    | 3, 10 => 5676875000000000
    | 4, 10 => 20470000000000000
    | 5, 10 => 56995000000000000
    | 6, 10 => 80042500000000000
    | 7, 10 => 88230000000000000
    | 0, 11 => 79700000000000000
    | 1, 11 => 65350000000000000
    | 2, 11 => 62500000000000000
    | 3, 11 => 6718281250000000
    | 4, 11 => 19750000000000000
    | 5, 11 => 56615000000000000
    | 6, 11 => 81992500000000000
    | 7, 11 => 90107500000000000
    | 0, 12 => 78317500000000000
    | 1, 12 => 64480000000000000
    | 2, 12 => 64175000000000000
    | 3, 12 => 5468750000000000
    | 4, 12 => 20642500000000000
    | 5, 12 => 56387500000000000
    | 6, 12 => 80137500000000000
    | 7, 12 => 88855000000000000
    | 0, 13 => 79245000000000000
    | 1, 13 => 64252500000000000
    | 2, 13 => 62502500000000000
    | 3, 13 => 6406562500000000
    | 4, 13 => 20072500000000000
    | 5, 13 => 56957500000000000
    | 6, 13 => 80932500000000000
    | 7, 13 => 91867500000000000
    | 0, 14 => 79320000000000000
    | 1, 14 => 65047500000000000
    | 2, 14 => 59607500000000000
    | 3, 14 => 5937812500000000
    | 4, 14 => 19582500000000000
    | 5, 14 => 55950000000000000
    | 6, 14 => 81387500000000000
    | 7, 14 => 90315000000000000
    | 0, 15 => 84362500000000000
    | 1, 15 => 67039035087719300
    | 2, 15 => 71950000000000000
    | 3, 15 => 6093906250000000
    | 4, 15 => 36805000000000000
    | 5, 15 => 49087500000000000
    | 6, 15 => 90437500000000000
    | 7, 15 => 94472500000000000
    | _, _ => 0

-- Empty-prefix baseline = Standard
def noPromptW : Prompt := 0
def accW : Model → Task → Prompt → Int := accTable
def effW (m : Model) (t : Task) (p : Prompt) : Int := accTable m t p - accTable m t noPromptW

-- Premise A: every prompt has a non-positive-effect cell relative to the Standard baseline
-- Mechanically verified by decide over the finite types.
theorem premise_no_universal_enhancer :
    ∀ p : Prompt, ∃ (m : Model) (t : Task), effW m t p ≤ 0 := by
  decide

-- Premise B: for every prompt there is another prompt that is strictly better in some cell
theorem premise_no_global_optimum :
    ∀ p : Prompt, ∃ (m : Model) (t : Task) (p' : Prompt), accTable m t p' > accTable m t p := by
  decide

-- Conclusion: within the finite family evaluated in the paper there is neither a globally optimal nor a universal-enhancer prompt
theorem no_golden_rule_witness :
    ¬ (∃ p : Prompt, GoldenRule.GR accTable p ∨ GoldenRule.UE accTable noPromptW p) := by
  exact GoldenRule.no_golden_rule accTable noPromptW premise_no_global_optimum premise_no_universal_enhancer

-- Instantiation of Theorem 3: "Think." has a negative effect on GSM8K and a positive effect on MMLU
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

-- Direct conclusion: negative on GSM8K and positive on MMLU, so the effect increases strictly with the task
theorem effect_differs_by_task_witness :
    GoldenRule.eff accTable noPromptW 0 tGSM8K pThink < GoldenRule.eff accTable noPromptW 0 tMMLU pThink := by
  apply GoldenRule.effect_differs_by_task accTable noPromptW (m := 0) (p := pThink) (t1 := tGSM8K) (t2 := tMMLU)
  · decide
  · decide

-- Instantiation of Theorem 6 (dominance): Standard and "Think." reverse their order across GSM8K/MMLU
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
