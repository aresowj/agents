---
name: writing-pull-requests
description: Prepares focused, reviewable pull requests with clear titles, descriptions, validation evidence, and risk disclosure. Use when creating, drafting, updating, or writing a pull request, PR description, or request for code review.
---

# Writing Pull Requests

## Prepare a reviewable change

Inspect the repository's contribution guidance, PR template, branch policy, and checks before drafting. Keep the PR focused on one outcome. Split unrelated refactors, generated churn, drive-by formatting, and independent features into separate changes when practical.

Before requesting review, inspect the diff against the intended base branch. Verify behavior, tests, documentation, migrations, compatibility, and security implications. Use a draft PR for early feedback or CI while the work is incomplete.

## Write the PR

Use an imperative, outcome-oriented title under the repository's preferred length. The description should explain the change for a reviewer who has not followed the implementation:

```markdown
## Summary
- [What changed and why]
- [Key design choice, if it is not obvious]

## Validation
- [Command or check]: [result]
- [Manual scenario]: [result]

## Risks and rollout
- [Migration, compatibility, performance, security, rollback, or monitoring notes]

## Reviewer notes
- [Specific files, tradeoffs, or questions that need attention]
```

Use concrete facts rather than a diff narration. Link the issue, design record, incident, or dependency when it supplies context. Include screenshots or recordings for material UI changes. State skipped or failing checks plainly, with the reason and follow-up.

## Final review checklist

- The title, description, and commits match the actual diff.
- The diff has a single understandable purpose and no accidental files or secrets.
- Automated and relevant manual validation are recorded.
- Backward compatibility, data migration, flags, rollout, and rollback are addressed when applicable.
- Documentation and API contracts changed with the code when needed.
- Required reviewers, code owners, labels, and repository templates are honored.

Do not create, push, open, or modify a remote PR unless the user has authorized that external action. When only asked to write a PR, provide a ready-to-paste title and description.
