---
name: test_coverage
description: Guidelines for generating tests and enforcing the 80% minimum coverage rule.
---

# Test Coverage Enforcement

This repository strictly enforces an **80% minimum test coverage** for all Python and Go code. CI builds will fail if coverage drops below this threshold.

## Workflow

1. Whenever you modify or create a new functional file (`.py` or `.go`), you must ensure sufficient tests exist.
2. **Use the Tool**: Call the `generate_tests_for_coverage_tool` MCP tool, passing the path to the modified file and the language (`python` or `go`).
3. **Verify**: The tool will use the Supervisor LLM to read the source and scaffold the necessary `pytest` or `testify` tests to reach 80% coverage.
4. **Manual Polish**: Review the generated tests. If they require complex business logic mocks that the LLM could not guess, implement the remaining mock logic yourself.
