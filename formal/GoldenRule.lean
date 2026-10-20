/-!
GoldenRule.lean — 提示词"无 golden rule"的严格形式化证明（最终版）。

Design note (see FINAL_DESIGN.md, FORMAL_LEAN4.md):
  * Model / Task / Prompt 是抽象类型参数，对应"论文实际评测到的有限族"。
  * acc : Model → Task → Prompt → Int 是准确率（百分数 ×100 的整数刻度）。
  * noPrompt : Prompt 是空前缀基线（论文数据中即 "Standard"）。
  * eff 是相对空前缀基线的效应。
  * UE（通用增强）: 该提示词相对空前缀基线，在每一个评测格都严格提升。
  * GR（全局最优 / golden rule 强形式）: 该提示词在每一个评测格都不比任何候选差。

核心主张（本文件证明的唯一命题）：
  **在 LLM 领域，prompt 的性能依赖数据集、下游任务、模型 —— 没有 golden rule。**

形式化覆盖：
  - H1a 直接否定：无全局最优提示词（T1）、无通用增强提示词（T2）、总命题（T5）。
  - H1b 依赖方向（正面形式）：效应依赖任务（T3）、效应依赖模型（T4）、
    单格反例即可否定 UE/GR（T7/T8）。
  - H1c 序关系：双提示词序翻转 ⇒ 无全局支配（T6）。
  - H2 反思标记：表面指标单调性被真实反例击穿（T9/T10）。
  - 机制层（描述性框架）：提示前缀作为隐藏状态初始化（Mediation）、
    term-first 两阶段分解（TermFirst）。

所有定理参数化：acc 与 noPrompt 作为显式参数，可在抽象层陈述（纯理论），
也可用真实数据表实例化（见 Witness_GR / Witness_ModelScale / Instance）。
证明是"反设 + 实例化矛盾"的纯构造，不依赖概率或统计。

References:
  * docs/02_theory/FORMAL_PROOF.md（数学记号）
  * docs/02_theory/formal/FINAL_DESIGN.md（最终版设计）
  * docs/02_theory/formal/FORMAL_LEAN4.md（LEAN4 设计）
-/

namespace GoldenRule

/- 模型参数空间：抽象类型（论文评测到的模型集合）。 -/
variable {Model : Type}

/- 下游任务/数据集：抽象类型（论文评测到的数据集集合）。 -/
variable {Task : Type}

/- 提示词：抽象类型（论文评测到的提示词族）。 -/
variable {Prompt : Type}

