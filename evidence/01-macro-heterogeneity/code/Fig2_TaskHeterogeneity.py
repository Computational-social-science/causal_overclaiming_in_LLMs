
"""Figure 2: task heterogeneity of Zero-shot CoT prompt variants (four benchmarks).

Panels: GSM8K, MMLU, HumanEval and AIME 2024, evaluated on Qwen2.5-3B.
Bars show the accuracy change relative to the Standard prompt (percentage
points); error bars show the standard error of the mean (SEM).

Data sources (all inside this repository):
- tables/fig2_task_heterogeneity_scores.csv
    Per-run accuracy for GSM8K/MMLU/HumanEval, four runs per prompt.
    Mean, sample standard deviation (ddof=1) and SEM = SD / sqrt(4) are
    computed exactly as in the manuscript pipeline.
- tables/fig2_aime2024_scores.csv
    Aggregated mean and replicate standard deviation for the Term-first row
    of the GSM8K/MMLU/HumanEval panels (the per-run values are not part of
    the released tables). The standard deviation is converted to the sample
    (ddof=1) convention when the table labels it as a population SD.
- evidence/01-macro-heterogeneity/data/aime2024_qwen25_3b_n64_16k_scores/
    AIME 2024 aggregate summaries: Standard baseline B (n=64), the four
    pooled Term-first batches (n=256) and the 14 conventional prompts (n=64).

Output: figures/Figure2_TaskHeterogeneity.{png,jpg,tiff,svg}
"""

from __future__ import annotations

import csv
import sys
from dataclasses import dataclass
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

# Ensure project root is on sys.path (robust against any cwd)
sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from scripts.plot_config import setup_style, save_figure, OKABE_ITO as OI


ERROR_STD = "std"
ERROR_SEM = "sem"
ERROR_NONE = "none"
TERM_FIRST_PROMPT = "What is the query? Term first, then reasoning."
TERM_FIRST_DISPLAY_LABEL = "What is the query?\nTerm first, then reasoning."

ROOT = Path(__file__).resolve().parents[1]  # evidence/01-macro-heterogeneity/
REPO_ROOT = Path(__file__).resolve().parents[3]
FIG_DIR = REPO_ROOT / "figures"
RUN_TABLE = REPO_ROOT / "tables" / "fig2_task_heterogeneity_scores.csv"
TERM_TABLE = REPO_ROOT / "tables" / "fig2_aime2024_scores.csv"

AIME_DIR = ROOT / "data" / "aime2024_qwen25_3b_n64_16k_scores"
STANDARD_B_CSV = AIME_DIR / "standard_baselineB_aggregate_summary.csv"
TERM_REPEAT_CDEF_CSV = AIME_DIR / "termfirst_repeatCDEF_aggregate_summary.csv"
PROMPTS_CSV = AIME_DIR / "prompts15_aggregate_summary.csv"
AIME_OFFICIAL_BASELINE_MODEL = "standard_baselineB"
AIME_OFFICIAL_TERM_MODEL = "termfirst_repeatCDEF_pooled"

# ---- Style ----
setup_style({"font.size": 7, "axes.labelsize": 8, "axes.titlesize": 8,
             "xtick.labelsize": 7, "ytick.labelsize": 7, "legend.fontsize": 7})

COLORS = {
    "GSM8K": OI["orange"],
    "MMLU": OI["sky_blue"],
    "AIME2024": OI["blue"],
    "HumanEval": OI["reddish_purple"],
}

INSTRUCTIONS = [
    "Standard",
    "Think.",
    "Wait, think.",
    "Wait, wait. Think.",
    "Think step by step.",
    "Think step-by-step.",
    "Let's think step by step.",
    "Let's think step-by-step.",
    "Step by step, let's solve this.",
    "Let's address this step by step.",
    "Think this through step by step.",
    "Let's approach this step by step.",
    "Step by step, let's work through this.",
    "Let's reason through this step by step.",
    "Let's go through the process step by step.",
]

