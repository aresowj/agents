---
name: software-architecture
description: Designs and evaluates software architecture, boundaries, interfaces, tradeoffs, and design-pattern choices. Use when the user asks to architect, design a system, choose an architecture or design pattern, create an ADR, assess maintainability, or plan a substantial technical change.
---

# Software Architecture

## Start from forces, not patterns

Establish the problem, users, business outcome, constraints, quality attributes, data sensitivity, operational needs, and success measures. Inspect the existing system before proposing change: current boundaries, dependencies, data flows, deployment model, conventions, failure modes, and tests.

State assumptions and distinguish facts from inferences. Treat architecture as evolving: prefer the smallest reversible decision that meets the current need, with feedback and tests that preserve important qualities over time.

## Design the boundaries

Define responsibilities, ownership, interfaces, data lifecycle, synchronous and asynchronous flows, failure handling, observability, security, and deployment implications. Keep high-level policy independent of framework, transport, storage, and vendor details when that separation has clear value.

Choose abstractions around stable business concepts and change boundaries. Favor simple composition and explicit dependencies. Avoid distributed components, generic layers, plugin systems, queues, repositories, factories, or event buses unless a demonstrated force justifies their cost.

## Select patterns deliberately

Describe each candidate pattern as a tradeoff, not a default:

- Use **Strategy** for interchangeable behavior with a stable caller contract.
- Use **Adapter** or an anti-corruption layer at external or legacy boundaries.
- Use **Ports and Adapters / Hexagonal** architecture when core policy needs isolation from delivery and infrastructure.
- Use **CQRS** only when read and write models have materially different needs.
- Use **Events** for decoupled, durable facts and explicit eventual-consistency handling; do not use them as hidden RPC.
- Use **Domain-driven design** where a complex domain benefits from explicit bounded contexts and a shared language.

For every pattern, name the alternative, why it was rejected, coupling introduced, failure modes, and how it can be changed later.

## Make a decision record

Use this compact ADR or design-review structure:

```markdown
# [Decision]

## Context
[Problem, constraints, and non-goals]

## Decision
[Chosen boundaries, interfaces, data flow, and pattern]

## Consequences
[Benefits, costs, risks, operational impact, and migration]

## Alternatives considered
[Option and reason not chosen]

## Validation
[Tests, metrics, architecture fitness functions, rollout, and rollback]
```

Use diagrams only when they clarify relationships that prose cannot; keep them at the appropriate abstraction level and maintain them with the code.

## Validate before committing

Test the most consequential assumptions with a spike, prototype, load test, threat model, failure exercise, or contract test. Define measurable guardrails for critical qualities, such as latency, correctness, security, reliability, or dependency direction. Include migration, rollout, observability, and rollback for changes that affect production behavior or data.

Present a recommended option, its tradeoffs, evidence, and the next decision or experiment. Do not claim an architecture is future-proof; explain the changes it is designed to accommodate.
