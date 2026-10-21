import GoldenRule
import MethodologyCore

/-!
MethodologyWitness.lean — data instantiation of the non-monotonicity of surface metrics
(two strict same-batch counterexamples and one cross-batch counterexample).

Data binding: the integer literals below are transcribed from the files named per item; do
not edit them by hand.

  1. Peak-layer non-function counterexample (Theorem 11 / not_function_of):
     premature convergence (PC) and delayed commitment (DC) have the same peak-layer
     distribution (L26 count 10 for both), yet the 15-question accuracies differ:
     PC 1330/100 vs DC 2670/100. The peak layer therefore cannot determine accuracy
     deterministically.
     Data source: evidence/03-logit-lens/data/logit_lens_1.5b_full.json
  2. Model-scale sequence counterexample (Theorem 12 / not_monotone_sequence):
     the term-first gain Δ = +1694, -809, +367 (x100, 0.5B to 3B) first falls and then rises
     (1.5B is the trough).
     Data source: evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
     (3B uses the group48 value 367; see Witness_ModelScale.lean for the data conventions)
  3. Generation-length counterexample (Theorem 9 / no_universal_metric, a cross-batch
     auxiliary observation):
     PO length 70956 > DC length 8667 (single controlled case, AIME 2024-II-4), yet the
     15-question accuracies are PO 1330/100 < DC 2670/100.
     Lengths are taken from evidence/02-state-divergence/data/selected_controlled_case.json;
     accuracies from logit_lens_1.5b_full.json. This is a cross-batch pairing (see the
     limitations discussed in the manuscript), so it is a direction-consistent auxiliary
     observation only, not load-bearing evidence.
-/

namespace MethodologyWitness

-- ========================================================================
-- 1. Peak-layer non-function counterexample (Theorem 11 / MethodologyCore.not_function_of)
--    The peak-layer distribution is the same but the accuracy differs, so the metric cannot
--    determine accuracy.
-- ========================================================================

-- Condition identifiers: 0 = PC (premature convergence), 1 = DC (delayed commitment)
abbrev Cond := Fin 2

-- Peak-layer metric: L26 count (10 for both PC and DC, so the peak-layer distribution is the same)
def peakMetric (_c : Cond) : Int := 10

-- Accuracy (percent x 100): PC = 1330, DC = 2670
def peakAcc (c : Cond) : Int := if c = 0 then 1330 else 2670

-- Same metric value, different quality
example : peakMetric 0 = peakMetric 1 := by decide
example : peakAcc 0 ≠ peakAcc 1 := by decide

-- Apply Theorem 11: the peak layer cannot determine accuracy deterministically
theorem not_function_of_peaklayer :
    ¬ ∃ f : Int → Int, ∀ c : Cond, peakAcc c = f (peakMetric c) :=
  MethodologyCore.not_function_of peakMetric peakAcc
    (e1 := 0) (e2 := 1) (by decide) (by decide)

-- ========================================================================
-- 2. Model-scale sequence counterexample (Theorem 12 / MethodologyCore.not_monotone_sequence)
--    While the index (scale) increases monotonically, the gain first falls and then rises, so
--    the gain sequence is not monotone.
-- ========================================================================

-- Scale index: 0 = 0.5B, 1 = 1.5B, 2 = 3B (μ_N strictly increasing)
abbrev ScaleIdx := Fin 3

-- term-first gain Δ (percent x 100): +1694, -809, +367
def deltaSeq (i : ScaleIdx) : Int :=
  match i.val with
  | 0 => 1694
  | 1 => -809
  | _ => 367

-- First falls, then rises (1.5B is the trough)
example : deltaSeq 0 > deltaSeq 1 := by decide
example : deltaSeq 1 < deltaSeq 2 := by decide

-- Apply Theorem 12: the gain sequence is neither non-decreasing nor non-increasing
theorem not_monotone_scale :
    ¬ (∀ i j : Fin 3, i ≤ j → deltaSeq i ≤ deltaSeq j) ∧
    ¬ (∀ i j : Fin 3, i ≤ j → deltaSeq i ≥ deltaSeq j) :=
  MethodologyCore.not_monotone_sequence deltaSeq (by decide) (by decide)

-- ========================================================================
-- 3. Generation-length counterexample (Theorem 9 / GoldenRule.no_universal_metric,
--    a cross-batch auxiliary observation)
--    A longer length but a lower accuracy, so generation length is not a strictly monotone
--    metric of accuracy.
-- ========================================================================

-- Conditions: 0 = PO (persistent oscillation), 1 = DC (delayed commitment)
abbrev LenCond := Fin 2

-- Generation length: PO 70956 > DC 8667 (single controlled case, AIME 2024-II-4)
def lenMetric (c : LenCond) : Int := if c = 0 then 70956 else 8667

-- Accuracy (percent x 100, 15-question extension): PO 1330, DC 2670
def lenAcc (c : LenCond) : Int := if c = 0 then 1330 else 2670

-- Longer length but lower accuracy
example : lenMetric 0 > lenMetric 1 := by decide
example : lenAcc 0 < lenAcc 1 := by decide

-- Apply Theorem 9: generation length is not a strictly monotone metric of accuracy (cross-batch auxiliary observation)
theorem not_monotone_length :
    ¬ GoldenRule.MetricMonotone lenMetric lenAcc :=
  GoldenRule.no_universal_metric lenMetric lenAcc
    (p1 := 0) (p2 := 1) (by decide) (by decide)

end MethodologyWitness