DISPLAY_INSTRUCTIONS = ["Standard", TERM_FIRST_DISPLAY_LABEL] + INSTRUCTIONS[1:]

RUNS_PER_PROMPT = 4


@dataclass
class AimeRow:
    prompt: str
    mean_accuracy: float
    sample_std_accuracy: float
    runs: int
    total_correct: int
    pass_at_64_accuracy: float


@dataclass
class TermFirstSummary:
    task: str
    mean_accuracy: float
    std_accuracy: float
    runs: int

    @property
    def sem_accuracy(self) -> float:
        return self.std_accuracy / np.sqrt(self.runs)


def read_csv_rows(path: Path) -> list[dict[str, str]]:
    with open(path, newline="") as handle:
        return list(csv.DictReader(handle))


def load_run_scores() -> dict[str, list[list[float]]]:
    """Per-run scores for GSM8K/MMLU/HumanEval, ordered as in INSTRUCTIONS."""
    rows = read_csv_rows(RUN_TABLE)
    by_prompt = {row["Instruction"]: row for row in rows}
    missing = [prompt for prompt in INSTRUCTIONS if prompt not in by_prompt]
    if missing:
        raise KeyError(f"Prompts missing from {RUN_TABLE}: {missing}")

    scores: dict[str, list[list[float]]] = {}
    for dataset in ("GSM8K", "MMLU", "HumanEval"):
        runs: list[list[float]] = []
        for run in range(1, RUNS_PER_PROMPT + 1):
            column = f"{dataset}_R{run}"
            runs.append([float(by_prompt[prompt][column]) for prompt in INSTRUCTIONS])
        scores[dataset] = runs
    return scores


def load_termfirst_summaries() -> dict[str, TermFirstSummary]:
    """Term-first aggregate mean/SD for the three non-AIME panels."""
    rows = read_csv_rows(TERM_TABLE)
    summaries: dict[str, TermFirstSummary] = {}
    for dataset in ("GSM8K", "MMLU", "HumanEval"):
        row = next(
            item
            for item in rows
            if item["dataset"] == dataset
            and item["prompt"].startswith("What is the query?")
        )
        runs = int(row["runs"])
        std = float(row["std_accuracy"])
        definition = row.get("std_definition", "")
        if "population" in definition and runs > 1:
            # Convert the population SD stored in the table to the sample
            # (ddof=1) convention used by the manuscript pipeline.
            std = std * np.sqrt(runs / (runs - 1))
        summaries[dataset] = TermFirstSummary(
            task=dataset,
            mean_accuracy=float(row["mean_accuracy"]),
            std_accuracy=std,
            runs=runs,
        )
    return summaries


def load_aime_rows() -> tuple[AimeRow, dict[str, AimeRow], list[AimeRow]]:
    standard_rows = read_csv_rows(STANDARD_B_CSV)
    term_repeat_rows = read_csv_rows(TERM_REPEAT_CDEF_CSV)

    standard = next(
        row for row in standard_rows if row["model"] == AIME_OFFICIAL_BASELINE_MODEL
    )
    termfirst = next(
        row for row in term_repeat_rows if row["model"] == AIME_OFFICIAL_TERM_MODEL
    )
    baseline = AimeRow(
        prompt="Standard",
        mean_accuracy=float(standard["mean_accuracy"]),
        sample_std_accuracy=float(standard["sample_std_accuracy"]),
        runs=int(standard["runs"]),
        total_correct=int(standard["total_correct_over_1920"]),
        pass_at_64_accuracy=float(standard["pass_at_64_accuracy"]),
    )
    termfirst_row = AimeRow(
        prompt=TERM_FIRST_PROMPT,
        mean_accuracy=float(termfirst["mean_accuracy"]),
        sample_std_accuracy=float(termfirst["sample_std_accuracy"]),
        runs=int(termfirst["runs"]),
        total_correct=int(termfirst["total_correct_over_1920"]),
        pass_at_64_accuracy=(
            float(termfirst["pass_at_64_accuracy"])
            if termfirst.get("pass_at_64_accuracy")
            else int(termfirst["total_correct_over_1920"])
            / int(termfirst["pred_count"])
            * 100
        ),
    )

    by_prompt: dict[str, AimeRow] = {TERM_FIRST_DISPLAY_LABEL: termfirst_row}
    all_rows = [baseline, termfirst_row]
    for row in read_csv_rows(PROMPTS_CSV):
        item = AimeRow(
            prompt=row["system_prompt"].strip(),
            mean_accuracy=float(row["mean_accuracy"]),
            sample_std_accuracy=float(row["sample_std_accuracy"]),
            runs=int(row["runs"]),
            total_correct=int(row["total_correct_over_1920"]),
            pass_at_64_accuracy=float(row["pass_at_64_accuracy"]),
        )
        by_prompt[item.prompt] = item
        all_rows.append(item)
    return baseline, by_prompt, all_rows


