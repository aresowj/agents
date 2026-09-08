---
name: pi-specific-agent-routing
description: Orchestrate bounded subagent and background work in Pi, including optional local-model execution. Use for Pi-specific delegation, parallel work, background tasks, or model selection.
---

# Pi-Specific Agent Routing

## Load the capability you need

Pi installations vary by package and version. Treat the current tool registry and returned tool documentation as authoritative. If delegation or background tools are hidden by a lazy loader, search for the capability first, activate only the relevant tool group, and then follow the discovered schema exactly.

Do not copy an API shape from this skill into a call. In particular, confirm the active runtime's names and parameters for subagents, parallel runs, background tasks, budgets, structured output, and worktree isolation before using them.

## Decide whether to delegate

Delegate work that is concrete, bounded, independently verifiable, and useful in parallel with parent work. Good candidates are read-only exploration, isolated implementation areas, test investigation, and independent review.

Keep work with the parent when it is trivial, sequential, requires frequent user interaction, or depends on shared mutable files. Use the fewest agents that create real parallelism, and assign one owner to each writable area.

## Select a model at runtime

Use configured Pi providers and currently available model identifiers rather than a static catalog. Inspect active settings or provider model discovery when model selection matters.

- Honor explicit user and project choices.
- Prefer an efficient model for retrieval and routine bounded work.
- Use stronger reasoning for architecture, ambiguous multi-file changes, hard debugging, or costly failure modes.
- Account for local RAM and VRAM before concurrent local runs; serialize work when models cannot coexist safely.
- Escalate only after identifying a concrete shortcoming in the prior attempt.

When using an OpenAI-compatible local endpoint, confirm availability and query its model list before dispatch. Send minimal context, exclude secrets, bound retries and output, and validate all generated changes in the parent workspace.

## Dispatch with explicit boundaries

Every subtask must define:

1. Objective and deliverable.
2. Relevant paths and non-goals.
3. Read-only or edit authorization and any allowed external effects.
4. Acceptance criteria and validation commands.
5. Required evidence: findings, files changed, checks run, and risks.

Use structured output when downstream automation genuinely consumes it. Apply tool and usage budgets proportional to the task when the active tool supports them; do not invent unsupported budget fields.

Use background execution only for work that can progress without interaction. Prefer completion events or bounded waits over frequent polling, and define a timeout or stopping condition for long-running work.

## Integrate and recover

Inspect returned files, diffs, sources, and test output directly. Reconcile conflicts centrally and run integrated validation. Subagent reports are not proof.

On failure, determine whether the cause is missing context, invalid assumptions, resource pressure, or a tool limitation. Retry only with a targeted correction. Cancel redundant work and surface blockers instead of silently looping or falling back to an unrelated model.
