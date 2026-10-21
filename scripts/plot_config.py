"""
Plot Config — shared module for scientific figure configuration.

Design principles:
  1. No paper dependencies — no paper-specific concepts or color mappings.
  2. Layer separation — palette, semantic roles, style, and export are independent layers.
  3. dict over mode — rcParams are overridden with dicts, not locked into a fixed mode.

Usage:
  from scripts.plot_config import setup_style, save_figure, OKABE_ITO as OI

  setup_style()                               # base style only
  setup_style({"font.size": 9, "figure.dpi": 200})  # flexible overrides

  save_figure(fig, "Fig1", out_dir="./figures")
  # -> Fig1.png, Fig1.jpg, Fig1.tiff, Fig1.svg (all 400 DPI)

  save_figure(fig, "Fig1", out_dir="./figures",
              formats=["png", "pdf"], dpi=600)
"""

from __future__ import annotations

import io
import os
from pathlib import Path
from typing import Iterable

import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Layer 1 — Raw palette (pure data, no paper semantics)                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

OKABE_ITO: dict[str, str] = {
    "orange":         "#E69F00",
    "sky_blue":       "#56B4E9",
    "bluish_green":   "#009E73",
    "yellow":         "#F0E442",
    "blue":           "#0072B2",
    "vermillion":     "#D55E00",
    "reddish_purple": "#CC79A7",
    "black":          "#000000",
    "gray":           "#999999",
}

OKABE_ITO_LIST: list[str] = [
    OKABE_ITO["orange"],
    OKABE_ITO["sky_blue"],
    OKABE_ITO["bluish_green"],
    OKABE_ITO["yellow"],
    OKABE_ITO["blue"],
    OKABE_ITO["vermillion"],
    OKABE_ITO["reddish_purple"],
    OKABE_ITO["black"],
]

# Paul Tol "Bright" qualitative palette — fallback when Okabe-Ito is not enough
TOL_BRIGHT: dict[str, str] = {
    "blue":    "#4477AA",
    "cyan":    "#66CCEE",
    "green":   "#228833",
    "yellow":  "#CCBB44",
    "red":     "#EE6677",
    "purple":  "#AA3377",
    "grey":    "#BBBBBB",
}

TOL_BRIGHT_LIST: list[str] = [
    TOL_BRIGHT["blue"],
    TOL_BRIGHT["cyan"],
    TOL_BRIGHT["green"],
    TOL_BRIGHT["yellow"],
    TOL_BRIGHT["red"],
    TOL_BRIGHT["purple"],
    TOL_BRIGHT["grey"],
]


def sequential_from_cmap(
    n: int, cmap_name: str = "Blues", start: float = 0.25, stop: float = 0.90
) -> list[str]:
    """Return n evenly spaced hex colors from a matplotlib colormap.

    Args:
        n: number of colors to sample
        cmap_name: matplotlib colormap name ("Blues", "Oranges", "Greens", ...)
        start: start position (0-1); avoids colors that are too light
        stop: stop position (0-1); avoids colors that are too dark

    Returns:
        list of n hex color codes
    """
    cmap = plt.get_cmap(cmap_name)
    return [
        mcolors.to_hex(cmap(v))
        for v in np.linspace(start, stop, n)
    ]


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Layer 2 — Common semantic roles (domain independent)                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class Roles:
    """Common semantic color roles.

    Usage:
        from scripts.plot_config import ROLES
        ax.plot(..., color=ROLES.negative)

    Each role takes its hex value from Layer 1; changing OKABE_ITO updates every role.
    """

    def __init__(self, palette: dict[str, str]) -> None:
        self._p = palette

    @property
    def negative(self) -> str:   return self._p["vermillion"]
    @property
    def positive(self) -> str:   return self._p["bluish_green"]
    @property
    def warning(self) -> str:    return self._p["vermillion"]
    @property
    def baseline(self) -> str:   return self._p["gray"]
    @property
    def neutral(self) -> str:    return self._p["gray"]
    @property
    def highlight(self) -> str:  return self._p["orange"]
    @property
    def accent(self) -> str:     return self._p["reddish_purple"]
    @property
    def cool(self) -> str:       return self._p["blue"]
    @property
    def warm(self) -> str:       return self._p["orange"]
    @property
    def muted(self) -> str:      return self._p["gray"]

    # Generic data categories — used when no specific semantics apply
    @property
    def data_1(self) -> str:     return self._p["orange"]
    @property
    def data_2(self) -> str:     return self._p["sky_blue"]
    @property
    def data_3(self) -> str:     return self._p["bluish_green"]
    @property
    def data_4(self) -> str:     return self._p["blue"]
    @property
    def data_5(self) -> str:     return self._p["vermillion"]
    @property
    def data_6(self) -> str:     return self._p["reddish_purple"]
    @property
    def data_7(self) -> str:     return self._p["yellow"]
    @property
    def data_8(self) -> str:     return self._p["black"]


