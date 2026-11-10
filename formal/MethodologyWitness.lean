import MethodologyCore

/-!
MethodologyWitness.lean — data instantiation of the non-monotonicity of surface metrics
(two same-batch counterexamples: peak-layer non-function and model-scale sequence).

Data binding: the integer literals below are transcribed from the files named per item; do
not edit them by hand.

  1. Peak-layer non-function counterexample (manuscript Theorem 2 / not_function_of):
     underthinking and normal-thinking have the same peak-layer distribution (L26 count 10
     for both), yet the 15-question accuracies differ: 1330/100 vs 2670/100. The peak layer
     therefore cannot determine accuracy deterministically.
     Data source: evidence/03-logit-lens/data/logit_lens_1.5b_full.json
  2. Model-scale sequence counterexample (manuscript Theorem 3 / not_monotone_sequence):
     the term-first gain Δ = +1694, -810, +368 (x100, 0.5B to 3B) first falls and then rises
     (1.5B is the trough). The four runs are averaged, then the difference is rounded half
     away from zero and encoded.
     Data source: evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
     (see Witness_ModelScale.lean for the data conventions)
-/

namespace MethodologyWitness

-- ========================================================================
-- 1. Peak-layer non-function counterexample (manuscript Theorem 2 / MethodologyCore.not_function_of)
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

-- Apply Theorem 2: the peak layer cannot determine accuracy deterministically
theorem not_function_of_peaklayer :
    ¬ ∃ f : Int → Int, ∀ c : Cond, peakAcc c = f (peakMetric c) :=
  MethodologyCore.not_function_of peakMetric peakAcc
    (e1 := 0) (e2 := 1) (by decide) (by decide)

-- ========================================================================
-- 2. Model-scale sequence counterexample (manuscript Theorem 3 / MethodologyCore.not_monotone_sequence)
--    While the index (scale) increases monotonically, the gain first falls and then rises, so
--    the gain sequence is not monotone.
-- ========================================================================

-- Scale index: 0 = 0.5B, 1 = 1.5B, 2 = 3B (μ_N strictly increasing)
abbrev ScaleIdx := Fin 3

-- Scale ordering in half-billions (0.5B, 1.5B, 3B), shown strictly increasing
def scaleInHalfBillions (i : ScaleIdx) : Nat :=
  match i.val with
  | 0 => 1
  | 1 => 3
  | _ => 6
example : scaleInHalfBillions 0 < scaleInHalfBillions 1 ∧
    scaleInHalfBillions 1 < scaleInHalfBillions 2 := by decide

-- term-first gain Δ (percent x 100): +1694, -810, +368
def deltaSeq (i : ScaleIdx) : Int :=
  match i.val with
  | 0 => 1694
  | 1 => -810
  | _ => 368

-- First falls, then rises (1.5B is the trough)
example : deltaSeq 0 > deltaSeq 1 := by decide
example : deltaSeq 1 < deltaSeq 2 := by decide

-- Apply Theorem 3: the gain sequence is neither non-decreasing nor non-increasing
theorem not_monotone_scale :
    ¬ (∀ i j : Fin 3, i ≤ j → deltaSeq i ≤ deltaSeq j) ∧
    ¬ (∀ i j : Fin 3, i ≤ j → deltaSeq i ≥ deltaSeq j) :=
  MethodologyCore.not_monotone_sequence deltaSeq (by decide) (by decide)

end MethodologyWitness
