---
paths:
  - "**/*.py"
  - "scripts/python/**"
---

# Python Code Conventions

**Reproducibility is the default, not a feature.** A script should run from a clean
checkout with no manual intervention and end in the same state every time.

> This rule mirrors [`r-code-conventions.md`](r-code-conventions.md) and
> [`stata-code-conventions.md`](stata-code-conventions.md) for this project's
> **secondary** Python analysis. Stata is primary; use Python where it's the better
> tool (scraping, text/NLP features, plotting). All three rules apply on their own files.

## 1. Reproducibility scaffolding

Every analysis script starts with the same shape:

```python
"""
File:     NN_descriptive_name.py
Purpose:  [one-sentence description]
Inputs:   [paths]
Outputs:  [paths]
Run order: standalone | after NN_prior.py
"""
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[2]      # repo root — NO hardcoded absolute paths
OUT  = ROOT / "scripts" / "python" / "_outputs"
OUT.mkdir(parents=True, exist_ok=True)

SEED = 20260701
rng = np.random.default_rng(SEED)               # seed ONCE; pass `rng` around, don't reseed
```

- **No hardcoded absolute paths** — always derive from `ROOT` / `pathlib`.
- **Seed once** with a `Generator`; avoid the legacy global `np.random.seed()` where possible.
- **Pin the environment** — record versions for the replication package (`pip freeze`
  / `uv.lock` / `requirements.txt`); see `/capture-environment`.

## 2. Numbered pipeline

Scripts live in `scripts/python/`, numbered for run order, outputs in `scripts/python/_outputs/`.
A `99_run_all.py` (or a Makefile target) should reproduce every Python output in one command.

## 3. Figures — presentation-ready (project non-negotiable)

```python
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(8, 5), dpi=300)
# ... plot ...
fig.savefig(OUT / "fig_name.png", dpi=300, bbox_inches="tight", facecolor="white")
fig.savefig(OUT / "fig_name.pdf", bbox_inches="tight")            # vector for the report
```

Consistent theme, readable fonts, **≥300 DPI, white background**, both raster + vector.
Same standard for `plotnine`.

## 4. Tables — presentation-ready

Export to a durable format and a formatted version; never leave a raw `print(df)` as the
deliverable. `df.to_csv(OUT / "tab_name.csv", index=False)` plus a formatted export
(`.to_latex()` / `.to_markdown()` / `styler`) with labeled columns.

## 5. Numerical discipline

- **No float equality** — use `np.isclose` / `math.isclose`, never `==` on floats.
- **Clamp probabilities** to an open interval before `norm.ppf` etc.:
  `p = np.clip(p, 1e-12, 1 - 1e-12)`.
- **Explicit NaN handling** — be deliberate with `.dropna()` / `skipna`; don't rely on
  silent defaults. State how zeros/missing are treated (matters for log-count outcomes).
- **Deterministic resampling** — derive per-replicate seeds from the base
  (`rng.spawn(n)` or `base + b`), don't reseed inside loops.

## 6. Style

- `snake_case`, functions documented with docstrings, no magic numbers.
- Lines ≤ 100 chars (math-heavy lines may exceed if a comment explains the operation).
- Prefer `pandas`/`numpy` vectorization; comments explain **why**, not what.

## 7. Checklist

```
[ ] Paths derived from repo root (pathlib) — no absolute paths
[ ] Seed set once via a Generator, documented
[ ] Figures: ≥300 DPI, white bg, raster + vector
[ ] Tables: exported CSV + formatted, labeled
[ ] Numerical discipline: no float ==, clamp probs, explicit NaN handling
[ ] Environment pinned for the replication package
```

## Cross-references

- [`stata-code-conventions.md`](stata-code-conventions.md) — primary-analysis discipline.
- [`r-code-conventions.md`](r-code-conventions.md) — R analysis discipline.
- [`replication-protocol.md`](replication-protocol.md) — tolerance contract across R / Stata / Python.
- `/capture-environment`, `/audit-reproducibility` — env pinning + numeric verification.