ROLES = Roles(OKABE_ITO)


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Layer 3 — rcParams (base + flexible overrides)                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

STYLE_BASE: dict = {
    # ── fonts ──
    "font.family":      "sans-serif",
    "font.sans-serif":  ["Arial", "Helvetica", "DejaVu Sans"],
    "font.size":        8,
    "axes.labelsize":   9,
    "axes.titlesize":   9,
    "xtick.labelsize":  8,
    "ytick.labelsize":  8,
    "legend.fontsize":  8,
    "figure.titlesize": 10,
    # ── font embedding (LaTeX compatible) ──
    "pdf.fonttype":     42,
    "ps.fonttype":      42,
    "svg.fonttype":     "none",
    # ── ticks and axes ──
    "axes.linewidth":       0.5,
    "xtick.major.width":    0.5,
    "ytick.major.width":    0.5,
    "xtick.minor.width":    0.3,
    "ytick.minor.width":    0.3,
    "xtick.major.size":     3.0,
    "ytick.major.size":     3.0,
    "xtick.direction":      "out",
    "ytick.direction":      "out",
    # ── legend ──
    "legend.frameon":       False,
    "legend.handlelength":  1.2,
    "legend.handleheight":  0.7,
    # ── spines ──
    "axes.spines.top":      False,
    "axes.spines.right":    False,
    # ── grid ──
    "axes.grid":            False,
    "grid.alpha":           0.3,
    "grid.linewidth":       0.3,
    "grid.linestyle":       "--",
    # ── default color cycle ──
    "axes.prop_cycle":      plt.cycler(color=OKABE_ITO_LIST),
}

# Preset overrides — provided per scenario, free to merge
STYLE_TALK: dict = {
    "font.size":        14,
    "axes.labelsize":   14,
    "axes.titlesize":   14,
    "xtick.labelsize":  12,
    "ytick.labelsize":  12,
    "legend.fontsize":  12,
}

STYLE_POSTER: dict = {
    "font.size":        18,
    "axes.labelsize":   18,
    "axes.titlesize":   18,
    "xtick.labelsize":  16,
    "ytick.labelsize":  16,
    "legend.fontsize":  16,
}

# Common overrides for 3D figures
STYLE_3D: dict = {
    "font.size":        9,
    "axes.labelsize":   10,
    "axes.titlesize":   11,
    "xtick.labelsize":  7,
    "ytick.labelsize":  7,
    "axes.grid":        False,
    "axes.spines.top":  True,
    "axes.spines.right": True,
}

# Common overrides for heatmaps
STYLE_HEATMAP: dict = {
    "font.size":        7,
    "axes.labelsize":   8,
    "xtick.labelsize":  6,
    "ytick.labelsize":  7,
}


