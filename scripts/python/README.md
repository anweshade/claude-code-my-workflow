# scripts/python/

**Secondary analysis** (Python). Conventions: `.claude/rules/python-code-conventions.md`.

- Numbered pipeline (`01_explore.py`, `02_clean.py`, …); outputs to `scripts/python/_outputs/`.
- Project-root-relative paths via `pathlib`; no hardcoded absolute paths.
- Seed a `numpy.random.Generator` once and document it.
- There is no Python-native `/data-analysis` skill — follow the conventions rule and
  pair with `/audit-reproducibility` for numeric checks.
