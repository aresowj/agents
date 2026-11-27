@AGENTS.md

## Subagent Delegation Policy

Optimize for warm-cache reuse and minimal rework. Never delegate by default.

- **Keep on Opus (Direct):** Architecture, debugging, root-cause analysis, and any edit touching ≤3 files or files already in active context. Executing directly in a warm cache is cheaper than spawning a subagent.
- **Delegate to Haiku (Read-Only Context Firewall):** Repo-wide searches, symbol/dependency tracing, log grepping, and exploring unfamiliar directories.
  - Instruct Haiku to return **only** relevant file paths, line ranges, and a 3–5 bullet summary—never raw file dumps.
- **Delegate to Sonnet (Heavy Implementation):** Multi-file changes (>3 files), repetitive refactors, migrations, or bulk test generation—**only** after the plan and interfaces are locked.
  - Handoff prompts must include exact file paths, function signatures/types, constraints, and the verification command to run.
- **Anti-Rework Guardrails:**
  - Never delegate ambiguous specs or open-ended debugging.
  - If a subagent's output fails verification once, take over and fix it directly on Opus rather than looping.


## Context & Output Hygiene

Keep tool outputs minimal. Never dump raw logs, full lockfiles, or unscoped diffs into context.

- **Tests & Builds:** Run targeted tests (single file/test name) before full suites. Use quiet/compact flags (e.g., `go test`, `jest --silent`, `pytest -q`) and pipe verbose runs to `tail -n 60` or `grep -E "FAIL|ERROR"`. If a run fails, inspect only the first failing stack trace.
- **Git Diffs & Logs:** Always check `git status -s` or `git diff --stat` first. Scope `git diff` to specific paths (`git diff -- path/to/file`) and exclude lockfiles/generated assets (`git diff -- . ':!*lock*' ':!*.sum'`). Limit `git log` with `-n 10 --oneline`.
- **File Reads & Search:** Search with `rg -l` or `rg -n -C 2` before opening files. Read targeted line ranges rather than full files over ~250 lines. Never read lockfiles, build artifacts, minified bundles, or raw JSON/CSV dumps.
- **Noisy CLI Commands:** Cap unbounded output (`docker logs`, `curl`, package installs, linters) with `| head -n 50` or `| tail -n 50`. For large outputs you need to query repeatedly, redirect to `/tmp/out.log` and `rg` it.
- **Compaction:** When switching subtasks or after a heavy debug loop, suggest `/compact` focused on modified files, architectural decisions, and remaining TODOs.