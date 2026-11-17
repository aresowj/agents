# Agent Configuration

Portable Pi configuration, extensions, and reusable subagent prompts for local agent workflows.

## Reusable subagents

The agents/ directory contains custom subagent prompts for reuse across projects.

## Reusable skills

`skills/` contains harness skills that load on demand.

- `wave-orchestrator` — executes a `plans/*.md` backlog in dependency-ordered
  parallel waves: one worktree per plan, `run-worker` for execution, verification
  before each merge, and a live `plans/STATUS.md` schedule.

Link a skill into a harness so it is discovered (symlink, so `git pull` updates it):

```bash
mkdir -p ~/.config/opencode/skills ~/.claude/skills ~/.agents/skills
ln -sfn ~/agents/skills/wave-orchestrator ~/.config/opencode/skills/wave-orchestrator
ln -sfn ~/agents/skills/wave-orchestrator ~/.claude/skills/wave-orchestrator
ln -sfn ~/agents/skills/wave-orchestrator ~/.agents/skills/wave-orchestrator
```

## Pi configuration

The `.pi/` directory contains settings and a package manifest for restoring a Pi environment. The root `@aresowj/pi-lazy-tools` Pi package provides the `lazy-tools` extension, which keeps heavyweight capability groups hidden until searched and activated. Install it with `pi install npm:@aresowj/pi-lazy-tools` after publishing.

Configure default rules inside Pi with `/lazy-tools`: use `eager <tool-or-prefix>`, `lazy <tool-or-prefix>`, `default <tool-or-prefix>`, `show`, or `reset`. Rules persist in `~/.pi/agent/lazy-tools.json` and apply immediately.

Review `.pi/auth.json` before sharing or restoring configuration. Never commit live credentials.

External skills installed outside this repository are pinned in `EXTERNAL_SKILLS.md`.

## Cursor worker daemon (macOS)

Run this repo as a background **My Machines** worker for Cursor Cloud Agents (starts at login, restarts on crash):

```bash
./scripts/cursor-worker/install.sh
./scripts/cursor-worker/status.sh
```

Full setup, configuration, and troubleshooting: [`docs/cursor-worker-daemon.md`](docs/cursor-worker-daemon.md).

## Validate changes

Run the repository hooks before submitting changes:

```powershell
pre-commit run --all-files
```

CI runs the repository hooks on pull requests and changes to `main`.