def setup_style(overrides: dict | None = None) -> None:
    """Apply the base rcParams, with optional overrides.

    Args:
        overrides: rcParams dict to override or extend.
                   If None, only STYLE_BASE is applied.
                   Presets such as STYLE_3D or STYLE_TALK, or a custom dict, may be passed.
                   Merge multiple presets yourself:
                     setup_style({**STYLE_BASE, **STYLE_3D,
                                  "figure.dpi": 200})

    Examples:
        # Minimal — base style only
        setup_style()

        # Override the font size
        setup_style({"font.size": 7})

        # For talks
        setup_style(STYLE_TALK)

        # 3D figures
        setup_style(STYLE_3D)

        # Custom merge
        setup_style({**STYLE_BASE, "font.size": 10,
                     "xtick.direction": "in"})
    """
    plt.rcParams.update(STYLE_BASE)
    if overrides:
        plt.rcParams.update(overrides)


def reset_style() -> None:
    """Reset to the matplotlib default style."""
    plt.rcdefaults()


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Layer 4 — Export engine                                                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Internal configuration — decoupled from the paper semantics
#
# Implementation notes:
#   - PNG/SVG/PDF: native matplotlib output
#   - JPG/TIFF: render to an RGBA buffer, then transcode and compress with PIL
#     matplotlib pil_kwargs do not take effect on some backends; handling the file with PIL is more reliable

_FORMAT_SPECS: dict[str, dict] = {
    "png": {
        "ext": ".png",
        "save_kwargs": {"bbox_inches": "tight", "pad_inches": 0.02},
    },
    "jpg": {
        "ext": ".jpg",
        "save_kwargs": {"bbox_inches": "tight", "pad_inches": 0.02},
        "pil_convert": True,
        "pil_format": "JPEG",
        "pil_kwargs": {"quality": 100, "subsampling": 0},  # 0 = 4:4:4, no chroma subsampling
    },
    "tiff": {
        "ext": ".tiff",
        "save_kwargs": {"bbox_inches": "tight", "pad_inches": 0.02},
        "pil_convert": True,
        "pil_format": "TIFF",
        "pil_kwargs": {"compression": "tiff_lzw"},
    },
    "svg": {
        "ext": ".svg",
        "save_kwargs": {"bbox_inches": "tight", "pad_inches": 0.02},
    },
    "pdf": {
        "ext": ".pdf",
        "save_kwargs": {"bbox_inches": "tight", "pad_inches": 0.02},
    },
}

# Common combinations
FORMATS_ALL = ["png", "jpg", "tiff", "svg"]
FORMATS_VECTOR = ["pdf", "svg"]
FORMATS_RASTER = ["png", "jpg", "tiff"]
FORMATS_PUBLICATION = ["pdf", "png", "svg"]  # most common for submission


def save_figure(
    fig: plt.Figure,
    name: str,
    out_dir: str | Path,
    formats: Iterable[str] | None = None,
    dpi: int | None = 400,
    close: bool = True,
    verbose: bool = True,
) -> list[Path]:
    """Save one figure in several formats at once.

    Args:
        fig: matplotlib Figure object
        name: file name (without extension), e.g. "Fig1_BarChart"
        out_dir: output directory
        formats: output format list, default ["png","jpg","tiff","svg"]
        dpi: raster DPI, default 400. Ignored for vector formats.
        close: call plt.close(fig) after saving
        verbose: print the path of every saved file

    Returns:
        list of saved Paths

    Raises:
        ValueError: formats contains an unsupported format
        OSError: output directory cannot be created or written

    Examples:
        # Default four formats + 400 DPI
        save_figure(fig, "Fig1_BarChart", "./figures")

        # PNG + PDF only, 600 DPI
        save_figure(fig, "Fig2_Scaling", "./figures",
                     formats=["png", "pdf"], dpi=600)

        # Keep the figure open (for further editing)
        save_figure(fig, "draft", "./preview", close=False)
    """
    if formats is None:
        formats = FORMATS_ALL

    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    saved: list[Path] = []
    for fmt in formats:
        spec = _FORMAT_SPECS.get(fmt)
        if spec is None:
            raise ValueError(
                f"Unsupported format: {fmt!r}. "
                f"Supported: {list(_FORMAT_SPECS.keys())}"
            )

        out_path = out_dir / f"{name}{spec['ext']}"

        if spec.get("pil_convert"):
            # JPG/TIFF: render to RGBA buffer → PIL convert
            _save_via_pil(fig, out_path, spec, dpi)
        else:
            # PNG/SVG/PDF: native matplotlib
            kwargs = dict(spec["save_kwargs"])
            if fmt not in ("svg", "pdf") and dpi is not None:
                kwargs["dpi"] = dpi
            fig.savefig(out_path, **kwargs)

        saved.append(out_path)

        if verbose:
            dpi_str = ""
            if fmt not in ("svg", "pdf") and dpi:
                dpi_str = f", {dpi} DPI"
            print(f"  {out_path}{dpi_str}")

    if close:
        plt.close(fig)

    return saved


