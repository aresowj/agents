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
- `claude/` — Claude Code user settings mirrored from `~/.claude/settings.json` (default subagent model). Per-agent model routing lives in this file.
- `docs/cursor-worker-daemon.md` — macOS launchd setup for `agent worker` on this machine.
- `scripts/cursor-worker/` — install, status, restart, and uninstall scripts for the worker daemon.
- `extensions/lazy-tools/` — Pi extension (Node.js, TypeScript). Defers heavyweight tool groups behind `search_tools` to keep system prompts small.
- `EXTERNAL_SKILLS.md` — Registry of external skills with restore and validation instructions.
- `opencode/` — user-scope OpenCode config: the Repowise MCP entry and its agent guidance, restored to `~/.config/opencode/`. See [`opencode/README.md`](opencode/README.md).
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

- For most bounded, fully specified coding work, use the `deepseek-implementer` custom agent: it writes a plan and dispatches it to a headless DeepSeek Flash worker through `run-worker`, then verifies the result. Use `routine-implementer` when the model fallback rule below reaches the Claude tier, or when the task cannot run in a separate git worktree.
- For bounded, fully specified coding work done directly by the agent, use the `routine-implementer` custom agent. Provide the task scope, acceptance criteria, and relevant context.
- Before handing off or merging code changes, use the read-only `reviewer` custom agent with the exact diff, requirements, and available verification evidence. Keep fixes and the final disposition with the primary agent.
- Run implementation and review sequentially. Respect explicit user requests to skip delegation or use a different workflow.

## Keeping agent definitions in sync

Each agent in `agents/` has two definitions: `<name>.toml` for Codex and `<name>.md` for Claude Code. Keep them in sync:

- Any change to one file's `name`, `description`, or instructions (the TOML `developer_instructions` and the Markdown body) must be made to the other in the same commit.
- When adding a new agent, create both files. When removing one, remove both.
- Models are per-harness and intentionally differ: TOML `model`/`model_reasoning_effort` use Codex models; Markdown `model:` uses Claude models. Changing one does not require changing the other.
- Harness-specific wording may differ only where a feature does not exist in the other harness (for example, Codex `sandbox_mode` vs. Claude Code `tools:` and a read-only instruction).

## Claude Code subagent models

When starting a subagent with the Agent tool, always pass `model` as below, unless the user asks for a different one:

| Agent type | model |
|---|---|
| Plan | opus |
| general-purpose | sonnet |
| claude | sonnet |
| Explore | haiku |
| web-fetch | haiku |
| claude-code-guide | haiku |
| statusline-setup | haiku |

Custom agents from `agents/*.md`:

| Agent | model |
|---|---|
| reviewer | opus (set in its file) |
| deepseek-implementer | sonnet (set in its file); it only plans, dispatches and verifies |
| routine-implementer | haiku for simple, mechanical tasks (renames, small edits in one or two files, boilerplate); sonnet otherwise. Its file defaults to sonnet, so pass `model: haiku` for the simple ones. When unsure, use sonnet. |

Other agents (custom or from plugins) keep their own `model` setting; if they have none, Sonnet is the default via `CLAUDE_CODE_SUBAGENT_MODEL` in `claude/settings.json`. Other harnesses can ignore this section.

## DeepSeek worker execution rules

Applies to any harness driving headless OpenCode workers (`opencode run`): Codex, Claude Code, Gemini CLI, Antigravity, or a shell script.

- NEVER run `opencode run` with unredirected stdout/stderr in `run_command`. Streaming text, tool calls, and stderr can flood the calling agent's context or block on TTY reads.
- Always invoke parallel workers via `run-worker <worktree-dir> <plan-file> <log-name>` (installed on PATH; `./scripts/run-worker.sh` is equivalent inside this repo). The script detaches stdin (`</dev/null`), routes stdout and stderr to `${OPENCODE_WORKER_LOG_DIR:-/tmp}/opencode-<log-name>.log`, and prints only `worker=<log-name> exit=<code> model=<model> log=<path>`.
- One worker per git worktree. Never point two workers at the same worktree or at overlapping files.
- When workers finish, inspect ONLY:
  - exit codes from the summary line (or `wait`),
  - `git -C <worktree-dir> diff --stat`,
  - `tail -n 25 <log-file>` for the failure tail.
  Never `cat` a full log into context.
