# CLAUDE.MD -- Influencer Marketing Research Project

<!-- This repo is a fork of an academic-slides+econometrics workflow template.
     It has been adapted for a PROSE RESEARCH REPORT on influencer marketing:
     data + analysis + figures + Markdown drafts live here; the final report is
     written in Word / Google Docs. Slide/LaTeX/teaching machinery is kept on
     disk but DORMANT (see "What Applies / What to Ignore"). Do not delete it —
     it keeps future upstream merges clean. -->

**Project:** Influencer Marketing (Essay 2) — *working title, confirm*
**Institution:** Kelley School of Business, Indiana University
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- re-run analysis / re-check outputs and confirm results at the end of every task
- **Single source of truth** -- analysis **outputs** (Stata primary; R / Python secondary) + **Markdown working drafts** in this repo are authoritative; **Word / Google Docs is the final rendering surface**, kept in sync *from* the repo drafts (never the reverse)
- **Quality gates** -- advisory for this project (see note below): use the review skills, not a numeric score, as the real gate
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md) (generic) or `.claude/state/personal-memory.md` (project-specific)

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, decision records, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```
my-project/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── data/                        # [ACTIVE] Raw + processed data (guarded by confidential-data rule)
├── report/                      # [ACTIVE] Markdown working drafts of report sections
├── scripts/stata/               # [ACTIVE] Stata .do files — PRIMARY analysis (Essay 2)
├── scripts/R/                   # [ACTIVE] R analysis (secondary); outputs in scripts/R/_outputs/
├── scripts/python/              # [ACTIVE] Python analysis (secondary)
├── Figures/                     # [ACTIVE] Figures and images
├── quality_reports/             # [ACTIVE] Plans, specs, decision records, session logs
├── Bibliography_base.bib        # [ACTIVE] Centralized bibliography
├── explorations/                # [ACTIVE] Research sandbox
├── templates/                   # [ACTIVE] Spec / session-log / decision-record templates
│
├── Slides/                      # [DORMANT] Beamer .tex — not used in this project
├── Quarto/                      # [DORMANT] RevealJS .qmd + theme
├── Preambles/header.tex         # [DORMANT] LaTeX headers
├── docs/                        # [DORMANT] GitHub Pages (slides site)
└── master_supporting_docs/      # [ACTIVE] Papers and background docs
```

---

## Commands

```bash
# Run Stata do-file (PRIMARY analysis; batch mode)
stata-mp -b do scripts/stata/validation.do

# Run R analysis (secondary; numbered pipeline; outputs land in scripts/R/_outputs/)
Rscript scripts/R/01_explore.R

# Run Python analysis (secondary)
python scripts/python/analyze.py

# Quality score — LIMITATION: scores only .qmd / .tex / .R; it ERRORS on .md, .py, and .do.
# Our main artifact types (Markdown drafts, Stata, Python) are NOT scorable, so treat
# the numeric gate as advisory and lean on the review skills below.
python scripts/quality_score.py scripts/R/file.R
```

---

## Quality Thresholds (advisory for this project)

The numeric 80/90/95 gate came from the slides template and only scores `.qmd/.tex/.R`.
For a prose+data project the **real quality mechanism is the review skills**:

- **Prose drafts:** `/proofread` → `/humanize` → `/verify-claims` → `/review-paper`
- **Analysis:** `/review-r` + `/audit-reproducibility` (and `/stata-replication` for Stata)

**Do not run `./scripts/install-hooks.sh`** yet — its pre-commit hook adds surface-sync (template maintenance) + R/qmd/tex scoring that mostly won't apply here and would only add friction. Revisit if we later add `.md`/`.py` scorers.

---

## What Applies / What to Ignore

**A — Applies directly (use freely):**
`/stata-replication` `/audit-reproducibility` `/replication-package` `/capture-environment`
`/review-paper` `/seven-pass-review` `/review-r` `/verify-claims` `/proofread` `/humanize`
`/submission-disclosures` `/respond-to-referees` `/lit-review` `/interview-me`
`/research-ideation` `/diagnose` `/commit` `/learn` `/checkpoint` `/context-status`
(`/data-analysis` is R-native — usable for the secondary R work, not the Stata pipeline)

**B — Adapt before trusting (customized for this project):**
- `quality_score.py` — doesn't score `.md`/`.py` (see above)
- Knowledge base (`.claude/rules/knowledge-base-template.md`) — repurposed as a **marketing-metrics + decisions registry**
- `domain-reviewer` agent — retuned for **influencer-marketing substance**, not econometrics slides

**C — Dormant / ignore (slides + teaching template machinery):**
`/create-lecture` `/compile-latex` `/deploy` `/qa-quarto` `/slide-excellence`
`/translate-to-quarto` `/extract-tikz` `/new-diagram` `/syllabus` `/teach-from-paper`
`/scaffold-exercises` `/pedagogy-review` `/visual-audit` — plus `Slides/ Quarto/ Preambles/ docs/`
and the palette-/surface-sync scripts. Left on disk for clean upstream merges; not part of this workflow.

---

## Current Project State

| Section / RQ | Draft (report/) | Analysis | Key outputs |
| --- | --- | --- | --- |
| Essay 2: disclosure × surprise → engagement | *(tbd)* | `scripts/stata/…` (R/Python tbd) | `Validation_OOS`, `Validation_Holm`, `Validation_CV_c1` |
| *(add sections as work begins)* | | | |

*Data lives on the author's machine (`Dropbox/.../Revised Version JM`), not in this repo. Update this table as drafts and analysis land here.*
