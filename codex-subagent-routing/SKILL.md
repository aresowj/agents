---
name: codex-subagent-routing
description: Delegate bounded, independently verifiable work to Codex subagents and integrate the results. Use when the user requests subagents or when independent research, implementation, review, or validation streams can run concurrently.
---

# Codex Subagent Routing

## Decide whether delegation helps

Delegate only when a subtask has a concrete deliverable, a distinct ownership boundary, and a way to verify its result independently. Keep design decisions, user communication, integration, and final validation with the parent agent.

Good candidates include independent repository reconnaissance, isolated modules, focused test investigation, and an independent review after implementation. Keep work local when it is sequential, trivial, requires frequent user input, or would create overlapping edits in shared files.

Use the fewest agents that provide meaningful parallelism. Delegation should reduce elapsed time or add an independent perspective, not merely distribute activity.

## Select agents and models from the active runtime

Treat the models, reasoning levels, concurrency limits, and context-forking options exposed by the current Codex session as authoritative. Do not rely on a static model catalog in this skill.

- Inherit the parent model unless a different model or effort level has a clear task-specific benefit.
- Honor an explicit user or repository model choice.
- Use lower-cost profiles for retrieval and routine bounded work; reserve stronger reasoning for ambiguity, architecture, hard debugging, or high-cost failure.
- Escalate only after inspecting why an earlier attempt was insufficient. Avoid blind retries.
- Fork only the context the subtask needs. Never include secrets or unrelated user data.

## Dispatch with a contract

Every subtask prompt must state:

1. The objective and expected deliverable.
2. In-scope files or systems and explicit non-goals.
3. Whether edits or external side effects are authorized.
4. Acceptance criteria and required validation.
5. The evidence to report: findings, changed files, commands or checks run, and unresolved risks.

Assign one owner per writable area. Parallel agents may share read-only context, but they must not edit the same files concurrently. If work depends on another result, run it sequentially or establish the interface first.

## Coordinate without busywork

Continue useful parent work while agents run. Send follow-ups only to close a concrete gap or redirect scope. Interrupt work that has become redundant or conflicts with the selected approach. Prefer event-driven waits or longer bounded waits over frequent status polling.

Do not create nested agent hierarchies unless the runtime permits them and the extra layer has a clear coordination benefit. The parent remains accountable for the outcome regardless of delegation depth.

## Integrate and verify

Subagent output is evidence, not authority. Before accepting it:

1. Inspect the actual diff, files, sources, or command output.
2. Reconcile contradictions and overlapping recommendations in one place.
3. Run integration-level checks appropriate to the combined change.
4. Confirm that no subtask exceeded its permissions or scope.
5. Report the integrated outcome and remaining uncertainty, not internal agent chatter.

If an agent fails, identify whether the cause is missing context, an invalid assumption, a tool limitation, or insufficient reasoning. Retry only when a targeted change addresses that cause; otherwise finish locally or explain the blocker.