- Overrides: `OPENCODE_WORKER_MODELS` (space-separated fallback chain, default below), `OPENCODE_WORKER_MODEL` (pins one model and disables fallback), `OPENCODE_WORKER_LOG_DIR` (default `/tmp`; on Windows set it to a real folder).
- Keep the DeepSeek API key in `DEEPSEEK_API_KEY` or OpenCode's own auth store (`opencode auth login`), never in this repository.

### Model fallback rule

Implementation work goes down this chain, moving to the next tier only when the current one fails to run (rate limit, exhausted quota, auth error, unavailable model):

1. OpenCode free DeepSeek Flash: `opencode/deepseek-v4.1-flash-free`
2. OpenCode Go DeepSeek Flash: `opencode-go/deepseek-v4.1-flash`
3. DeepSeek direct Flash: `deepseek/deepseek-flash`
4. Claude Sonnet or Haiku, the native models in the Claude subscription: `routine-implementer` with `model` per the subagent table (haiku for simple, mechanical tasks; sonnet otherwise).

`run-worker` handles tiers 1–3 itself. It moves to the next model only when an attempt left `HEAD` and `git status --porcelain` unchanged; an attempt that changed the worktree is final, so partial work is never handed to another model. It exits `75` when every OpenCode tier made no progress: that is the signal for tier 4. Do not fall back to Claude on an ordinary failure (tests failing, out-of-scope diff); retry or fix that on the same chain. Harnesses without Claude models stop at tier 3 and report.
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

## Platform bugbash

For a bugbash, QA pass or device walkthrough on Android, iOS or web, use the `platform-bugbash` skill (`skills/platform-bugbash/SKILL.md`): one draft PR that is never merged, tests for every fix, and every device in the matrix verified.

## Repowise (local code index)

Repowise indexes a repository locally and answers from that index instead of
repeated greps: dependency graph, git history signals, code health, dead code
and docs. Harnesses with the MCP server wired call its tools; anywhere else the
same index answers through the CLI (`repowise ask "<question>"`,
`repowise health`, `repowise status`). See
[`opencode/README.md`](opencode/README.md) for the user-scope MCP entry, the
per-repository indexing steps and the upgrade procedure.

Sequence after upgrading Repowise or starting on a new repository:

```bash
uv tool upgrade repowise        # or: pipx upgrade repowise
repowise agents refresh         # carry the new release into every wired agent
repowise next --prompt setup    # finish any remaining setup, handed to your agent
repowise update --working-tree --index-only   # index uncommitted work too
repowise doctor                 # every row must be ✓ OK
```

Upgrading alone changes nothing on disk: `agents refresh` is the step that
rewrites the MCP entries and hook paths of every agent already wired. Restart
OpenCode and Claude Code afterwards, because MCP servers and hooks load only at
startup.

<!-- REPOWISE_DISTILL:START — Do not edit below this line. Auto-generated by Repowise. -->
For any question about this codebase, call a Repowise tool first (get_answer for how/where/why questions, search_codebase for an identifier, get_context for callers or a file).

### Output Distillation

- Prefer `repowise distill <cmd>` for noisy commands: test runs, builds, `git status`/`log`/`diff`, searches, file listings. It runs the command unchanged (exit code preserved) and prints a compact, errors-first rendering; every error line survives.
- Output may contain a marker like `[repowise#a1b2c3d4e5f6: 230 lines omitted (~6.1k tokens); restore: repowise expand a1b2c3d4e5f6]`. The omitted content is fully preserved: run `repowise expand <ref>` to retrieve it, or `repowise expand <ref> -q <regex>` for just the matching lines.
- Never re-run a command to see omitted output; expand the marker instead.
- For structure-level questions about a large indexed file ("what's in here", "which function handles X"), `get_context(["path"], include=["skeleton"])` returns the file with bodies elided (every signature plus the bodies of the most central symbols) at a fraction of the cost of a full Read.
<!-- REPOWISE_DISTILL:END -->

## Pre-commit verification

Before pushing or opening a PR:

1. Run `pre-commit run --all-files`.
2. Verify `extensions/lazy-tools/index.ts` passes TypeScript (if pi dev environment available; otherwise skip).
3. Inspect diff for stale references, secrets, `.pi/auth.json` leaks.

Never use CI as the first validation pass.
