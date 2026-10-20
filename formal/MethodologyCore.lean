/-!
MethodologyCore.lean — 方法论核心抽象引理：
表面指标作为回答质量代理的非单调性（测度类型无关层）。

本文件提供两个与具体测度类型无关的抽象引理：

  * not_function_of        （定理 M2）：同一指标值对应不同准确率
                            ⇒ 指标不是准确率的确定性函数（非函数代理）。
                            —— 形式化论文 P1-7 观测：过早收敛与延迟承诺的
                            峰值层分布（均为 10/15 在 L26、5/15 在 L27）相同，
                            但 15 题准确率 13.3% ≠ 26.7%。
  * not_monotone_sequence  （定理 M3）：有序评测格序列上存在"先降后升"的
                            序反转 ⇒ 序列既非单调不减也非单调不增。
                            —— 形式化模型规模反例：term-first 增益 Δ =
                            [+1694, −809, +367, +973, +566]（百分数×100，
                            0.5B→32B），在规模递增时先降后升（1.5B 为谷，
                            对应重跑真值 -8.09 pp，见 Witness_ModelScale.lean
                            line 38-44）。

与 GoldenRule.no_universal_metric（定理 9）的关系：
  GoldenRule.no_universal_metric 以 metric/acc 为类型参数，已经是
  "测度类型无关的元定理"（指标严格单调被反例对击穿）。本文件补充两个
  相邻命题：指标同值不同质（非函数代理）与序列非单调。

References:
  * docs/02_theory/METHODOLOGY_PROOF.md（完整证明）
  * docs/02_theory/STRICT_PROOF.md §8（定理 9/10）
  * docs/02_theory/formal/GoldenRule.lean（MetricMonotone / no_universal_metric）
-/

namespace MethodologyCore

/--
定理 M2（同值不同质 ⇒ 非函数代理）：若存在评测点对 e1, e2 使
metric(e1) = metric(e2) 且 acc(e1) ≠ acc(e2)，则不存在函数 f : Int → Int
使得 ∀ e, acc e = f (metric e)。即：表面指标值不能确定性地决定准确率，
指标不是准确率的充分函数（确定性代理被否定）。
-/
theorem not_function_of
    {E : Type} (metric acc : E → Int) {e1 e2 : E}
    (hmetric : metric e1 = metric e2)
    (hacc : acc e1 ≠ acc e2) :
    ¬ ∃ f : Int → Int, ∀ e : E, acc e = f (metric e) := by
  intro hf
  rcases hf with ⟨f, hfe⟩
  have h1 : acc e1 = f (metric e1) := hfe e1
  have h2 : acc e2 = f (metric e2) := hfe e2
  have hsame : f (metric e1) = f (metric e2) := by
    rw [hmetric]
  have hacc_eq : acc e1 = acc e2 := by
    rw [h1, hsame, ← h2]
  exact hacc hacc_eq

/--
定理 M3（序列非单调）：设 a 是三个有序评测点上的准确率/效应序列
（对应的测度类型指标 μ 单调，如模型规模递增）。若存在序反转
（a 0 > a 1 且 a 1 < a 2，即中间点是谷），则序列 a 既非单调不减也非
单调不增，因而 μ 不能作为 a 的全局单调预测指标。
-/
theorem not_monotone_sequence
    (a : Fin 3 → Int)
    (hdec : a 0 > a 1)
    (hinc : a 1 < a 2) :
    ¬ (∀ i j : Fin 3, i ≤ j → a i ≤ a j) ∧
    ¬ (∀ i j : Fin 3, i ≤ j → a i ≥ a j) := by
  constructor
  · intro hmono
    have h01 : a 0 ≤ a 1 := hmono 0 1 (by decide)
    exact Int.not_lt_of_ge h01 hdec
  · intro hanti
    have h12 : a 1 ≥ a 2 := hanti 1 2 (by decide)
    exact Int.not_lt_of_ge h12 hinc

end MethodologyCore
