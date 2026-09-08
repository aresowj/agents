# Repository Guidelines

This repository stores portable agent skills and Pi configuration. Keep instructions concise, environment-specific where necessary, and resistant to tool or model churn.

## Skill changes

- Every skill lives in a root-level directory with a `SKILL.md` whose frontmatter `name` matches the directory name.
- Descriptions must say what the skill does and when it should activate. Avoid catch-all language that routes unrelated requests into a skill.
- Put durable decisions and non-obvious constraints in skills. Do not copy model catalogs, benchmark claims, or tool schemas that the active runtime can expose directly.
- Keep authorization boundaries explicit. Delegation never grants a subagent broader edit, network, or external-mutation permission than the parent received.
- Prefer runtime capability discovery over guessed tool names or parameters.
- Avoid overlap: extend the owning skill or remove the superseded skill instead of maintaining two near-duplicates.

## Verification

Before pushing or opening a pull request:

1. Run the local skill validator against every root-level skill directory.
2. Run `pre-commit run --all-files`.
3. Inspect the complete diff for stale references, accidental files, secrets, and mismatched documentation.

Never use CI as the first validation pass.
