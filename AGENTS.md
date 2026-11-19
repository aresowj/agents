# Agent Guidance

This repository publishes as `@aresowj/pi-lazy-tools` (a Pi extension package) and maintains external skill references in `EXTERNAL_SKILLS.md`.

## Security

- NEVER sync the OpenAI API key to the repo. Keep it in environment variables only.

## Starting new work

Always pull the latest `main` before starting new work:

```bash
git -C ~/agents pull --ff-only origin main
```

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

## Codex custom subagents

- For bounded, fully specified coding work, use the `routine-implementer` custom agent. Provide the task scope, acceptance criteria, and relevant context.
- Before handing off or merging code changes, use the read-only `reviewer` custom agent with the exact diff, requirements, and available verification evidence. Keep fixes and the final disposition with the primary agent.
- Run implementation and review sequentially. Respect explicit user requests to skip delegation or use a different workflow.

## DeepSeek worker execution rules

Applies to any harness driving headless OpenCode workers (`opencode run`): Codex, Claude Code, Gemini CLI, Antigravity, or a shell script.

- NEVER run `opencode run` with unredirected stdout/stderr in `run_command`. Streaming text, tool calls, and stderr can flood the calling agent's context or block on TTY reads.
- Always invoke parallel workers via `run-worker <worktree-dir> <plan-file> <log-name>` (installed on PATH; `./scripts/run-worker.sh` is equivalent inside this repo). The script detaches stdin (`</dev/null`), routes stdout and stderr to `${OPENCODE_WORKER_LOG_DIR:-/tmp}/opencode-<log-name>.log`, and prints only `worker=<log-name> exit=<code> log=<path>`.
- One worker per git worktree. Never point two workers at the same worktree or at overlapping files.
- When workers finish, inspect ONLY:
  - exit codes from the summary line (or `wait`),
  - `git -C <worktree-dir> diff --stat`,
  - `tail -n 25 <log-file>` for the failure tail.
  Never `cat` a full log into context.
- Overrides: `OPENCODE_WORKER_MODEL` (default `opencode-go/deepseek-v4.1-flash`), `OPENCODE_WORKER_LOG_DIR` (default `/tmp`).
- Do not pass `--dir` to `opencode run`: v2.2.7 has no such flag. The wrapper `cd`s into the worktree instead.

Launch several workers without blocking the caller:

```bash
run-worker ../worktrees/api plans/api.md api &
run-worker ../worktrees/ui  plans/ui.md  ui  &
wait
git -C ../worktrees/api diff --stat
tail -n 25 /tmp/opencode-api.log
```

### Setup and sync

On a new machine, clone this repository and link everything in one pass:

```bash
git clone git@github.com:aresowj/agents.git ~/agents

ln -sfn ~/agents/AGENTS.md ~/AGENTS.md
ln -sfn ~/agents/AGENTS.md ~/.codex/AGENTS.md
ln -sfn ~/agents/AGENTS.md ~/.config/opencode/AGENTS.md
ln -sfn ~/agents/AGENTS.md ~/.claude/CLAUDE.md
ln -sfn ~/agents/AGENTS.md ~/.gemini/GEMINI.md

~/agents/scripts/install-worker-link.sh   # -> ~/.local/bin/run-worker
```

- Rule files are symlinked, not copied, so `git -C ~/agents pull` updates every harness at once. Do not replace a link with a copy.
- `install-worker-link.sh` accepts an optional bin directory (default `~/.local/bin`), refuses to overwrite a real file, and only replaces symlinks.
- Re-run the link step after moving the clone: symlinks store absolute paths and break silently when the target moves.

## Plan orchestration (waves)

Execute a `plans/*.md` backlog with the `wave-orchestrator` skill (`skills/wave-orchestrator/SKILL.md`): disjoint parallel waves, one worktree per plan, `run-worker` only, verify then merge. Never delegate it to subagents.

## Pre-commit verification

Before pushing or opening a PR:

1. Run `pre-commit run --all-files`.
2. Verify `extensions/lazy-tools/index.ts` passes TypeScript (if pi dev environment available; otherwise skip).
3. Inspect diff for stale references, secrets, `.pi/auth.json` leaks.

Never use CI as the first validation pass.
