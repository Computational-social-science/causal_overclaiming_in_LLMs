/-!
GoldenRule.lean — machine-checked proof that no prompt is a golden rule (final version).

Design note:
  * Model / Task / Prompt are abstract type parameters, corresponding to the finite family
    actually evaluated in the paper.
  * acc : Model → Task → Prompt → Int is accuracy, encoded as an integer at a scale of
    percent x 100.
  * noPrompt : Prompt is the empty-prefix baseline (called "Standard" in the data).
  * eff is the effect relative to the empty-prefix baseline.
  * UE (universal enhancer): the prompt improves accuracy strictly in every evaluated cell
    relative to the empty-prefix baseline.
  * GR (global optimum, strong form of a golden rule): the prompt is nowhere worse than
    any candidate prompt in any evaluated cell.

Core claim (the single proposition proved in this file):
  In the LLM setting, prompt performance depends on the dataset, the downstream task and
  the model: there is no golden rule.

Formal coverage:
  - H1a direct refutation: no globally optimal prompt (T1), no universal enhancer (T2),
    combined statement (T5).
  - H1b direction of dependence (positive form): effect depends on the task (T3), effect
    depends on the model (T4); a single counterexample cell refutes UE/GR (T7/T8).
  - H1c order relation: a two-prompt order reversal implies no global dominance (T6).
  - H2 reflection markers: monotonicity of a surface metric is refuted by a real
    counterexample (T9/T10).
  - Mechanism layer (descriptive framework): the prompt prefix as initialization of the
    hidden state (Mediation), and the two-stage decomposition of term-first (TermFirst).

All theorems are parameterized: acc and noPrompt are explicit parameters, so the statements
can be given at the abstract level (pure theory) or instantiated with real data tables (see
Witness_GR, Witness_ModelScale and Instance). The proofs are purely constructive (assume the
negation and instantiate the contradiction) and do not rely on probability or statistics.
-/

namespace GoldenRule

/- Model space: abstract type (the set of models evaluated in the paper). -/
variable {Model : Type}

/- Downstream tasks and datasets: abstract type (the set of datasets evaluated in the paper). -/
variable {Task : Type}

/- Prompts: abstract type (the family of prompts evaluated in the paper). -/
variable {Prompt : Type}

