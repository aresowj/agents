# Agent Guidance

This repository publishes as `@aresowj/pi-lazy-tools` (a Pi extension package) and maintains external skill references in `EXTERNAL_SKILLS.md`.

## Repository structure

- `.pi/` — Pi environment config (packages list, settings, auth). See `README.md` for Pi setup.
- `docs/cursor-worker-daemon.md` — macOS launchd setup for `agent worker` on this machine.
- `scripts/cursor-worker/` — install, status, restart, and uninstall scripts for the worker daemon.
- `extensions/lazy-tools/` — Pi extension (Node.js, TypeScript). Defers heavyweight tool groups behind `search_tools` to keep system prompts small.
- `EXTERNAL_SKILLS.md` — Registry of external skills with restore and validation instructions.
- CI runs `pre-commit` hooks on every PR and push to `main`.

## Local agent routing

**Local agent available:** hostname `kagami`, max 1 concurrent task, ~65k context, ~40 tok/s generation.

**Use for:**
- Simple to medium-complexity reasoning tasks (not low-effort tasks).
- General coding work: refactoring, debugging, test writing, code review.
- Tasks where you can tolerate slower output (cloud cost savings justify latency).

**Do NOT use for:**
- Urgent/blocking work (40 tok/s is slow for interactive debugging).
- Large reasoning problems requiring 60k+ context or multiple reasoning steps.
- Parallel work (max 1 concurrent task; avoid spawning multiple tasks to this model).

**How to delegate:** When a task fits the profile above, explicitly request the local agent. Never auto-spawn concurrent tasks to `kagami`; prefer sequential work or wait for non-urgent background processing.

## Pre-commit verification

Before pushing or opening a PR:

1. Run `pre-commit run --all-files`.
2. Verify `extensions/lazy-tools/index.ts` passes TypeScript (if pi dev environment available; otherwise skip).
3. Inspect diff for stale references, secrets, `.pi/auth.json` leaks.

Never use CI as the first validation pass.
