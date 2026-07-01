# scripts/stata/

**Primary analysis** for Essay 2 (Stata). Conventions: `.claude/rules/stata-code-conventions.md`.

- Numbered pipeline (`00_install.do`, `01_clean.do`, … `99_run_all.do`); outputs to
  `scripts/stata/_outputs/`.
- No hardcoded absolute paths — set the project root once via a `global` (the
  `ROOT1`/`ROOT2` confirm-file pattern) and reference `${derived}` / `${tables}`.
- `set seed` + `set sortseed` at the top of any script with random ops.
- Executing `.do` files through Claude requires the stata-mcp server
  (`claude mcp add stata-mcp --scope user -- uvx stata-mcp`).