/-- 效应：相对空前缀基线 (noPrompt) 的准确率差。定义即为 Acc(p) − Acc(ε)。 -/
def eff (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    (m : Model) (t : Task) (p : Prompt) : Int :=
  acc m t p - acc m t noPrompt

/-- 通用增强提示词（Universal Enhancer）：
    相对空前缀基线，在每一个评测格都严格提升准确率。 -/
def UE (acc : Model → Task → Prompt → Int) (noPrompt : Prompt) (p : Prompt) : Prop :=
  ∀ (m : Model) (t : Task), eff acc noPrompt m t p > 0

/-- 全局最优提示词（Golden Rule 的强形式）：
    在每一个评测格都不比任何候选提示词差。 -/
def GR (acc : Model → Task → Prompt → Int) (p : Prompt) : Prop :=
  ∀ (m : Model) (t : Task) (p' : Prompt), acc m t p ≥ acc m t p'

/--
定理 1（无全局最优提示词）：若每个提示词 p 都存在提示词 p' 与评测格 (m,t)
使得 acc(m,t,p') > acc(m,t,p)，则不存在全局最优提示词。

证明：反设存在全局最优 p*。由 GR 定义，它在所有格都不比任何 p' 差，
即 ∀ p', acc(m,t,p*) ≥ acc(m,t,p')。但前提给出某格中 p' 严格更优，
矛盾。
-/
theorem no_global_optimum
    (acc : Model → Task → Prompt → Int)
    (h : ∀ p : Prompt, ∃ (m : Model) (t : Task) (p' : Prompt), acc m t p' > acc m t p) :
    ¬ ∃ p : Prompt, GR acc p := by
  rintro ⟨pstar, hgr⟩
  obtain ⟨m, t, p', hgt⟩ := h pstar
  have hge : acc m t pstar ≥ acc m t p' := hgr m t p'
  exact (Int.not_lt_of_ge hge) hgt

/--
定理 2（无通用增强提示词）：若每个提示词 p 都存在评测格 (m,t)
使得 eff(m,t,p) ≤ 0，则不存在通用增强提示词。

证明：反设存在 UE 提示词 p*。由 UE 定义，∀ 格, eff > 0。
但前提给出某格 eff ≤ 0，矛盾。
-/
theorem no_universal_enhancer
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    (h : ∀ p : Prompt, ∃ (m : Model) (t : Task), eff acc noPrompt m t p ≤ 0) :
    ¬ ∃ p : Prompt, UE acc noPrompt p := by
  rintro ⟨pstar, hue⟩
  obtain ⟨m, t, hle⟩ := h pstar
  have hgt : eff acc noPrompt m t pstar > 0 := hue m t
  exact (Int.not_lt_of_ge hle) hgt

/--
定理 3（效应依赖任务）：若固定模型 m、提示词 p，存在两个数据集 t1, t2
使 eff(m,t1,p) < 0 < eff(m,t2,p)，则 p 不是通用增强提示词。

这直接形式化核心主张的"prompt 性能依赖数据集"：
同一提示词、同一模型，仅更换数据集，效应方向即可反转。

注：证明仅用负效应前提（eff(t1)<0 即违反 UE 的"所有格严格正"）；
`_h2`（正效应前提）保持"效应翻转"的前提形状，以匹配数据实例化
（Think. 在 GSM8K 负、MMLU 正），并使定理声称的是"方向反转"而非
仅"存在反例格"。
-/
theorem effect_depends_on_task
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {m : Model} {p : Prompt} {t1 t2 : Task}
    (h1 : eff acc noPrompt m t1 p < 0) (_h2 : eff acc noPrompt m t2 p > 0) :
    ¬ UE acc noPrompt p := by
  intro hue
  have hpos : eff acc noPrompt m t1 p > 0 := hue m t1
  exact (Int.not_lt_of_ge (Int.le_of_lt h1)) hpos

/--
定理 4（效应依赖模型）：若固定数据集 t、提示词 p，存在两个模型 m1, m2
使 eff(m1,t,p) < 0 < eff(m2,t,p)，则 p 不是通用增强提示词。

这直接形式化核心主张的"prompt 性能依赖模型"：
同一提示词、同一数据集，仅更换模型，效应方向即可反转。

注：同上，证明仅用负效应前提；`_h2` 保持"效应翻转"形状以匹配
数据实例化（term-first 在 1.5B 负、3B 正）。
-/
theorem effect_depends_on_model
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {t : Task} {p : Prompt} {m1 m2 : Model}
    (h1 : eff acc noPrompt m1 t p < 0) (_h2 : eff acc noPrompt m2 t p > 0) :
    ¬ UE acc noPrompt p := by
  intro hue
  have hpos : eff acc noPrompt m1 t p > 0 := hue m1 t
  exact (Int.not_lt_of_ge (Int.le_of_lt h1)) hpos

/--
定理 3'（效应方向依赖任务——直接结论）：若固定模型 m、提示词 p，
存在两个数据集 t1, t2 使 eff(m,t1,p) < 0 < eff(m,t2,p)，
则 eff(m,t1,p) < eff(m,t2,p)。

这是"prompt 效应依赖数据集"的直接形式化：同一提示词、同一模型，
仅更换数据集，效应值严格上升（从负到正）。方向变化是**结论**而非前提。
-/
theorem effect_differs_by_task
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {m : Model} {p : Prompt} {t1 t2 : Task}
    (h1 : eff acc noPrompt m t1 p < 0) (h2 : eff acc noPrompt m t2 p > 0) :
    eff acc noPrompt m t1 p < eff acc noPrompt m t2 p := by
  exact Int.lt_trans h1 h2  -- h1: e1<0, h2: 0<e2 ⇒ e1<0<e2 ⇒ e1<e2

/--
定理 4'（效应方向依赖模型——直接结论）：若固定数据集 t、提示词 p，
存在两个模型 m1, m2 使 eff(m1,t,p) < 0 < eff(m2,t,p)，
则 eff(m1,t,p) < eff(m2,t,p)。

这是"prompt 效应依赖模型"的直接形式化：同一提示词、同一数据集，
仅更换模型，效应值严格上升（从负到正）。方向变化是**结论**而非前提。
-/
theorem effect_differs_by_model
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {t : Task} {p : Prompt} {m1 m2 : Model}
    (h1 : eff acc noPrompt m1 t p < 0) (h2 : eff acc noPrompt m2 t p > 0) :
    eff acc noPrompt m1 t p < eff acc noPrompt m2 t p := by
  exact Int.lt_trans h1 h2  -- h1: e1<0, h2: 0<e2 ⇒ e1<0<e2 ⇒ e1<e2

/--
定理 5（无 golden rule 总命题）：若满足定理 1 与定理 2 的前提，
则既不存在全局最优提示词，也不存在通用增强提示词。

这是论文核心主张的直接形式化结论：
  "prompt 性能依赖数据集/任务/模型，没有 golden rule"
的"没有 golden rule"部分。
-/
theorem no_golden_rule
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    (h1 : ∀ p : Prompt, ∃ (m : Model) (t : Task) (p' : Prompt), acc m t p' > acc m t p)
    (h2 : ∀ p : Prompt, ∃ (m : Model) (t : Task), eff acc noPrompt m t p ≤ 0) :
    ¬ (∃ p : Prompt, GR acc p ∨ UE acc noPrompt p) := by
  rintro ⟨p, hp⟩
  cases hp with
  | inl hgr => exact (no_global_optimum acc h1) ⟨p, hgr⟩
  | inr hue => exact (no_universal_enhancer acc noPrompt h2) ⟨p, hue⟩

/-- 严格支配（Dominance）：提示词 p 在任务 t 上严格优于提示词 q。 -/
def dominates (acc : Model → Task → Prompt → Int) (m : Model) (t : Task)
    (p q : Prompt) : Prop :=
  acc m t p > acc m t q

/--
定理 6（双提示词序关系可翻转 / 无全局支配）：固定模型 m 与两个数据集 t1, t2，
若提示词 p 在 t1 上严格优于 q、在 t2 上严格劣于 q，则 p, q 在 {t1, t2} 上
互不支配（即不存在一个提示词在两个数据集上都严格优于另一个）。

对应 FORMAL_PROOF.md §2.5：提示词的相对优劣本身依赖数据集。
-/
theorem no_global_dominance
    (acc : Model → Task → Prompt → Int)
    {m : Model} {t1 t2 : Task} {p q : Prompt}
    (h1 : dominates acc m t1 p q)
    (h2 : dominates acc m t2 q p) :
    ¬ (∀ t : Task, t = t1 ∨ t = t2 → dominates acc m t p q) ∧
    ¬ (∀ t : Task, t = t1 ∨ t = t2 → dominates acc m t q p) := by
  constructor
  · intro hp
    have hq2 := hp t2 (Or.inr rfl)
    exact (Int.not_lt_of_ge (Int.le_of_lt h2)) hq2
  · intro hq
    have hp1 := hq t1 (Or.inl rfl)
    exact (Int.not_lt_of_ge (Int.le_of_lt h1)) hp1

/--
定理 7（单格非正效应足以否定通用增强）：若固定模型 m、任务 t、提示词 p，
存在一个评测格使 eff(m,t,p) ≤ 0，则 p 不是通用增强提示词。

这是 T2 的局部形式：否定一个固定 p 只需一个反例格，无需穷举所有 p。
支撑"效应依赖"主张的反面：单格即可推翻"通用"。
-/
theorem not_UE_of_nonpositive_effect
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {m : Model} {t : Task} {p : Prompt}
    (h : eff acc noPrompt m t p ≤ 0) :
    ¬ UE acc noPrompt p := by
  intro hue
  have hgt : eff acc noPrompt m t p > 0 := hue m t
  exact Int.not_lt_of_ge h hgt

/--
定理 8（单格被更优提示词击败足以否定全局最优）：若固定模型 m、任务 t，
存在提示词 q 使 acc(m,t,q) > acc(m,t,p)，则 p 不是全局最优提示词。

这是 T1 的局部形式：否定一个固定 p 只需一个更优格。
-/
theorem not_GR_of_strictly_better_prompt
    (acc : Model → Task → Prompt → Int)
    {m : Model} {t : Task} {p q : Prompt}
    (h : acc m t q > acc m t p) :
    ¬ GR acc p := by
  intro hgr
  have hge : acc m t p ≥ acc m t q := hgr m t q
  exact Int.not_lt_of_ge hge h

/-- 严格单调表面指标假设：指标高 ⇒ 准确率严格高。 -/
def MetricMonotone {Prompt : Type} (metric acc : Prompt → Int) : Prop :=
  ∀ p p', metric p > metric p' → acc p > acc p'

/-- 弱单调表面指标假设：指标不低 ⇒ 准确率不低。 -/
def WeakMetricMonotone {Prompt : Type} (metric acc : Prompt → Int) : Prop :=
  ∀ p p', metric p ≥ metric p' → acc p ≥ acc p'

/--
定理 9（任何表面指标的严格单调均被反例击穿）：若存在提示词对 p1, p2
使 metric(p1) > metric(p2) 且 acc(p1) ≤ acc(p2)，则该指标不可能是
严格单调的准确率预测器。

H2 的抽象层：反思标记频率是这样一个表面指标（metric = Wait 频次，
acc = 准确率），真实数据提供反例对（见 Instance.lean）。
-/
theorem no_universal_metric
    {Prompt : Type} (metric acc : Prompt → Int) {p1 p2 : Prompt}
    (hmetric : metric p1 > metric p2)
    (hacc : acc p1 ≤ acc p2) :
    ¬ MetricMonotone metric acc := by
  intro h
  have hm := h p1 p2 hmetric
  exact Int.not_lt_of_ge hacc hm

/--
定理 10（任何表面指标的弱单调也被反例击穿）：若存在提示词对 p1, p2
使 metric(p1) > metric(p2) 且 acc(p1) < acc(p2)，则该指标不可能是
弱单调的准确率预测器。
-/
theorem no_universal_weak_metric
    {Prompt : Type} (metric acc : Prompt → Int) {p1 p2 : Prompt}
    (hmetric : metric p1 > metric p2)
    (hacc : acc p1 < acc p2) :
    ¬ WeakMetricMonotone metric acc := by
  intro h
  have hge : acc p2 ≤ acc p1 := h p1 p2 (Int.le_of_lt hmetric)
  exact Int.not_lt_of_ge hge hacc

end GoldenRule

/-!
# 提示前缀作为隐藏状态初始化的形式化（FORMAL_PROOF.md §3.1）

机制声称：提示前缀的作用是设定模型后续展开的动力学初始条件——它不编码
具体解题步骤，而是初始化隐藏状态。形式化的核心是"上下文状态中介同一性"：

  若两个提示词在给定查询上产生相同的上下文隐藏状态，则它们产生相同的
  输出（首 token 分布与完整补全分布）。

证明是确定性函数的同一性传播（`congrArg`），不依赖概率或测度论。
这是描述性框架的形式化：说明"提示词效果必须经由隐藏状态传播"在自回归
Transformer 中具有严格含义，但不声称"初始状态不同必然导致正确答案不同"。
-/
namespace Mediation

/--
定理 M1（上下文状态中介同一性）：若两个提示词 p1, p2 在查询 q 上产生
相同的上下文隐藏状态，则任何以隐藏状态为输入的解码算子 dec 都给出相同输出。

这形式化了"提示词对后续计算的影响必须经由初始状态传播"：
相同初始状态 ⇒ 相同后续输出。反方向并不必然成立（不同隐藏状态也可能
被同一解码算子映射到相同输出）。
-/
theorem mediation_identity
    {Prompt Query Hidden Output : Type} (enc : Prompt → Query → Hidden)
    (dec : Hidden → Output) (p1 p2 : Prompt) (q : Query) :
    enc p1 q = enc p2 q → dec (enc p1 q) = dec (enc p2 q) := by
  intro h
  exact congrArg dec h

/--
推论 M2/M3（首 token 分布与逐层轨迹的中介同一性）：
首 token 分布 Head_θ 和逐层轨迹 f = Layer∘…∘Layer 都是隐藏状态的确定性
函数，因此它们是 M1 在特定解码算子下的特例（证明体与 M1 相同，仅换
dec 为 head / f）。这里列出两个命名实例，便于论文按语义引用。
-/
theorem mediation_identity_first_token
    {Prompt Query Hidden Output : Type} (enc : Prompt → Query → Hidden)
    (head : Hidden → Output) (p1 p2 : Prompt) (q : Query) :
    enc p1 q = enc p2 q → head (enc p1 q) = head (enc p2 q) :=
  mediation_identity enc head p1 p2 q

theorem mediation_identity_trajectory
    {Prompt Query Hidden Output : Type} (enc : Prompt → Query → Hidden)
    (f : Hidden → Output) (p1 p2 : Prompt) (q : Query) :
    enc p1 q = enc p2 q → f (enc p1 q) = f (enc p2 q) :=
  mediation_identity enc f p1 p2 q

end Mediation

/-!
# term-first 两阶段分解的形式化（FORMAL_PROOF.md §3.2）

机制声称：term-first 提示词把"问题结构"生成与"最终答案"生成分开，因而可分解。
形式化的关键洞察：**这个分解不是无条件恒等式，而是由"中介充分性"条件推出**。

  全概率公式（前提）：
    M(A|Q,p) = Σ_S M(A|Q,S,p) · M(S|Q,p)
  中介充分性（前提）：
    ∀ Q S, M(A|Q,S,p) = M(A|Q,S)     （给定结构 S 后，答案分布不再依赖前缀 p）
  结论：
    M(A|Q,p) = Σ_S M(A|Q,S) · M(S|Q,p)

证明：把中介充分性代入全概率公式的求和项。概率函数用 Rat 表示
（核心库无实数），有限段集合用 List 表示。
-/
namespace TermFirst

/--
定理 TF1（term-first 两阶段分解）：给定全概率公式与中介充分性条件，
则答案分布可分解为"结构生成 × 给定结构的答案分布"。

- 前提 h_total：M(A|Q,p) = Σ_S M(A|Q,S,p)·M(S|Q,p)（全概率公式）
- 前提 h_med ：∀ S∈segs, M(A|Q,S,p) = M(A|Q,S)（中介充分性）
- 结论      ：M(A|Q,p) = Σ_S M(A|Q,S)·M(S|Q,p)

证明：rw 展开 h_total 后，用 List.map_eq_map_iff 逐项替换求和项。
-/
theorem two_stage_decomposition
    {Query Prompt Seg : Type} (segs : List Seg)
    (probAnswer : Query → Prompt → Rat)
    (probStruct : Query → Prompt → Seg → Rat)
    (probGiven  : Query → Prompt → Seg → Rat)
    (probPlain  : Query → Seg → Rat)
    {q : Query} {p : Prompt}
    (h_total : probAnswer q p = (segs.map (fun s => probGiven q p s * probStruct q p s)).sum)
    (h_med : ∀ s ∈ segs, probGiven q p s = probPlain q s) :
    probAnswer q p = (segs.map (fun s => probPlain q s * probStruct q p s)).sum := by
  rw [h_total]
  -- 逐项替换：对任意 s∈segs，probGiven q p s = probPlain q s
  -- 用 List.map_eq_map_iff 证明两侧的 map 相等，再 congrArg 到 sum
  apply congrArg List.sum
  rw [List.map_eq_map_iff]
  intro s hs
  rw [h_med s hs]

end TermFirst
