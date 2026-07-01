# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "Spec unclear on X. Assume Y?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also refactor Y while here, or focus on X?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (tolerance checks, tests, compilation)
- Documentation (logs, commits)
- Plotting (per established standards)
- Deployment (after you approve, I ship automatically)

---

## Quality Gates (advisory for this project)

The numeric `quality_score.py` gate scores only `.qmd/.tex/.R` — not our `.md`/`.do`/`.py`
artifacts. The **review skills are the real gate**: `/proofread` → `/humanize` →
`/verify-claims` → `/review-paper` for prose; `/review-r` + `/audit-reproducibility`
(+ `/stata-replication`) for analysis. See CLAUDE.md → "Quality Thresholds".

---

## Non-Negotiables

- **No hardcoded absolute paths in committed code.** Stata: define the project root once via a `global` (the `ROOT1`/`ROOT2` confirm-file pattern) and reference `${derived}` / `${tables}` everywhere. R: `here::here()`. Python: project-root-relative / `pathlib`.
- **Seeds set once, explicitly, in every stochastic script** — and documented. Stata: `set seed` at the top; for repeated splits use a stated `base + r` scheme (as in the validation do-file). R: `set.seed()`. Python: a seeded `Generator` (`np.random.default_rng(seed)`).
- **Figures are presentation-ready** — consistent theme, high-DPI (≥300), readable fonts, white background. Applies to Stata graphs, R (ggplot), and Python (matplotlib/plotnine) alike.
- **Tables are presentation-ready** — polished, fully labeled, exported to a durable format (CSV + a formatted version); never raw console dumps in the report.
- **Reproducibility tolerance** — headline numbers must reproduce to the precision reported in the draft; flag any near-miss rather than rounding it away. *(Set a firm numeric tolerance when we build the replication package — `[confirm]`.)*

---

## Preferences

**Visual:** Presentation-ready figures **and** tables, always (explicit requirement — polish by default, don't wait to be asked).
**Reporting:** Concise, lead with the numbers/answer, and be honest about caveats and power. *(inferred from working style — override anytime)*
**Session logs:** Always (post-plan, incremental, end-of-session).
**Replication:** Strict — flag near-misses, don't silently round.
**Onboarding:** More check-ins during early sessions — work in small reviewable steps and pause at high-impact decisions rather than batching.

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
