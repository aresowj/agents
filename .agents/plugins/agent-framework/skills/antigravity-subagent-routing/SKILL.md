---
name: antigravity-subagent-routing
description: Routes tasks between Antigravity orchestrators (Gemini Pro, Claude Opus) and subagents (pro, flash, flash_lite, inherit) or local llama.cpp LLMs. Use when delegating subtasks, orchestrating multi-step work, or routing bounded coding/research tasks in Google Antigravity.
---

# Antigravity Subagent Routing

This skill defines the subagent and model routing strategy when working inside Google Antigravity (AGY / Antigravity 2.0 / CLI). It coordinates between cloud foundation models (Google Gemini, Claude) and your local OpenAI-compatible `llama.cpp` LLM instances running on `http://localhost:8080`.

## 1. Antigravity Native Subagents (`invoke_subagent`)

Antigravity provides native background subagent invocation via the `invoke_subagent` tool:
- `TypeName`: Subagent persona (e.g. `self` to inherit full toolset, or `research` for read-only codebase exploration).
- `Role`: 2-5 word job description (e.g. `Database Debugger`, `Frontend Engineer`).
- `Model`: Target capability tier:
  - `pro`: High-reasoning model (Gemini Pro / Claude 3.7/Sonnet/Opus tier).
  - `flash`: Fast, efficient model (Gemini Flash tier).
  - `flash_lite`: Lightweight model for high-throughput, low-reasoning read tasks.
  - `inherit`: Inherits the orchestrator's current model.

### Native Antigravity Routing Matrix

| Task Category | Antigravity `Model` Value | Antigravity Subagent Type | When to Use |
| :--- | :--- | :--- | :--- |
| **Complex Implementation** | `pro` | `self` | Multi-file changes, architectural refactors, database schema/migrations, complex test suites, API contracts. |
| **Standard / Scoped Code** | `flash` | `self` | Single-file edits, bug fixes with diagnosed root cause, simple unit tests, i18n/localization updates. |
| **Research & Exploration** | `flash_lite` (or `flash`) | `research` | Grep/file searches, documentation queries, log review, read-only surveying that would clutter parent context. |
| **Natural Chain Extension** | `inherit` | `self` | Bounded tasks directly continuing the orchestrator's immediate reasoning line. |

---

## 2. Local LLMs Integration (`llama.cpp` / OpenAI API)

When running offline, conserving cloud rate limits, or delegating local code execution, Antigravity can interact directly with your local LLM engine via `http://localhost:8080/v1` (OpenAI-compatible REST API).

### Local LLM Endpoint Details
- **Base URL**: `http://localhost:8080/v1`
- **Models Endpoint**: `GET http://localhost:8080/v1/models`
- **Completions Endpoint**: `POST http://localhost:8080/v1/chat/completions`

### Default Coding Agent Directive
> **Primary Default Coding Model**: `devstral-small-2-24b-q4`
> Unless a task requires a different specialist, the orchestrator SHOULD route local coding, debugging, test fixing, and multi-file code editing tasks to **`devstral-small-2-24b-q4` by default**. Built specifically for agentic loops (68.0% SWE-bench Verified), it excels at repo navigation, unified diffs, tool calling, and test verification.
> *The orchestrator remains empowered to route to other models when task characteristics demand it* (e.g., deep mathematical reasoning, fast regex filtering, or specialized logic).

### Local Model Routing Table

| Tier / Category | Primary Model | Alternative Presets | Strengths & Dispatch Scenario |
| :--- | :--- | :--- | :--- |
| **Default Coding Agent** | **`devstral-small-2-24b-q4`** *(Default)* | `DavidAU/Qwen3.8-27B-TURBO-...` | **Autonomous coding loops, bug fixing, test writing, refactoring.** Tailored for tool use, git diff application, and repository editing. |
| **Deep Reasoning & Architecture** | `qwen2.5-coder-32b-q5` | `qwen3.8-27b-ud-q6`, `qwen3.6-27b-q6` | Complex algorithmic reasoning, deep math/logic, large system architecture planning, theoretical design. |
| **Logic & Root-Cause Analysis** | `ministral-14b-reasoning-q4` | `ministral-8b-reasoning-q4` | Chain-of-thought diagnostics, edge-case vulnerability discovery, root-cause verification for elusive bugs. |
| **Fast / Scoped Coding** | `qwen3.5-9b-deepseek-q8` | `qwen3.5-9b-q8`, `omnicoder-9b-q6`, `lfm2-8b-a1b-q8` | Fast routine functions, boilerplate generation, unit test stubs, high-throughput editing with low VRAM. |
| **Lightweight Recon & Formatting** | `qwen2.5-coder-1.5b-q8` | — | Regex crafting, log parsing, token-efficient repetitive text transformations. |

---

## 3. Hybrid Routing Decision Tree

```
Does the task require native Antigravity subagents (`invoke_subagent`)?
├── YES → Use Antigravity subagent tier:
│   ├── Is it multi-file or high-risk? → `Model: "pro"`
│   ├── Is it a single-file edit or standard test? → `Model: "flash"`
│   └── Is it pure read-only research/grep? → `Model: "flash_lite"` (`research`)
│
└── NO (Local batch task, local inference script, offline, or quota saving)
    └── Route to local `llama.cpp` API (http://localhost:8080/v1):
        ├── General coding / bug fixing / agentic edit loop?
        │   └── ★ DEFAULT: `devstral-small-2-24b-q4`
        ├── Complex algorithms or mathematical logic?
        │   └── `qwen2.5-coder-32b-q5` or `qwen3.8-27b-ud-q6`
        ├── Chain-of-thought root-cause debugging?
        │   └── `ministral-14b-reasoning-q4`
        ├── Fast function boilerplate / simple scripts?
        │   └── `qwen3.5-9b-deepseek-q8` or `omnicoder-9b-q6`
        └── Fast text extraction / regex parsing?
            └── `qwen2.5-coder-1.5b-q8`
```

---

## 4. Dispatch Guidelines for Antigravity

When dispatching work to a subagent:
1. **Explicit Boundaries**: Clearly state target files, functions, and non-goals.
2. **Acceptance Criteria**: State tests or checks that verify the solution.
3. **Report Back**: Require the subagent to report changed files, test output, and any remaining risks.
4. **No Nested Hierarchy**: Prefer a single level of well-scoped subagents reporting to the orchestrator.
