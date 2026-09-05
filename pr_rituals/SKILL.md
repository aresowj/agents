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
2. **Execute PR Preparation Locally**:
   - Run `pre-commit run --all-files` (or equivalent linters like ruff, gofmt, golangci-lint).
   - Evaluate the unpushed commits and write a comprehensive PR description.
   - Use the `gh` CLI (e.g., `gh pr create`) to publish the PR.
3. **Handle Failures**: If `pre-commit` or tests fail, read the output, fix the failing code in Python, Go, or other languages, verify the fix locally with tests, commit the fixes, and attempt to create the PR again.
