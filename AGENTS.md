# Agent Guidelines & Workflow Rules

## Local Testing Before Every Push
- **Mandatory Local Testing**: Before every `git push` or Pull Request creation, you MUST run all relevant test suites and linters locally first (e.g., `python -m pytest`, `go test ./...`, `ruff check .`).
- **Never Rely on CI as a First Check**: Do NOT push untested changes or incremental fixes just to wait for remote CI to tell you if they pass. Always verify test outcomes and coverage locally beforehand.