/-- Effect: the accuracy difference relative to the empty-prefix baseline (noPrompt). By definition it is Acc(p) − Acc(ε). -/
def eff (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    (m : Model) (t : Task) (p : Prompt) : Int :=
  acc m t p - acc m t noPrompt

/-- Universal enhancer prompt: relative to the empty-prefix baseline, it strictly improves
    accuracy in every evaluated cell. -/
def UE (acc : Model → Task → Prompt → Int) (noPrompt : Prompt) (p : Prompt) : Prop :=
  ∀ (m : Model) (t : Task), eff acc noPrompt m t p > 0

/-- Globally optimal prompt (strong form of a golden rule): in every evaluated cell it is
    nowhere worse than any candidate prompt. -/
def GR (acc : Model → Task → Prompt → Int) (p : Prompt) : Prop :=
  ∀ (m : Model) (t : Task) (p' : Prompt), acc m t p ≥ acc m t p'

/--
Theorem 1 (no globally optimal prompt): if for every prompt p there is a prompt p' and an
evaluated cell (m,t) with acc(m,t,p') > acc(m,t,p), then no globally optimal prompt exists.

Proof: suppose a globally optimal p* exists. By the definition of GR it is nowhere worse
than any p', that is, acc(m,t,p*) ≥ acc(m,t,p') for all p'. But the hypothesis gives a cell
in which some p' is strictly better, a contradiction.
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
Theorem 2 (no universal enhancer): if for every prompt p there is an evaluated cell (m,t)
with eff(m,t,p) ≤ 0, then no universal enhancer exists.

Proof: suppose a UE prompt p* exists. By the definition of UE, eff > 0 in every cell. But
the hypothesis gives a cell with eff ≤ 0, a contradiction.
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
Theorem 3 (effect depends on the task): if, for a fixed model m and prompt p, there are two
datasets t1, t2 with eff(m,t1,p) < 0 < eff(m,t2,p), then p is not a universal enhancer.

This formalizes the part of the core claim that says prompt performance depends on the
dataset: with the same prompt and the same model, changing only the dataset can reverse the
sign of the effect.

Note: the proof uses only the negative-effect hypothesis (eff(t1) < 0 already violates the
"strictly positive in every cell" condition of UE); `_h2` (the positive-effect hypothesis)
is kept to preserve the shape of an effect reversal, matching the data instantiation
(Think. is negative on GSM8K and positive on MMLU), and to make the theorem state a
"direction reversal" rather than merely "a counterexample cell exists".
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
Theorem 4 (effect depends on the model): if, for a fixed dataset t and prompt p, there are
two models m1, m2 with eff(m1,t,p) < 0 < eff(m2,t,p), then p is not a universal enhancer.

This formalizes the part of the core claim that says prompt performance depends on the
model: with the same prompt and the same dataset, changing only the model can reverse the
sign of the effect.

Note: as above, the proof uses only the negative-effect hypothesis; `_h2` preserves the
shape of an effect reversal to match the data instantiation (term-first is negative at 1.5B
and positive at 3B).
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
Theorem 3' (the direction of the effect depends on the task, direct corollary): if, for a
fixed model m and prompt p, there are two datasets t1, t2 with
eff(m,t1,p) < 0 < eff(m,t2,p), then eff(m,t1,p) < eff(m,t2,p).

This is the direct formalization of "prompt effects depend on the dataset": same prompt,
same model, only the dataset changes and the effect strictly increases (from negative to
positive). The direction change is a conclusion, not a hypothesis.
-/
theorem effect_differs_by_task
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {m : Model} {p : Prompt} {t1 t2 : Task}
    (h1 : eff acc noPrompt m t1 p < 0) (h2 : eff acc noPrompt m t2 p > 0) :
    eff acc noPrompt m t1 p < eff acc noPrompt m t2 p := by
  exact Int.lt_trans h1 h2  -- h1: e1<0, h2: 0<e2 ⇒ e1<0<e2 ⇒ e1<e2

/--
Theorem 4' (the direction of the effect depends on the model, direct corollary): if, for a
fixed dataset t and prompt p, there are two models m1, m2 with
eff(m1,t,p) < 0 < eff(m2,t,p), then eff(m1,t,p) < eff(m2,t,p).

This is the direct formalization of "prompt effects depend on the model": same prompt, same
dataset, only the model changes and the effect strictly increases (from negative to
positive). The direction change is a conclusion, not a hypothesis.
-/
theorem effect_differs_by_model
    (acc : Model → Task → Prompt → Int) (noPrompt : Prompt)
    {t : Task} {p : Prompt} {m1 m2 : Model}
    (h1 : eff acc noPrompt m1 t p < 0) (h2 : eff acc noPrompt m2 t p > 0) :
    eff acc noPrompt m1 t p < eff acc noPrompt m2 t p := by
  exact Int.lt_trans h1 h2  -- h1: e1<0, h2: 0<e2 ⇒ e1<0<e2 ⇒ e1<e2

/--
Theorem 5 (combined statement: no golden rule): if the hypotheses of Theorems 1 and 2 hold,
then there is neither a globally optimal prompt nor a universal enhancer.

This is the direct formal conclusion of the paper's core claim: prompt performance depends
on the dataset, task and model, so there is no golden rule.
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

/-- Strict dominance: prompt p is strictly better than prompt q on task t. -/
def dominates (acc : Model → Task → Prompt → Int) (m : Model) (t : Task)
    (p q : Prompt) : Prop :=
  acc m t p > acc m t q

/--
Theorem 6 (the order between two prompts can reverse, that is, no global dominance): fix a
model m and two datasets t1, t2. If prompt p is strictly better than q on t1 and strictly
worse than q on t2, then p and q do not dominate each other on {t1, t2}: there is no prompt
that is strictly better than the other on both datasets.

This formalizes the statement that the relative ranking of two prompts depends on the
dataset.
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
Theorem 7 (a single non-positive effect is enough to refute universal enhancement): if, for
a fixed model m, task t and prompt p, there is one evaluated cell with
eff(m,t,p) ≤ 0, then p is not a universal enhancer.

This is the local form of T2: refuting a fixed p needs only one counterexample cell, without
enumerating all p. It supports the reverse side of the "effect depends" claim: one cell
suffices to refute "universal".
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
Theorem 8 (a single cell in which a better prompt wins is enough to refute global
optimality): if, for a fixed model m and task t, there is a prompt q with
acc(m,t,q) > acc(m,t,p), then p is not a globally optimal prompt.

This is the local form of T1: refuting a fixed p needs only one cell with a better prompt.
-/
theorem not_GR_of_strictly_better_prompt
    (acc : Model → Task → Prompt → Int)
    {m : Model} {t : Task} {p q : Prompt}
    (h : acc m t q > acc m t p) :
    ¬ GR acc p := by
  intro hgr
  have hge : acc m t p ≥ acc m t q := hgr m t q
  exact Int.not_lt_of_ge hge h

/-- Strictly monotone surface-metric hypothesis: a higher metric implies strictly higher accuracy. -/
def MetricMonotone {Prompt : Type} (metric acc : Prompt → Int) : Prop :=
  ∀ p p', metric p > metric p' → acc p > acc p'

/-- Weakly monotone surface-metric hypothesis: a metric that is not lower implies accuracy that is not lower. -/
def WeakMetricMonotone {Prompt : Type} (metric acc : Prompt → Int) : Prop :=
  ∀ p p', metric p ≥ metric p' → acc p ≥ acc p'

/--
Theorem 9 (any claim of strict monotonicity for a surface metric is refuted by a
counterexample): if there is a pair of prompts p1, p2 with metric(p1) > metric(p2) and
acc(p1) ≤ acc(p2), then the metric cannot be a strictly monotone predictor of accuracy.

This is the abstract layer of H2: reflection-marker frequency is such a surface metric
(metric = "wait" count, acc = accuracy), and the real data supply the counterexample pair
(see Instance.lean).
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
Theorem 10 (any claim of weak monotonicity for a surface metric is refuted by a
counterexample): if there is a pair of prompts p1, p2 with metric(p1) > metric(p2) and
acc(p1) < acc(p2), then the metric cannot be a weakly monotone predictor of accuracy.
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
# Formalizing the prompt prefix as initialization of the hidden state
(mechanism section of the manuscript)

Mechanism claim: the role of a prompt prefix is to set the initial condition of the dynamics
that the model subsequently unfolds. It does not encode the individual solution steps; it
initializes the hidden state. The core of the formalization is the identity that context
states mediate:

  If two prompts produce the same context hidden state on a given query, they produce the
  same output (first-token distribution and full-completion distribution).

The proof is identity propagation through a deterministic function (`congrArg`); it does not
rely on probability or measure theory. This is a formalization of a descriptive framework: it
gives precise meaning, in an autoregressive Transformer, to "prompt effects must propagate
through the hidden state", but it does not claim that a different initial state necessarily
leads to a different correct answer.
-/
namespace Mediation

/--
Theorem M1 (identity mediated by the context state): if two prompts p1, p2 produce the same
context hidden state on a query q, then any decoding operator dec that takes a hidden state
as input yields the same output.

This formalizes "a prompt's effect on subsequent computation must propagate through the
initial state": the same initial state implies the same subsequent output. The converse does
not necessarily hold (different hidden states can be mapped to the same output by the same
decoding operator).
-/
theorem mediation_identity
    {Prompt Query Hidden Output : Type} (enc : Prompt → Query → Hidden)
    (dec : Hidden → Output) (p1 p2 : Prompt) (q : Query) :
    enc p1 q = enc p2 q → dec (enc p1 q) = dec (enc p2 q) := by
  intro h
  exact congrArg dec h

/--
Corollary M2/M3 (mediation identity for the first-token distribution and for the layer-wise
trajectory): the first-token distribution Head_θ and the layer-wise trajectory
f = Layer ∘ ... ∘ Layer are both deterministic functions of the hidden state, hence they are
instances of M1 under a particular decoding operator (the proof term is the same as M1, with
dec replaced by head / f). Two named instances are listed here so that the manuscript can
refer to them by meaning.
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
# Formalizing the two-stage decomposition of term-first
(mechanism section of the manuscript)

Mechanism claim: a term-first prompt separates the generation of the problem structure from
the generation of the final answer, and is therefore decomposable. The key insight of the
formalization is that this decomposition is not an unconditional identity; it follows from a
"mediation sufficiency" condition.

  Law of total probability (hypothesis):
    M(A|Q,p) = Σ_S M(A|Q,S,p) · M(S|Q,p)
  Mediation sufficiency (hypothesis):
    ∀ Q S, M(A|Q,S,p) = M(A|Q,S)     (given the structure S, the answer distribution no
                                      longer depends on the prefix p)
  Conclusion:
    M(A|Q,p) = Σ_S M(A|Q,S) · M(S|Q,p)

Proof: substitute mediation sufficiency into the summands of the law of total probability.
Probability functions are represented by Rat (the core library has no reals) and the finite
segment set by a List.
-/
namespace TermFirst

/--
Theorem TF1 (two-stage decomposition of term-first): given the law of total probability and
the mediation sufficiency condition, the answer distribution decomposes into "structure
generation" times "answer distribution given the structure".

- Hypothesis h_total: M(A|Q,p) = Σ_S M(A|Q,S,p)·M(S|Q,p) (law of total probability)
- Hypothesis h_med : ∀ S ∈ segs, M(A|Q,S,p) = M(A|Q,S) (mediation sufficiency)
- Conclusion        : M(A|Q,p) = Σ_S M(A|Q,S)·M(S|Q,p)

Proof: rewrite with h_total, then replace the summands one by one using
List.map_eq_map_iff.
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
  -- Replace term by term: for every s ∈ segs, probGiven q p s = probPlain q s
  -- Use List.map_eq_map_iff to show the two maps are equal, then congrArg to sum
  apply congrArg List.sum
  rw [List.map_eq_map_iff]
  intro s hs
  rw [h_med s hs]

end TermFirst
