---
name: pr_rituals
description: Standard procedure for creating Pull Requests, ensuring all tests and formatting pass.
---

# PR Rituals

When the user asks you to create a Pull Request or finish a feature, you MUST follow this ritual:

1. **Verify State & Run Local Tests**:
   - Ensure there are no outstanding linting or syntax errors.
   - Run full test suites locally (`python -m pytest`, `go test ./...`) to ensure all tests pass and coverage requirements (>=80%) are satisfied.
   - **Never push code or create a PR and wait for CI to catch errors without running tests locally first.**
2. **Execute PR Tool**: Call the `prepare_pr_tool` MCP tool provided by the `agents-framework` server.
   - This tool will automatically run `pre-commit` (ruff, gofmt, golangci-lint).
   - It will evaluate the unpushed commits and write a comprehensive PR description.
   - It will use the `gh` CLI to publish the PR.
3. **Handle Failures**: If `prepare_pr_tool` fails due to formatting or test failures, read the output, fix the failing code in Python or Go, verify the fix locally with tests, commit the fixes, and invoke the tool again.
