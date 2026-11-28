# OpenCode + Repowise

Portable, user-scope configuration that gives every OpenCode session, in every
repository on the machine, the Repowise MCP tools. Repowise indexes a
repository locally (dependency graph, git history signals, code health, dead
code, docs) and answers from that index instead of repeated greps.

The agent guidance that tells a session to use that index lives in
[`AGENTS.md`](../AGENTS.md) at the repository root, which the restore steps
below symlink into every harness. Nothing here contains keys, and the index
itself never belongs in git.

## Files

| File | Goes to | Purpose |
|---|---|---|
| [`opencode.jsonc`](opencode.jsonc) | merge into `~/.config/opencode/opencode.jsonc` | User-scope MCP entry, so every project gets the server |

The `AGENTS.md` block with the `REPOWISE_DISTILL` markers is maintained in
place. Leave the markers alone so a later `repowise agents add` updates that
block instead of appending a second copy.

## Restore on a new machine

```bash
# 1. Install Repowise (Python 3.11+; uv provides its own Python).
uv tool install repowise        # or: pipx install repowise
repowise --version

# 2. Merge the "mcp" block from opencode/opencode.jsonc into
#    ~/.config/opencode/opencode.jsonc (keep existing settings), or copy the
#    file if there is no config yet. Then let Repowise point the entry at the
#    local binary, so it works without PATH:
repowise agents add --target=opencode --yes

# 3. Link the shared guidance into OpenCode (see "Setup and sync" in
#    AGENTS.md for the other harnesses):
ln -sfn ~/agents/AGENTS.md ~/.config/opencode/AGENTS.md

# 4. Restart OpenCode; MCP servers load only at startup.
```

OpenCode lists the five core tools (`get_answer`, `get_context`, `get_symbol`,
`search_codebase`, `get_why`). Change the profile with
`repowise config set mcp.tools <core|lean|standard|all>`.

A config file with comments is JSONC; Repowise will not rewrite a file it
cannot parse as strict JSON, so if `agents add` reports that it could not read
`~/.config/opencode/opencode.jsonc`, fix the syntax (or merge the block by
hand) and re-run it. `agents add` may also update the managed block inside
`AGENTS.md`; commit that change like any other edit to the tracked file.

## Per repository

```bash
repowise init --yes --no-prose     # free: no model calls, builds graph + docs from code
repowise status                    # sync commit, pages, freshness
repowise health                    # score, worst file, ranked fixes with verify commands
```

- **Freshness is automatic**: `init` installs a post-commit hook that runs
  `repowise update` after each commit, so the index follows the branch.
- **Linked worktrees**: an unindexed worktree reads through to the main
  checkout's index read-only; `repowise init` (or `update`) inside one seeds
  from the base checkout and only processes the files that differ.
- **Keep the index out of git**: `init` never edits `.gitignore`. Add
  `.repowise/` to `.gitignore` or to `.git/info/exclude` (clone-local).
  Hand-written `.repowise/policies.yaml`, `components.yaml`, `teams.yaml` and
  `decisions.yaml` are the only files there meant to be committed.
- **Optional upgrades**: `repowise generate --provider claude_cli` writes the
  doc pages with a model (plan quota, no API bill), and
  `repowise reindex --embedder ollama` adds semantic search locally.

## Remove

```bash
repowise uninstall --keep-index    # unwire agents, keep the index
repowise uninstall --all           # everything, including the index
uv tool uninstall repowise         # then the package itself
```