def _save_via_pil(
    fig: plt.Figure,
    out_path: Path,
    spec: dict,
    dpi: int | None,
) -> None:
    """Render figure to RGBA buffer, then save via PIL with proper compression."""
    buf = io.BytesIO()
    fig.savefig(
        buf,
        format="png",
        dpi=dpi,
        bbox_inches="tight",
        pad_inches=0.02,
    )
    buf.seek(0)
    img = Image.open(buf)
    # Convert RGBA → RGB for formats that don't support alpha
    if img.mode == "RGBA" and spec["pil_format"] in ("JPEG",):
        background = Image.new("RGB", img.size, (255, 255, 255))
        background.paste(img, mask=img.split()[3])
        img = background
    elif img.mode == "RGBA":
        img = img.convert("RGB")
    img.save(out_path, format=spec["pil_format"], **spec["pil_kwargs"])


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Convenience helpers                                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

def set_okabe_ito_cycle() -> None:
    """Set the color cycle of the current axes to Okabe-Ito (does not touch global rcParams)."""
    plt.gca().set_prop_cycle(color=OKABE_ITO_LIST)


def apply_okabe_ito_globally() -> None:
    """Set Okabe-Ito as the global default color cycle."""
    plt.rcParams["axes.prop_cycle"] = plt.cycler(color=OKABE_ITO_LIST)


def despine(ax=None, top: bool = True, right: bool = True,
            left: bool = False, bottom: bool = False) -> None:
    """Convenience spine removal.

    Args:
        ax: target axes, defaults to the current axes
        top/right/left/bottom: whether to remove the spine
           By default top+right are removed (matching STYLE_BASE); pass left=True to remove the left spine.
    """
    if ax is None:
        ax = plt.gca()
    for spine, hide in [("top", top), ("right", right),
                        ("left", left), ("bottom", bottom)]:
        if hide:
            ax.spines[spine].set_visible(False)


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Self-check (run directly with python scripts/plot_config.py)              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

if __name__ == "__main__":
    print("=" * 60)
    print("plot_config self-check")
    print("=" * 60)

    print("\n[Layer 1] OKABE_ITO palette:")
    for name, hex_code in OKABE_ITO.items():
        print(f"  {name:20s} {hex_code}")

    print("\n[Layer 1] sequential_from_cmap('Blues', 5):")
    blues5 = sequential_from_cmap(5, "Blues")
    for i, c in enumerate(blues5):
        print(f"  step {i}: {c}")

    print("\n[Layer 2] ROLES:")
    for attr in sorted(dir(ROLES)):
        if attr.startswith("_"):
            continue
        val = getattr(ROLES, attr)
        if callable(val):
            continue
        print(f"  {attr:20s} {val}")

    print("\n[Layer 3] STYLE_BASE keys:", len(STYLE_BASE))
    print("  Preset dicts: STYLE_TALK, STYLE_POSTER, STYLE_3D, STYLE_HEATMAP")

    print("\n[Layer 4] Supported formats:", list(_FORMAT_SPECS.keys()))
    print("  Format combos: FORMATS_ALL, FORMATS_VECTOR, FORMATS_RASTER, FORMATS_PUBLICATION")

    print("\n  All checks passed.")
