# Lean 4 toolchain installation

The formalization uses **Lean 4.31.0** and the `Int` / `Fin` core libraries shipped with
Lean; it does not depend on Mathlib. The steps below were verified on macOS arm64.

## 1. Install elan

```bash
brew install elan-init
elan --version
```

`elan-init` provides the `elan`, `lean` and `lake` command entries.

## 2. Install Lean 4.31.0

```bash
elan toolchain install leanprover/lean4:v4.31.0
elan default leanprover/lean4:v4.31.0
```

A mirror may be used if downloads from GitHub are slow.

## 3. Verify the formalization project

Run the build from the `formal/` directory of this repository:

```bash
lean --version    # Lean (version 4.31.0)
cd formal/
lake build        # compiles the libraries declared in lakefile.lean
```

`lake build` does not fetch Mathlib; it only needs the core library of the installed Lean
distribution.

## Notes

- The elan toolchain directory is `~/.elan/toolchains/`, with one subdirectory per version.
- If `lean --version` hangs, elan is usually waiting for a download; check
  `~/.elan/toolchains/*.lock`.
- Accuracies (in percent) and reflection-marker frequencies are represented uniformly as
  `Int` at a scale of 100. This avoids floating-point error and does not require the
  rational layer of Mathlib.
