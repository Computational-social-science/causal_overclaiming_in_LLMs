import GoldenRule

/-!
H2 witness: a prompt with HIGHER reflection-marker frequency scores LOWER-or-equal
accuracy, which falsifies the monotone claim that higher frequency implies higher accuracy.

Data binding: evidence/02-state-divergence/data/reflection_1p5b_real.json
  (DeepSeek-R1-Distill-Qwen-1.5B, AIME 2024, n=64; reflection frequency and accuracy
   columns exactly as plotted in Figure 4). Integer literals at scale 100; do not edit by
   hand.

  Hi-freq prompt : Step by step, let's work through this.
    reflection freq = 4339   accuracy = 2172
  Lo-freq prompt : Think.
    reflection freq = 4200   accuracy = 2333

  4339 > 4200   but   2172 ≤ 2333
-/

-- DeepSeek-R1-Distill-Qwen-1.5B, AIME 2024 (n=64)  — see header comment above
def m0 : String := "DeepSeek-R1-Distill-Qwen-1.5B"
def d0 : String := "AIME2024"

-- Separate namespace: H2 uses String for the prompt and model identifiers, and its freq/acc
-- definitions differ in type from H1's GoldenRule.Witness (Fin types + accTable), so merging
-- them would conflict. The H2 counterexample therefore keeps its own namespace Witness.
namespace Witness

-- Reflection-marker frequency and accuracy, as measured. Unit: markers per response
-- (count of reflection-marker occurrences per generated response). Values are stored at
-- scale 100 (43.39 markers per response is stored as 4339) so that Int is exact.
def freqHi : Int := 4339
def accHi  : Int := 2172
def freqLo : Int := 4200
def accLo  : Int := 2333

-- Concrete prompts with their measured (freq, acc).  freq/acc are indexed by
-- (model, dataset, prompt); the counterexample below lives in the measured cell.
def hiPrompt := "Step by step, let's work through this."
def loPrompt := "Think."
def freq (_m _d : String) (p : String) : Int := if p = hiPrompt then freqHi else if p = loPrompt then freqLo else 0
def acc  (_m _d : String) (p : String) : Int := if p = hiPrompt then accHi else if p = loPrompt then accLo else 0

-- The counterexample hypothesis being rejected (cf. the H2 statement in the manuscript):
--   reflection frequency monotonically predicts accuracy.
def H_marker : Prop :=
  ∀ p p', freq m0 d0 p > freq m0 d0 p' → acc m0 d0 p > acc m0 d0 p'

-- 1. The measured inequality (verified by decide — kernel evaluation):
example : freqHi > freqLo := by decide
example : accHi ≤ accLo := by decide
example : accHi < accLo := by decide

-- 2. The concrete counterexample (DeepSeek-R1-Distill-Qwen-1.5B, AIME 2024):
--    a prompt with HIGHER reflection frequency scores LOWER accuracy.
--    This falsifies the monotone claim that higher frequency implies higher accuracy.
theorem not_H_marker : ¬ H_marker := by
  intro h
  have hgt : freq m0 d0 hiPrompt > freq m0 d0 loPrompt := by decide
  have hle : acc m0 d0 hiPrompt ≤ acc m0 d0 loPrompt := by decide
  have hm := h hiPrompt loPrompt hgt
  exact Int.not_lt_of_ge hle hm

-- 3. WEAK monotone claim: even non-strict monotonicity is falsified.
--    A strict frequency increase paired with a strict accuracy decrease is also a
--    counterexample to "freq ≥ freq' implies acc ≥ acc'".
def H_marker_weak : Prop :=
  ∀ p p', freq m0 d0 p ≥ freq m0 d0 p' → acc m0 d0 p ≥ acc m0 d0 p'

theorem not_H_marker_weak : ¬ H_marker_weak := by
  intro h
  have hgt : freq m0 d0 hiPrompt > freq m0 d0 loPrompt := by decide
  have hge : acc m0 d0 loPrompt ≤ acc m0 d0 hiPrompt := h hiPrompt loPrompt (Int.le_of_lt hgt)
  exact Int.not_lt_of_ge hge (by decide : acc m0 d0 hiPrompt < acc m0 d0 loPrompt)

-- 4. The same concrete pair instantiates the theory-layer metric lemmas
--    (T9/T10 in GoldenRule.lean): the reflection frequency is a surface
--    metric whose monotonicity is falsified by real data.
theorem not_H_marker_via_generic :
    ¬ GoldenRule.MetricMonotone (freq m0 d0) (acc m0 d0) := by
  apply GoldenRule.no_universal_metric (metric := freq m0 d0) (acc := acc m0 d0)
    (p1 := hiPrompt) (p2 := loPrompt)
  · decide
  · decide

theorem not_H_marker_weak_via_generic :
    ¬ GoldenRule.WeakMetricMonotone (freq m0 d0) (acc m0 d0) := by
  apply GoldenRule.no_universal_weak_metric (metric := freq m0 d0) (acc := acc m0 d0)
    (p1 := hiPrompt) (p2 := loPrompt)
  · decide
  · decide

end Witness
