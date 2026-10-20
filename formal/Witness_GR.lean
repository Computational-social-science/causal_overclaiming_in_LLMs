import GoldenRule

/-!
Witness_GR.lean — H1 数据实例化（自动生成，勿手改）。

生成脚本：docs/02_theory/formal/extract_gr_witness.py
数据源  ：evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv
          （Qwen2.5-3B，4 数据集 × 4 runs 均值）

本文件实例化 GoldenRule.lean 的三个抽象定理，把"前提"用真实数据验证，
从而推出论文评测到的有限族内不存在 golden rule。acc 表为精确 Int 刻度（百分数 ×100）。
-/

namespace GoldenRule.Witness

-- 提示词：Standard 基线（index 0）+ 14 个 CoT 变体（index 1-14），
-- 用 Fin 15 表示有限枚举。term-first 不在本表范围——
-- 它在 Witness_ModelScale.lean 单独验证（fig2 CSV：1.5B 负 / 3B 正）。
abbrev Prompt := Fin 15

-- 数据集：Fin 4
abbrev Task := Fin 4

-- 模型：本表固定 Qwen2.5-3B，用 Fin 1 表示单成员
abbrev Model := Fin 1


-- 准确率表（Qwen2.5-3B，4 数据集 × 15 提示词，4-run 均值，百分数×100）
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

-- 空前缀基线 = Standard
def noPromptW : Prompt := 0
def accW : Model → Task → Prompt → Int := accTable
def effW (m : Model) (t : Task) (p : Prompt) : Int := accTable m t p - accTable m t noPromptW

-- 前提 A：每个提示词都存在非正效果格（相对 Standard 基线）
-- 由 decide 在有限类型上机械验证。
theorem premise_no_universal_enhancer :
    ∀ p : Prompt, ∃ (m : Model) (t : Task), effW m t p ≤ 0 := by
  decide

-- 前提 B：每个提示词都存在另一提示词在某评测格严格更优
theorem premise_no_global_optimum :
    ∀ p : Prompt, ∃ (m : Model) (t : Task) (p' : Prompt), accTable m t p' > accTable m t p := by
  decide

-- 结论：论文评测到的有限族内，既无全局最优提示词，也无通用增强提示词
theorem no_golden_rule_witness :
    ¬ (∃ p : Prompt, GoldenRule.GR accTable p ∨ GoldenRule.UE accTable noPromptW p) := by
  exact GoldenRule.no_golden_rule accTable noPromptW premise_no_global_optimum premise_no_universal_enhancer

-- T3 数据实例化：Think. 在 GSM8K 负效应，在 MMLU 正效应
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

-- 直接结论：同一提示词在 GSM8K 负效应、MMLU 正效应 ⇒ 效应值随任务严格上升
theorem effect_differs_by_task_witness :
    GoldenRule.eff accTable noPromptW 0 tGSM8K pThink < GoldenRule.eff accTable noPromptW 0 tMMLU pThink := by
  apply GoldenRule.effect_differs_by_task accTable noPromptW (m := 0) (p := pThink) (t1 := tGSM8K) (t2 := tMMLU)
  · decide
  · decide

-- T6 数据实例化：Standard 与 Think. 在 GSM8K/MMLU 上序关系翻转
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
