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
repowise --version              # 0.62.0 is the version this config was written against

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

Then once per repository, from its root (`repowise` serves whichever directory
the session starts in, so a new clone needs its own index):

```bash
repowise init --yes --no-prose     # free: no model calls, builds graph + docs from code
repowise next                      # the few things worth doing, ranked
repowise next --prompt setup       # hand any remaining setup steps to your agent
```

OpenCode lists the five core tools (`get_answer`, `get_context`, `get_symbol`,
`search_codebase`, `get_why`) because it sends every listed schema with each
request. Change the profile with
`repowise config set mcp.tools <core|lean|standard|all>`; Claude Code keeps the
ten-tool standard profile and can load the core four eagerly with
`repowise config set mcp.always_load true`.

A config file with comments is JSONC; Repowise will not rewrite a file it
cannot parse as strict JSON, so if `agents add` reports that it could not read
`~/.config/opencode/opencode.jsonc`, fix the syntax (or merge the block by
hand) and re-run it. `agents add` may also update the managed block inside
`AGENTS.md`; commit that change like any other edit to the tracked file.

## Keeping an install current

```bash
uv tool upgrade repowise            # or: pipx upgrade repowise
repowise whats-new                  # what changed since the version you last read
repowise doctor                     # every check: hooks, wiring, index, providers
repowise agents refresh             # rewrite the configs of already-wired agents
```

`agents refresh` is what carries a new release's MCP entry, tool profile and
hook paths into `~/.claude.json`, `~/.claude/settings.json`, the Claude Desktop
config and `~/.config/opencode/opencode.jsonc`. It never adds a client that was
not wired before. Run it after every upgrade, then restart OpenCode and Claude
Code: MCP servers and hooks load only at startup. `doctor` is the gate
afterwards — every row must be `✓ OK`.

## Per repository

Once indexed, these are the day-to-day commands:

```bash
repowise update --working-tree --index-only   # fold uncommitted work into the index
repowise status                    # sync commit, pages, freshness
repowise health                    # score, worst file, ranked fixes with verify commands
repowise report                    # the most urgent findings, each with file:line
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
  `repowise config list --suggested` prints settings that fit this repository
  (`hooks.coverage_reingest` is the common one); apply one with
  `repowise config set <key> <value>`.
- **Runtime evidence**: `repowise evidence setup` prints the coverage and
  profile commands for each build unit; ingest one run with
  `repowise evidence add <profile>` so performance findings rank by measured
  cost instead of code shape alone. `repowise evidence status` shows the newest
  run of each workload.
- **Looking at the index**: `repowise report` lists the most urgent findings
  with file:line and a prompt for your agent, and `repowise serve` opens the
  dashboard. Mark an item fixed with `repowise mark <id> done`.

## Remove

```bash
repowise uninstall --keep-index    # unwire agents, keep the index
repowise uninstall --all           # everything, including the index
uv tool uninstall repowise         # then the package itself
```
