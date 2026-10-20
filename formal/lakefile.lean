import Lake
open Lake DSL

package goldenrule where
  -- 独立 LEAN4 项目：只依赖 Lean 发行版自带核心库，不依赖 Mathlib

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
