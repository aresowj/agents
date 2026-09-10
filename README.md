# Agent Workflow Skills

A small collection of portable skills for task orchestration across Codex, Google Antigravity, and Pi, plus reusable engineering guidance and Pi configuration.

## Skills

| Skill | Purpose |
|---|---|
| `codex-subagent-routing` | Bounded delegation and result integration in Codex. |
| `antigravity-subagent-routing` | Native Antigravity delegation and optional local inference. |
| `pi-specific-agent-routing` | Pi subagents, background work, and runtime model selection. |
| `software-architecture` | Architecture decisions, boundaries, tradeoffs, and ADRs. |
| `writing-code-comments` | Intent-focused comments and public API documentation. |
| `writing-pull-requests` | Reviewable PR descriptions and validation evidence. |

The routing skills share durable principles but keep platform-specific tool discovery and execution separate. They intentionally avoid pinned model catalogs: use the models and schemas exposed by the active runtime.

## Pi configuration

The `.pi/` directory contains settings and a package manifest for restoring a Pi environment. The root `@aresowj/pi-lazy-tools` Pi package provides the `lazy-tools` extension, which keeps heavyweight capability groups hidden until searched and activated. Install it with `pi install npm:@aresowj/pi-lazy-tools` after publishing.

Configure default rules inside Pi with `/lazy-tools`: use `eager <tool-or-prefix>`, `lazy <tool-or-prefix>`, `default <tool-or-prefix>`, `show`, or `reset`. Rules persist in `~/.pi/agent/lazy-tools.json` and apply immediately.

Review `.pi/auth.json` before sharing or restoring configuration. Never commit live credentials.

## Install repository skills

Copy or symlink the desired root-level skill directories into the skill directory used by the target agent. Install only the skills relevant to that environment; the three routing skills are alternatives, not a bundle that should all activate in one runtime.

External skills installed outside this repository are pinned in `EXTERNAL_SKILLS.md`.

## Validate changes

Run the local skill validator for every root-level skill directory, then run the repository hooks:

```powershell
$validator = 'C:\Users\areso\.codex\skills\.system\skill-creator\scripts\quick_validate.py'

Get-ChildItem -Directory | ForEach-Object {
  if (Test-Path (Join-Path $_.FullName 'SKILL.md')) {
    python $validator $_.FullName
  }
}

pre-commit run --all-files
```

CI runs the repository hooks on pull requests and changes to `main`.
