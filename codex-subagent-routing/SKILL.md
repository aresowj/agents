---
name: codex-subagent-routing
description: Routes bounded, independently verifiable work to Codex subagents and synthesizes their results. Use when a task has parallel research, review, implementation, or validation workstreams, or when the user asks to delegate, use subagents, or run agents in parallel.
---

# Codex Subagent Routing

## Decide whether to delegate

Delegate only when the work is concrete, bounded, and can progress independently alongside useful parent work. Do not delegate a task merely because it is large, vague, or sequential. Keep work local when it requires frequent user interaction, depends on a shared mutable edit area, or needs the parent’s continuous judgment.

When in doubt, prefer fewer agents with better-scoped prompts over many small agents. Subagents should save time, not multiply overhead.

Before spawning, define the deliverable, relevant scope, acceptance criteria, and whether the agent may edit files. Give each agent a distinct ownership boundary; never assign overlapping edits in the same files unless coordinated sequentially.

## Route by task shape

- Parallelize independent discovery, code review, test investigation, or isolated modules.
- Keep design decisions, user communication, integration, and final validation with the parent.
- Use a specialist only when its instructions or tools materially improve the result.
- Prefer one agent per coherent outcome. Avoid a hierarchy of tiny tasks and avoid using agents for trivial lookups.

## Model Routing Table

Use the lightest model and effort level that can reliably finish the job. Choose the model and effort together; increase effort only when the task needs deeper reasoning, broader synthesis, or higher precision.

| Task type | Complexity | Recommended first pick | Other viable options | Notes |
|---|---:|---|---|---|
| Planning, decomposition, orchestration, and result synthesis | Any | `gpt-5.6-terra` (medium) | `gpt-5.6-luna` (low) for simple plans; `gpt-5.6-sol` (high or xhigh) for high-stakes or highly ambiguous work | The orchestrator owns scope, model selection, sequencing, quality checks, and final integration. |
| File search, repo reconnaissance, simple summaries | Low | `gpt-5.6-luna` (low) | `gpt-5.4` (low), `gpt-5.6-terra` (low) | Lightweight profile: use low effort when the answer is mostly retrieval or straightforward synthesis. |
| Small code edits, isolated bug fixes, straightforward tests | Low to medium | `gpt-5.6-luna` (low) | `gpt-5.4` (low), `gpt-5.6-terra` (medium) | Lightweight profile for bounded implementation work; increase effort when correctness is uncertain. |
| Multi-file implementation, moderate debugging, API wiring, refactors with clear boundaries | Medium | `gpt-5.6-luna` (medium) | `gpt-5.4` (medium), `gpt-5.6-terra` (medium or high) | Preferred default for most agent work when you want capability without spending too quickly. |
| Hard debugging, tricky regressions, design-sensitive changes, non-obvious failure analysis | Medium to high | `gpt-5.6-terra` (high) | `gpt-5.6-luna` (high), `gpt-5.6-sol` (xhigh) | Use higher effort when the task needs deeper reasoning or careful tradeoff handling. |
| Architecture decisions, cross-cutting synthesis, high-uncertainty investigations, critical review | High | `gpt-5.6-sol` (high) | `gpt-5.6-terra` (high), `gpt-5.6-luna` (xhigh only when cost is acceptable) | Reserve the strongest model and effort for the hardest work, or when lower tiers have stalled. |
| Long-running independent review or validation where cost matters more than speed | Low to medium | `gpt-5.6-luna` (low) | `gpt-5.4` (low), `gpt-5.6-terra` (medium) | Lightweight profile for broad sweeps, checklist-style validation, and first-pass triage. |

## Routing Rules

- Start with the lightweight profile, `gpt-5.6-luna` at low effort, for shallow discovery and bounded implementation unless the task is clearly complex.
- Default to `gpt-5.6-luna` at low or medium effort for most real coding subagents because it balances capability and usage efficiency well.
- Reach for `gpt-5.6-terra` at medium or high effort when the work is likely to involve subtle reasoning, cross-file impact, or hard-to-diagnose behavior.
- Reserve `gpt-5.6-sol` at high, xhigh, or max effort for the rare cases where the added reasoning quality is worth the extra usage.
- If a lower model or effort level produces incomplete, low-confidence, or repetitive output, retry once with the next model or effort tier up instead of jumping straight to the most expensive option.
- When splitting work across multiple agents, mix models intentionally: use cheaper models for reconnaissance and stronger models for the final hard slice.

## Orchestrate Subtasks

Use an orchestrator for any delegation workflow. The orchestrator may be the parent agent or a dedicated planning subtask, but it must remain responsible for the end-to-end result rather than treating subagent output as authoritative.

1. Decompose the request into bounded, independently verifiable subtasks.
2. Assign each subtask one clear owner, acceptance criteria, relevant context, and the model selected from the routing table.
3. Spin up each subtask separately with its assigned model. Do not make subagents choose their own model or silently expand their scope.
4. Ask every subagent to report its conclusion, evidence, changed files, validation performed, and unresolved risks.
5. Inspect each result against the acceptance criteria. Check the actual diff or evidence when available; do not rely on a confident-sounding summary.
6. Resolve conflicts, fill gaps, and decide whether a targeted retry or escalation is warranted.
7. Integrate the verified results and run final validation in the parent context.

For cost control, use `gpt-5.6-luna` at low effort when decomposition and verification are straightforward. Use `gpt-5.6-terra` at medium effort as the normal reasoning-oriented orchestrator, and escalate to `gpt-5.6-terra` at high effort before using `gpt-5.6-sol`. Use `gpt-5.6-sol` at high or xhigh effort only when the plan has high uncertainty, cross-cutting consequences, or unusually costly failure modes. Prefer one orchestrator plus a small number of well-scoped subtasks over multiple planning layers.

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
