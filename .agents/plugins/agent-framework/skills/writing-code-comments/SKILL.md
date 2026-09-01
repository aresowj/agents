---
name: writing-code-comments
description: Writes and improves source-code comments, docstrings, TODOs, and API documentation that explain intent and contracts without duplicating code. Use when adding, revising, auditing, or asking how to write code comments, inline comments, doc comments, JSDoc, or docstrings.
---

# Writing Code Comments

## Comment only what code cannot say

Prefer clear names, small focused functions, types, and tests over comments that repeat the implementation. Add a comment when it explains a non-obvious decision, invariant, tradeoff, constraint, workaround, security property, performance reason, or externally imposed behavior.

Write for the next maintainer. State the reason and consequence, not a line-by-line paraphrase. Keep comments adjacent to the code they explain and update or delete stale comments in the same change.

## Choose the right form

- **Inline comment:** Explain *why* a local choice is surprising or necessary.
- **Doc comment / docstring:** Describe the public contract: purpose, inputs, return value, errors, side effects, constraints, and important usage notes. Follow the language and repository’s documentation conventions.
- **Module or file comment:** Explain responsibility, boundary, assumptions, and what does not belong there.
- **TODO:** Record tracked, actionable follow-up only. Use the repository’s format; otherwise write `TODO: <issue or condition> - <specific action>`. Never use a TODO to hide a known defect without a path to resolution.

## Write clearly

Use precise, complete sentences for documentation comments. Name the relevant symbol when the language convention expects it. Keep examples executable or validate them when practical. Avoid jokes, history that belongs in version control, vague warnings, redundant restatements, and implementation details likely to change.

```ts
// Preserve the server order: clients use it as a stable tie-breaker when scores match.
const ranked = sortByScore(items);

/**
 * Parses a signed callback and rejects expired or malformed payloads.
 *
 * @throws {InvalidCallbackError} When verification or decoding fails.
 */
function parseCallback(token: string): CallbackPayload { /* ... */ }
```

## Verify

Read the comment with its surrounding code and ask: would a future reader understand the decision or contract without it? If the answer is no, improve the code or comment. Confirm that identifiers, behavior, links, issue references, and examples remain accurate. Run the project's formatter, linter, documentation build, or tests when the comment format is machine-checked.
