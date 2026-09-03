---
name: software-architecture
description: Designs and evaluates software architecture, boundaries, interfaces, tradeoffs, and design-pattern choices. Use when the user asks to architect, design a system, choose an architecture or design pattern, create an ADR, assess maintainability, or plan a substantial technical change.
---

# Software Architecture

## Start from forces, not patterns

Establish the problem, users, business outcome, constraints, quality attributes, data sensitivity, operational needs, and success measures. Convert important quality attributes into scenarios with a trigger, expected behavior, measurable target, and priority. At minimum consider reliability, security, performance, scalability, availability, operability, maintainability, accessibility, cost, and time to change.

Inspect the existing system before proposing change: current boundaries, dependencies, data flows, deployment model, conventions, failure modes, ownership, and tests. Separate observed facts from assumptions and identify the decisions that are reversible versus expensive to change.

State assumptions and distinguish facts from inferences. Treat architecture as evolving: prefer the smallest reversible decision that meets the current need, with feedback and tests that preserve important qualities over time.

## Design the boundaries

Define responsibilities, ownership, interfaces, data lifecycle, consistency model, synchronous and asynchronous flows, failure handling, observability, security, and deployment implications. Align boundaries with cohesive business capabilities and team ownership where practical. Keep high-level policy independent of framework, transport, storage, and vendor details when that separation has clear value.

Choose abstractions around stable business concepts and change boundaries. Favor simple composition, explicit dependencies, and a modular monolith as the default when independent deployment or fault isolation is not a demonstrated need. Avoid distributed components, generic layers, plugin systems, queues, repositories, factories, or event buses unless a demonstrated force justifies their cost.

For distributed systems, define ownership of data and failure behavior explicitly. Use timeouts on remote calls, bounded retries with exponential backoff and jitter only for transient and safe-to-repeat operations, idempotency for retried commands, and circuit breakers or bulkheads where cascading failure is plausible. Do not hide network calls behind interfaces that look local.

Treat security and privacy as architectural concerns: define trust boundaries, authentication and authorization, secrets handling, data classification, encryption needs, abuse cases, audit requirements, and least-privilege access. Include observability as part of the design, with actionable logs, metrics, traces, health checks, and correlation identifiers.

## Common Patterns And Best Scenarios

Use the following catalog as a shortlist, not a default. Describe each candidate pattern as a tradeoff and select it only when its problem matches the system's forces.

| Pattern | Best scenario | Main tradeoff or warning |
|---|---|---|
| Layered architecture | A conventional application with clear presentation, application, domain, and infrastructure responsibilities | Can become a pass-through layer cake; enforce dependency direction. |
| Modular monolith | One deployable is sufficient, but the code needs strong internal boundaries and independent team ownership | Modules share a process and release; prevent direct cross-module data access. |
| Ports and Adapters / Hexagonal | Core policy must remain testable and isolated from delivery, storage, or vendor details | Adds interfaces and mapping; use only where the isolation pays for itself. |
| Clean architecture | Multiple outer mechanisms change independently and dependency inversion is valuable | Can create ceremony and overly abstract use cases in simple systems. |
| Microservices | Teams need independent deployment, scaling, or fault domains around well-understood business boundaries | Adds network, data consistency, deployment, and operations complexity. |
| Domain-driven design / bounded contexts | A complex domain has distinct models, terminology, and ownership boundaries | Not a reason to split a simple domain into many services. |
| Strategy | Several interchangeable algorithms or policies share a stable caller contract | Requires a meaningful variation point; avoid speculative strategies. |
| Adapter / anti-corruption layer | An external, legacy, or vendor model must not leak into the core domain | Adds translation code; keep mappings explicit and observable. |
| Facade / API gateway / BFF | Clients need a stable entry point, aggregation, protocol translation, or client-specific shaping | Can become a bottleneck or "god" service; keep ownership and scope narrow. |
| Repository | Domain code needs a collection-like abstraction over persistence and the persistence model is a real change boundary | Avoid generic CRUD repositories that obscure queries and transaction semantics. |
| Factory / Abstract Factory | Construction has complex invariants or must select a family of compatible implementations | A factory for trivial constructors is unnecessary indirection. |
| Decorator / middleware | Cross-cutting behavior such as authorization, metrics, caching, or tracing should compose around a stable contract | Ordering and hidden behavior can make debugging difficult. |
| CQRS | Read and write workloads, models, scaling, or authorization rules differ materially | Adds synchronization and eventual-consistency concerns; do not use for ordinary CRUD. |
| Event-driven / publish-subscribe | Independent consumers need durable facts and loose temporal coupling | Requires schemas, delivery semantics, replay strategy, and clear ownership; events are not hidden RPC. |
| Transactional outbox | A state change and its integration event must be published reliably from one service | Requires relay processing, deduplication, ordering decisions, and cleanup. |
| Event sourcing | The event history is itself a business asset and the domain benefits from reconstructing state from facts | Difficult schema evolution, projections, debugging, and data correction. |
| Saga / compensating transaction | A business workflow spans multiple services and cannot use one atomic transaction | Compensation is not a true rollback; design for partial completion and operator visibility. |
| Cache-aside | Read-heavy data is expensive to compute or fetch and stale data is acceptable within a defined bound | Invalidation, stampedes, stale reads, and memory cost need explicit policies. |
| Queue-based load leveling / competing consumers | Work can be asynchronous and traffic is bursty or processing needs independent scaling | Adds latency, retries, poison-message handling, and backpressure concerns. |
| Retry with backoff and jitter | Transient remote failures are expected and the operation is safe to repeat | Unbounded or synchronized retries create retry storms; pair with timeouts and a breaker where needed. |
| Circuit breaker | A dependency can remain unhealthy long enough that continued calls would exhaust resources | Requires useful health signals, half-open behavior, and fallback semantics. |
| Bulkhead | Workloads or tenants must fail independently to prevent cascading resource exhaustion | Partitioning costs capacity and operational complexity. |
| Strangler fig | A risky legacy migration benefits from incremental replacement behind a routing boundary | Needs a retirement plan and clear ownership to avoid a permanent hybrid. |

For every selected pattern, name the simpler alternative, why it was rejected, coupling introduced, failure modes, operational burden, migration path, and how the decision can be reversed or replaced later.

For every pattern, name the alternative, why it was rejected, coupling introduced, failure modes, and how it can be changed later.

## Make a decision record

Use this compact ADR or design-review structure:

```markdown
# [Decision]

Status: [Proposed | Accepted | Superseded | Deprecated]
Date: [YYYY-MM-DD]
Owners: [Team or individuals]

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
