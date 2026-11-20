# Subagent models

When starting a subagent with the Agent tool, always pass `model` as below, unless I ask for a different one:

| Agent type | model |
|---|---|
| Plan | opus |
| general-purpose | sonnet |
| claude | sonnet |
| Explore | haiku |
| web-fetch | haiku |
| claude-code-guide | haiku |
| statusline-setup | haiku |

Other agents (custom or from plugins) keep their own `model` setting; if they have none, Sonnet is the default via `CLAUDE_CODE_SUBAGENT_MODEL`.
