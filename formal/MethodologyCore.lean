/-!
MethodologyCore.lean — core abstract lemmas on the non-monotonicity of surface metrics used
as proxies for answer quality (measure-type-agnostic layer).

The file provides two abstract lemmas that are independent of the concrete measure type:

  * not_function_of (Theorem M2): the same metric value corresponds to different accuracies,
    so the metric is not a deterministic function of accuracy (it is not a function proxy).
    This formalizes the paper's observation that premature convergence (PC) and delayed
    commitment (DC) have the same peak-layer distribution (10/15 at L26 and 5/15 at L27 for
    both), yet their 15-question accuracies differ (13.3% vs 26.7%).
  * not_monotone_sequence (Theorem M3): an ordered sequence of evaluated cells that first
    falls and then rises contains an order reversal, so the sequence is neither non-increasing
    nor non-decreasing.
    This formalizes the model-scale counterexample: the term-first gain Δ =
    [+1694, -809, +367, +973, +566] (percent x 100, 0.5B to 32B) first falls and then rises
    as scale increases (1.5B is the trough, matching the re-run value -8.09 pp; see
    deltaTable in Witness_ModelScale.lean).

Relation to GoldenRule.no_universal_metric (Theorem 9):
  GoldenRule.no_universal_metric already is a measure-type-agnostic meta-theorem: it takes
  metric and acc as type parameters and refutes strict monotonicity with a counterexample
  pair. This file adds two neighbouring propositions: the same metric value can stand for
  different quality (no function proxy), and a sequence can be non-monotone.
-/

namespace MethodologyCore

/--
Theorem M2 (same value, different quality, so no function proxy): if there is a pair of
evaluated points e1, e2 with metric(e1) = metric(e2) and acc(e1) ≠ acc(e2), then there is no
function f : Int → Int with acc e = f (metric e) for all e. In other words, the value of a
surface metric cannot determine accuracy, so the metric is not a sufficient function of
accuracy (a deterministic proxy is refuted).
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
Theorem M3 (the sequence is not monotone): let a be a sequence of accuracies or effects over
three ordered evaluated points (whose corresponding measure-type index μ is monotone, for
example increasing model scale). If the order reverses (a 0 > a 1 and a 1 < a 2, so the middle
point is a trough), then the sequence a is neither non-increasing nor non-decreasing, and μ
cannot serve as a globally monotone predictor of a.
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