def process_dataset(
    scores_list: list[list[float]], error_mode: str
) -> tuple[np.ndarray, np.ndarray | None]:
    scores_array = np.array(scores_list, dtype=float)
    mean_scores = np.mean(scores_array, axis=0)
    std_scores = np.std(
        scores_array, axis=0, ddof=1 if scores_array.shape[0] > 1 else 0
    )
    base_score = mean_scores[0]
    delta_pp = mean_scores - base_score
    if error_mode == ERROR_STD:
        delta_err = std_scores
    elif error_mode == ERROR_SEM:
        delta_err = std_scores / np.sqrt(scores_array.shape[0])
    elif error_mode == ERROR_NONE:
        delta_err = None
    else:
        raise ValueError(f"Unknown error mode: {error_mode}")
    return delta_pp, delta_err


def process_aime_dataset(
    baseline: AimeRow, by_prompt: dict[str, AimeRow], error_mode: str
) -> tuple[np.ndarray, np.ndarray | None]:
    selected = [baseline]
    for prompt in DISPLAY_INSTRUCTIONS[1:]:
        key = prompt.strip()
        if key not in by_prompt:
            raise KeyError(f"Missing AIME prompt in aggregate CSV: {prompt!r}")
        selected.append(by_prompt[key])

    means = np.array([row.mean_accuracy for row in selected], dtype=float)
    stds = np.array([row.sample_std_accuracy for row in selected], dtype=float)
    runs = np.array([row.runs for row in selected], dtype=float)
    delta_pp = means - means[0]
    if error_mode == ERROR_STD:
        delta_err = stds
    elif error_mode == ERROR_SEM:
        delta_err = stds / np.sqrt(runs)
    elif error_mode == ERROR_NONE:
        delta_err = None
    else:
        raise ValueError(f"Unknown error mode: {error_mode}")
    return delta_pp, delta_err


def insert_termfirst(
    pc: np.ndarray,
    err: np.ndarray | None,
    scores: list[list[float]],
    term_summary: TermFirstSummary,
    error_mode: str,
) -> tuple[np.ndarray, np.ndarray | None]:
    score_array = np.array(scores, dtype=float)
    base_score = float(np.mean(score_array[:, 0]))
    term_pp = term_summary.mean_accuracy - base_score
    out_pc = np.insert(pc[1:], 0, term_pp)
    if err is None:
        return out_pc, None
    if error_mode == ERROR_STD:
        term_err = term_summary.std_accuracy
    elif error_mode == ERROR_SEM:
        term_err = term_summary.sem_accuracy
    else:
        raise ValueError(f"Unknown error mode for term-first row: {error_mode}")
    return out_pc, np.insert(err[1:], 0, term_err)


