# LEAN4 形式化证明

论文"提示词无 golden rule"主张的机械验证。用 LEAN4 定理证明器把
`docs/02_theory/FORMAL_PROOF.md` 的数学记号变成可编译验证的形式。

## 文件结构

| 文件 | 内容 | 生成方式 |
|---|---|---|
| `GoldenRule.lean` | **H1 抽象定理**：无全局最优、无通用增强、效应依赖任务/模型、总命题。纯构造证明，对所有 `acc`/`noPrompt` 成立 | 手写 |
| `Witness_GR.lean` | **H1 真实数据实例化**：把 Fig1 CSV 的 Qwen2.5-3B 评测结果写成 `accTable`，用 `decide` 验证前提，并实例化 `effect_depends_on_task_witness` / `no_global_dominance_witness` | `extract_gr_witness.py` |
| `Instance.lean` | **H2 反例**：反思标记频次→准确率单调蕴涵被真实数据反例击穿（`¬ H_marker`，含理论层 T9/T10 桥接） | `extract_witness.py` |
| `Witness_ModelScale.lean` | **效应依赖模型实例化**：term-first 在 GSM8K 上 1.5B 负效应 / 3B 正效应（fig2 数据） | `extract_model_scale.py` |
| `MethodologyCore.lean` | **方法论抽象引理**（r13 新增）：表面指标非单调性的测度类型无关层（M.2 同值不同质 + M.3 序列非单调） | 手写 |
| `MethodologyWitness.lean` | **方法论数据实例化**（r13 新增）：三个反例（峰值层非函数、规模序列、生成���度） | `extract_methodology.py` |
| `FORMAL_LEAN4.md` | 设计说明 + 数学记号 ↔ LEAN4 对应 + 数据绑定 | 手写 |
| `extract_witness.py` | 从 `reflection_1p5b_real.json` 生成 `Instance.lean` | — |
| `extract_gr_witness.py` | 从 `fig1_task_heterogeneity_scores.csv` 生成 `Witness_GR.lean` | — |
| `extract_model_scale.py` | 从 `fig2_model_scale_scores.csv` 生成 `Witness_ModelScale.lean` | — |
| `extract_methodology.py` | 从 `logit_lens_1.5b_full.json` + `fig2_model_scale_scores.csv` 生成 `MethodologyWitness.lean` | — |
| `lakefile.lean` / `lean-toolchain` | LEAN4 项目配置（Lean 4.31.0，无 Mathlib） | 手写 |
| `snapshot_version.py` | 版本快照工具：把当前工作版归档到 `versions/` | 手写 |

**当前版本**：r13-final（顶层 = `versions/r13-final/` 的完整定稿）。后续不再迭代本目录；扩展请新建 r14+ 版本。

## 编译

```bash
# 前置：elan 工具链（Lean 4.31.0，见 docs/02_theory/formal/INSTALL.md）
cd docs/02_theory/formal/
lake build
```

## 版本管理（多 AI 迭代）

本项目用多个 LLM（deepseek-v4-flash、opus 等）对形式化证明做多轮反复迭代。
每一轮的产出归档到独立版本目录，便于对比、回滚和择优。

**结构**：

```
formal/
├── GoldenRule.lean / Witness_GR.lean / Instance.lean   ← 当前工作版（最新可用）
├── snapshot_version.py                                   ← 归档工具
└── versions/
    ├── VERSIONS.md                                       ← 版本登记表
    ├── r0-baseline/                                      ← 已验证基线（可独立 lake build）
    ├── r1-deepseek-v4-flash/                             ← 迭代快照（每轮×每 AI 一个目录）
    └── ...
```

**使用流程**：

```bash
# 1. 把某一轮（某 AI 的产出）同步到顶层工作版
# 2. 归档当前工作版为版本快照：
python3 snapshot_version.py r1 deepseek-v4-flash \
  --note "改进了 H2 反例，证明结构更简洁"

# 查看已有版本：
python3 snapshot_version.py --list
```

**原则**：
- **顶层 = 当前工作版**，始终保留最新可用状态；`versions/` = 历史归档，只增不改。
- **每个版本自洽**：含全部 `.lean` + 生成脚本 + lake 配置，可独立 `lake build` 验证。
- **版本命名**：`r<N>-<ai>`（轮次×AI 混合）。同轮不同 AI 产出并列，便于对比。
- **编译状态**：登记表 `❓` 表示待验证；`✅` 表示该版本快照已独立 `lake build` 通过。
- 归档时 `snapshot_version.py` 自动跳过构建产物（`.lake/`、`__pycache__/`、`*.olean`）。

## 验证原则

- **证明不读数据文件**。数据通过生成脚本以精确 `Int` 字面量（百分数 ×100）编入
  实例化文件，防止手抄错误。
- **生成器可复现**。改数据后重跑生成脚本即可更新证明输入。
- **有限域边界**。`Model`/`Task`/`Prompt` 用 `Fin` 表示有限枚举，证明覆盖"论文评测到
  的有限族内不存在 golden rule"，不声称对任意未来模型成立（见 FORMAL_PROOF.md §6）。
- **无 Mathlib 依赖**。只用 Lean 4.31.0 自带核心库，避免额外拉取数百 MB 依赖。

## 复现链路（claim → 数据 → LEAN）

```
paper/main_cn.tex
  └─ docs/02_theory/FORMAL_PROOF.md        （数学陈述）
       └─ formal/GoldenRule.lean           （抽象定理：H1 核心 + H2 指标 + 机制层）
            ├─ formal/Witness_GR.lean      （实例化，数据=fig1 CSV）
            │    └─ evidence/01-macro-heterogeneity/data/fig1_task_heterogeneity_scores.csv
            ├─ formal/Witness_ModelScale.lean （实例化，数据=fig2 CSV，3B 用 group48 真值）
            │    └─ evidence/01-macro-heterogeneity/data/fig2_model_scale_scores.csv
            └─ formal/Instance.lean        （H2 反例，数据=reflection JSON）
                 └─ evidence/02-state-divergence/data/reflection_1p5b_real.json
```

> 注：Witness_ModelScale.lean 的 1.5B / 3B 效应均使用**重跑真值**（2026-08-06）：
- 1.5B：-8.09 pp（-809/100，重跑真值，pass@4，seeds 44–47，vLLM）
- 3B：+3.67 pp（+367/100，group48 真独立数据，pass@4）
- 0.5B / 7B / 32B：fig2 CSV 4-run 均值。
