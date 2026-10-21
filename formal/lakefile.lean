import Lake
open Lake DSL

package goldenrule where
  -- Standalone Lean 4 project: depends only on the core library shipped with Lean, not on Mathlib.

@[default_target]
lean_lib GoldenRule

@[default_target]
lean_lib Witness_GR

@[default_target]
lean_lib Instance

@[default_target]
lean_lib Witness_ModelScale

@[default_target]
lean_lib MethodologyCore

@[default_target]
lean_lib MethodologyWitness