def draw_variant(error_mode: str, aime_xlim: list[float]) -> None:
    run_scores = load_run_scores()
    term_summaries = load_termfirst_summaries()
    baseline, by_prompt, _ = load_aime_rows()

    gsm8k_pc, gsm8k_err = process_dataset(run_scores["GSM8K"], error_mode)
    mmlu_pc, mmlu_err = process_dataset(run_scores["MMLU"], error_mode)
    humaneval_pc, humaneval_err = process_dataset(run_scores["HumanEval"], error_mode)
    aime_pc, aime_err = process_aime_dataset(baseline, by_prompt, error_mode)

    gsm8k_plot_pc, gsm8k_plot_err = insert_termfirst(
        gsm8k_pc, gsm8k_err, run_scores["GSM8K"], term_summaries["GSM8K"], error_mode
    )
    mmlu_plot_pc, mmlu_plot_err = insert_termfirst(
        mmlu_pc, mmlu_err, run_scores["MMLU"], term_summaries["MMLU"], error_mode
    )
    humaneval_plot_pc, humaneval_plot_err = insert_termfirst(
        humaneval_pc,
        humaneval_err,
        run_scores["HumanEval"],
        term_summaries["HumanEval"],
        error_mode,
    )

    def trim_error(err: np.ndarray | None) -> np.ndarray | None:
        return None if err is None else err[1:]

    datasets = [
        ("GSM8K", gsm8k_plot_pc, gsm8k_plot_err, COLORS["GSM8K"], [-5, 5]),
        ("MMLU", mmlu_plot_pc, mmlu_plot_err, COLORS["MMLU"], [-3, 3]),
        (
            "HumanEval",
            humaneval_plot_pc,
            humaneval_plot_err,
            COLORS["HumanEval"],
            [-6, 12],
        ),
        ("AIME 2024", aime_pc[1:], trim_error(aime_err), COLORS["AIME2024"], aime_xlim),
    ]

    fig, axes = plt.subplots(
        1,
        4,
        figsize=(7.4, 4.25),
        gridspec_kw={"width_ratios": [1, 1, 1, 1], "wspace": 0.22},
    )
    y_pos = np.arange(len(DISPLAY_INSTRUCTIONS[1:]))[::-1]

    for i, (name, pc, err, color, xlim) in enumerate(datasets):
        ax = axes[i]
        ax.barh(y_pos, pc, color=color, height=0.7, edgecolor="none", alpha=0.9)
        if err is not None:
            valid = ~(np.isnan(pc) | np.isnan(err))
            ax.errorbar(
                pc[valid],
                y_pos[valid],
                xerr=err[valid],
                fmt="none",
                color=OI["gray"],
                alpha=0.7,
                linewidth=0.5,
                capsize=1.5,
            )
        ax.axvline(x=0, color="black", linestyle="-", linewidth=0.5)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_visible(False)
        ax.spines["bottom"].set_linewidth(0.5)
        ax.xaxis.set_tick_params(width=0.5)
        ax.yaxis.set_visible(False)

        ax.set_title(name, fontsize=8, fontweight="bold", pad=10, color=color)
        ax.set_xlabel(r"$\Delta$ACC (%)", fontsize=7)
        ax.set_xlim(xlim)

        if i == 0:
            ax.set_yticks(y_pos)
            ax.set_yticklabels(DISPLAY_INSTRUCTIONS[1:], fontsize=7, ha="right")
            ax.yaxis.set_visible(True)
            ax.yaxis.set_tick_params(width=0)

        ax.grid(axis="x", linestyle="--", alpha=0.3, linewidth=0.3)

    save_figure(
        fig,
        "Figure2_TaskHeterogeneity",
        FIG_DIR,
        formats=["png", "jpg", "tiff", "svg"],
    )


def draw() -> None:
    # Default SEM variant, matching the manuscript Figure 2 caption
    # ("Error bars indicate the standard error of the mean").
    draw_variant(ERROR_SEM, [-1, 1])


if __name__ == "__main__":
    draw()
