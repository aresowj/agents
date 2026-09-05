---
name: test_coverage
description: Guidelines for generating tests and enforcing the 80% minimum coverage rule.
---

# Test Coverage Enforcement

This repository strictly enforces an **80% minimum test coverage** for all Python and Go code. CI builds will fail if coverage drops below this threshold.

## Workflow

1. Whenever you modify or create a new functional file (`.py` or `.go`), you must ensure sufficient tests exist.
2. **Generate Tests**: Use your native coding abilities to scaffold the necessary `pytest` or `testify` tests to reach 80% coverage. Review the source file and generate test cases that exercise the core logic.
3. **Verify Locally**: Run the test suite locally (e.g., `pytest --cov=.` or `go test -cover`) to verify coverage.
4. **Manual Polish**: If the generated tests require complex business logic mocks that cannot be inferred, implement the remaining mock logic manually.
