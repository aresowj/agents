---
name: antigravity-subagent-routing
description: Orchestrate bounded subagent work in Google Antigravity, including optional local llama.cpp inference. Use when delegating, parallelizing, or selecting between native Antigravity agents and locally available models.
---

# Antigravity Subagent Routing

## Discover the active capabilities

Use the tool descriptions and model choices exposed by the current Antigravity session as the source of truth. Model names and tool schemas change; do not infer support from examples or maintain a copied model catalog here.

Before dispatching, confirm the available subagent tool, its accepted agent types and model values, concurrency limits, isolation options, and whether the target may edit files. Use a read-only research persona for exploration when the runtime provides one.

## Choose native delegation or local inference

Prefer a native Antigravity subagent when the task needs repository tools, workspace state, structured progress, or isolated edits. Use a local OpenAI-compatible endpoint only when it is reachable and local inference provides a concrete benefit such as offline operation, privacy, or conserving hosted usage.

For local inference:

- Query `http://localhost:8080/v1/models` before selecting a model; never assume a preset still exists.
- Use the model identifier returned by the endpoint exactly.
- Send only the minimum required context and exclude secrets.
- Treat generated patches and claims as untrusted until the orchestrator applies and validates them.
- Bound time, output, and retries. Retry only safe requests and only when the failure appears transient.

Local HTTP completion is not a substitute for an editing agent: the orchestrator retains responsibility for file changes, permission checks, and tests.

## Route by task shape

- Use a higher-reasoning native tier for architecture, ambiguous multi-file changes, migrations, or difficult failure analysis.
- Use an efficient general tier for scoped implementation with clear acceptance criteria.
- Use a lightweight read-only tier for file discovery, search, log triage, and straightforward summaries.
- Keep sequential, tightly coupled, or interaction-heavy work in the parent context.

Select the lightest available option likely to complete the task reliably. Honor explicit user and repository choices, and escalate only after identifying why the first attempt was insufficient.

## Dispatch and ownership

Each subtask must include the objective, relevant paths, non-goals, edit permissions, acceptance criteria, validation commands, and required evidence. Assign non-overlapping writable areas. Use worktree or equivalent isolation when concurrent edits could otherwise collide.

The orchestrator owns cross-cutting decisions and interfaces. Establish a shared contract before parallelizing consumers that depend on it.

## Integrate

Inspect every returned diff or artifact, reconcile contradictions, and run final checks in the integrated workspace. Do not treat a confident report as proof. If a subtask fails, change the context, scope, or capability before retrying; avoid repeating the same dispatch unchanged.
