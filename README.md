# Agent Configuration

Portable Pi configuration, extensions, and reusable subagent prompts for local agent workflows.

## Reusable subagents

The agents/ directory contains custom subagent prompts for reuse across projects.

## Claude Code configuration

`claude/settings.json` mirrors `~/.claude/settings.json`, including `CLAUDE_CODE_SUBAGENT_MODEL=sonnet` as the default for subagents without their own model. Restore it by copying it to `~/.claude/settings.json`.

Per-agent model routing (Plan on Opus; general-purpose and claude on Sonnet; Explore, web-fetch, claude-code-guide and statusline-setup on Haiku) lives in `AGENTS.md`, which reaches Claude through the `~/.claude/CLAUDE.md` symlink described there.

## Reusable skills

`skills/` contains harness skills that load on demand.

- `wave-orchestrator` — executes a `plans/*.md` backlog in dependency-ordered
  parallel waves: one worktree per plan, `run-worker` for execution, verification
  before each merge, and a live `plans/STATUS.md` schedule.
- `platform-bugbash` — multi-round bugbash of an app on Android emulators, iOS
  simulators or web browsers: sets up the toolchain and a Podman backend, walks
  every screen signed in with seeded content on the most popular devices, and
  collects fixes plus unit, integration, regression and e2e tests in one draft PR.

Link a skill into a harness so it is discovered (symlink, so `git pull` updates it):

```bash
mkdir -p ~/.config/opencode/skills ~/.claude/skills ~/.agents/skills
for skill in wave-orchestrator platform-bugbash; do
  ln -sfn ~/agents/skills/$skill ~/.config/opencode/skills/$skill
  ln -sfn ~/agents/skills/$skill ~/.claude/skills/$skill
  ln -sfn ~/agents/skills/$skill ~/.agents/skills/$skill
done
```

## Pi configuration

The `.pi/` directory contains settings and a package manifest for restoring a Pi environment. The root `@aresowj/pi-lazy-tools` Pi package provides the `lazy-tools` extension, which keeps heavyweight capability groups hidden until searched and activated. Install it with `pi install npm:@aresowj/pi-lazy-tools` after publishing.

Configure default rules inside Pi with `/lazy-tools`: use `eager <tool-or-prefix>`, `lazy <tool-or-prefix>`, `default <tool-or-prefix>`, `show`, or `reset`. Rules persist in `~/.pi/agent/lazy-tools.json` and apply immediately.

Review `.pi/auth.json` before sharing or restoring configuration. Never commit live credentials.

External skills installed outside this repository are pinned in `EXTERNAL_SKILLS.md`.

## OpenCode and Repowise

`opencode/` holds the user-scope OpenCode MCP entry for [Repowise](https://docs.repowise.dev), so every repository on the machine can query a local index instead of grepping. The agent guidance that goes with it lives in `AGENTS.md` above and reaches every harness through the symlinks below. Install and restore steps: [`opencode/README.md`](opencode/README.md).

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
