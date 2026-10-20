import GoldenRule

/-!
Witness_ModelScale.lean — 效应依赖模型的数据实例化（自动生成，勿手改）。

生成脚本：docs/02_theory/formal/extract_model_scale.py
数据源  ：evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
          （Qwen2.5 多规模 × 4 runs 均值，GSM8K）

⚠ 数据口径（2026-08-06 更新，见 evidence/01-macro-heterogeneity/notes/C类_规模实验最小重跑方案.md）：
  - fig2 中 term-first 的 0.5B/1.5B/7B/32B 已重跑为真 4 轮独立（seeds 44–47，GSM8K pass@4）。
  - 1.5B 使用重跑真值：效应 -809/100（负）。
  - 3B 使用已确认的 group48 真独立数据（84.36，即 367/100 pp vs Standard）。
  - 重跑实现备注：1.5B 用 vLLM、7B/32B 用 transformers（跨规模实现不一致）。

实例化 GoldenRule.effect_depends_on_model：
  term-first 在 Qwen2.5-1.5B 上效应 -809/100（负），
  在 Qwen2.5-3B 上效应 367/100（正）。
  同一提示词、同一数据集，效应方向依赖模型 —— 验证 FORMAL_PROOF §2.4。
-/

namespace GoldenRule.Witness

-- 两个模型：1.5B（0）与 3B（1）
abbrev Model2 := Fin 2

-- 单数据集：GSM8K
abbrev Task1 := Fin 1

-- 两个提示词：0 = term-first, 1 = Standard（基线）
abbrev Prompt1 := Fin 2

-- 效应表 deltaTable：term-first（Prompt 0）在 GSM8K 上相对 Standard 的效应 Δ。
-- Standard（noPrompt=1）锚定为 0，term-first（0）存效应值（百分数 ×100）。
-- 这样 eff(m,t,0) = deltaTable(m,t,0) - deltaTable(m,t,1) = Δ。
-- 注：本表存的是 Δ 而非原始准确率，命名用 deltaTable 与 Witness_GR 的
-- accTable（真实准确率）区分。
def deltaTable (m : Model2) (_t : Task1) (p : Prompt1) : Int :=
  if p = 0 then
    match m.val with
      | 0 => -809   -- 1.5B: Δ = -8.09 pp（负）
      | _ => 367  -- 3B: Δ = 3.67 pp（正）
  else
    0  -- Standard（基线）Δ = 0

-- 空前缀基线 = Standard
def noPrompt1 : Prompt1 := 1

-- 结论：term-first 不是通用增强提示词，且效应依赖模型
theorem effect_depends_on_model_witness :
    ¬ GoldenRule.UE deltaTable noPrompt1 0 := by
  -- 1.5B 上负效应 → 直接违反 UE 的"所有格严格正"
  apply GoldenRule.effect_depends_on_model deltaTable noPrompt1
    (m1 := 0) (m2 := 1) (t := 0) (p := 0)
  · decide  -- 1.5B: eff < 0
  · decide  -- 3B:   eff > 0

-- 直接结论：同一提示词在 1.5B 负效应、3B 正效应 ⇒ 效应值随模型严格上升
theorem effect_differs_by_model_witness :
    GoldenRule.eff deltaTable noPrompt1 0 0 0 < GoldenRule.eff deltaTable noPrompt1 1 0 0 := by
  apply GoldenRule.effect_differs_by_model deltaTable noPrompt1
    (m1 := 0) (m2 := 1) (t := 0) (p := 0)
  · decide  -- 1.5B: eff < 0
  · decide  -- 3B:   eff > 0

-- 显式展示两模型的效应符号（供审阅）
example : GoldenRule.eff deltaTable noPrompt1 0 0 0 < 0 := by decide
example : GoldenRule.eff deltaTable noPrompt1 1 0 0 > 0 := by decide

end GoldenRule.Witness
