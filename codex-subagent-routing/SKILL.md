---
name: codex-subagent-routing
description: Routes bounded, independently verifiable work to Codex subagents and synthesizes their results. Use when a task has parallel research, review, implementation, or validation workstreams, or when the user asks to delegate, use subagents, or run agents in parallel.
---

# Codex Subagent Routing

## Decide whether to delegate

Delegate only when the work is concrete, bounded, and can progress independently alongside useful parent work. Do not delegate a task merely because it is large, vague, or sequential. Keep work local when it requires frequent user interaction, depends on a shared mutable edit area, or needs the parent’s continuous judgment.

Before spawning, define the deliverable, relevant scope, acceptance criteria, and whether the agent may edit files. Give each agent a distinct ownership boundary; never assign overlapping edits in the same files unless coordinated sequentially.

## Route by task shape

- Parallelize independent discovery, code review, test investigation, or isolated modules.
- Keep design decisions, user communication, integration, and final validation with the parent.
- Use a specialist only when its instructions or tools materially improve the result.
- Prefer one agent per coherent outcome. Avoid a hierarchy of tiny tasks and avoid using agents for trivial lookups.

## Dispatch

Write a self-contained task prompt that includes:

1. The objective and exact boundaries.
2. Relevant paths, commands, constraints, and prior decisions.
3. Expected output or files to change.
4. Validation required before completion.
5. A request to report findings, changed files, tests, and unresolved risks.

Use full-history context only when it is necessary. Otherwise provide the minimal recent context needed to perform the task safely. Do not expose secrets or authorize external side effects unless the user has authorized them.

## Coordinate and integrate

Track agents by deliverable, not by activity. Continue parent work while agents run. Send a follow-up only to clarify a real gap or redirect a bounded task; interrupt work that becomes redundant or conflicts with the chosen approach.

When results arrive:

1. Inspect the actual diff, evidence, and tests; a subagent report is not proof.
2. Reconcile conflicts and make the final design decision in one place.
3. Run integration-level validation appropriate to the change.
4. Attribute remaining uncertainty clearly; do not claim unverified work is complete.

## Completion

Report the integrated outcome, files changed, validation performed, and any remaining risks. Do not expose internal agent chatter unless it materially helps the user.
