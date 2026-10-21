# Changelog

## v1.0.3 — 2026-10-22

Figure release. Code, data and formalization are unchanged from v1.0.2.

- Figure 5: panel labels a-d moved to the upper-left corner above the axes
  (set_title(loc="left")), matching the submitted figure; the previous in-axes
  ax.text(0.03, 0.92, ...) placement read as a data annotation.
- Refreshed figures/ to the final submitted exports for Figures 2-5 (PNG, JPG,
  TIFF, SVG); Figure 1 was already identical.
- No changes to data, scripts other than the Figure 5 label placement, or the
  Lean formalization.

## v1.0.2 — 2026-10-21

Figure release. Code, data and formalization are unchanged from v1.0.1.

- Figure 3 now labels every panel with the model family (Qwen2.5-0.5B, Qwen2.5-1.5B, Qwen2.5-3B,
  Qwen2.5-7B, Qwen2.5-32B), matching the figure caption and the model actually evaluated.
- JPG and TIFF exports now carry the physical resolution in their metadata, so every bitmap states
  400 dpi as required for submission.
- Figures regenerated; the PNG output is unchanged except for Figure 3.

## v1.0.1 — 2026-10-21

Documentation and figure release. The code, the data and the formalization are unchanged from v1.0.0.

- All documentation and all code comments are now in English. No Chinese text remains in the repository.
- The plotting scripts reproduce the manuscript figures exactly: a clean checkout regenerates
  `figures/Figure2_TaskHeterogeneity.*`, `Figure3_ScalingLaws.*`, `Figure4_ReflectionScatter.*` and
  `Figure5_LogitLens.*` byte for byte (PNG sha256 identical to the submitted files). Figure 2 no longer
  depends on a large backup archive; it is computed from the released per-run tables.
- Added `figures/`: the five manuscript figures in PNG, JPG, TIFF and SVG. Figure 1 is a hand-drawn
  vector diagram; its SVG source is in `evidence/00-fig1-conceptual/data/`.
- Removed the stale matplotlib renderer of an earlier Figure 1 layout, together with its icon assets.
- Removed references to internal working files that are not part of this repository, and removed tracked
  build artefacts (`tests/__pycache__`); added a `.gitignore`.
- Fixed a syntax error in `evidence/02-state-divergence/code/real_logit_lens_extractor.py` that
  prevented the module from importing.
- The raw inference archives stay attached to the v1.0.0 release; this release adds no large files.

## v1.0.0 — 2026-10-20

First unified release: code, summary data and Lean 4 formalization in a single repository.

- Merged the former code release (patterns-repro) and the laboratory data repository.
- Added the Lean 4 formalization (GoldenRule, Instance, Witness_GR, Witness_ModelScale, MethodologyCore,
  MethodologyWitness; lake build passing).
- Removed absolute local paths from data files; large raw artifacts moved to release assets.
- Summary tables (SI Tables S1-S5 and per-run accuracy tables) are in tables/.

Earlier separate deposits (patterns-repro v1.0.0 / v1.0.1) are superseded by this release.
