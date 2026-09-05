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

When offline, preserving cloud quotas, or performing local batch tasks, Antigravity can interact directly with your local LLM engine via `http://localhost:8080/v1` (OpenAI-compatible REST API).

### Local LLM Endpoint Details
- **Base URL**: `http://localhost:8080/v1`
- **Models Endpoint**: `GET http://localhost:8080/v1/models`
- **Completions Endpoint**: `POST http://localhost:8080/v1/chat/completions`

### Local Model Profiles & Capabilities

Your local `llama.cpp` runtime maintains 21 configured model presets spanning various parameter sizes and quantization levels:

| Category / Tier | Available Local Presets | Strengths & Best Use Cases |
| :--- | :--- | :--- |
| **Heavy Coding & Architecture** | • `DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF:Q4_K_M`<br>• `qwen3.8-27b-ud-q6`<br>• `qwen3.8-27b-ud-q4`<br>• `qwen3.6-27b-q6`<br>• `qwen3.6-27b-q4`<br>• `qwen2.5-coder-32b-q5` | Complex coding, deep logic, full file refactoring, reasoning, test authoring. |
| **Generalist & Multi-Domain** | • `gemma-4-26b-a4b-q6`<br>• `gemma-4-26b-a4b-q5`<br>• `gemma-4-26b-a4b-q4`<br>• `devstral-small-2-24b-q4`<br>• `lfm2-24b-a2b-q4`<br>• `gpt-oss-20b-mxfp4` | Technical analysis, architectural reviews, structured data transformation, documentation. |
| **Reasoning Specialists** | • `ministral-14b-reasoning-q4`<br>• `ministral-8b-reasoning-q4` | Chain-of-thought verification, test edge-case discovery, bug root-cause analysis. |
| **Fast / Medium Coding** | • `qwen3.5-9b-deepseek-q8`<br>• `qwen3.5-9b-q8`<br>• `qwen3.5-9b-q4`<br>• `omnicoder-9b-q6`<br>• `lfm2-8b-a1b-q8` | Rapid single-function implementation, docstrings, boilerplate creation, unit test drafting. |
| **Ultra-Lightweight / Bulk** | • `qwen2.5-coder-1.5b-q8` | Fast regex generation, log filtering, token-efficient repetitive text transformations. |

---

## 3. Hybrid Routing Decision Tree

```
Does the task require cloud tool-use / subagent spawning inside Antigravity?
├── YES → Use native `invoke_subagent`
│   ├── Is it multi-file or high-risk? → `Model: "pro"`
│   ├── Is it a single-file edit or standard test? → `Model: "flash"`
│   └── Is it pure read-only research/grep? → `Model: "flash_lite"` with `research` subagent
│
└── NO (Offline, batch task, local inference script, or quota saving)
    └── Route to local `llama.cpp` API (http://localhost:8080/v1):
        ├── Deep reasoning / cross-file code → Qwen 27B/32B or Devstral 24B
        ├── Chain-of-thought analysis / logic debugging → Ministral 14B / 8B Reasoning
        ├── Standard function writing / editing → Qwen3.5 9B or OmniCoder 9B
        └── Fast text extraction / formatting → Qwen2.5-Coder 1.5B
```

---

## 4. Dispatch Guidelines for Antigravity

When dispatching work to a subagent:
1. **Explicit Boundaries**: Clearly state target files, functions, and non-goals.
2. **Acceptance Criteria**: State tests or checks that verify the solution.
3. **Report Back**: Require the subagent to report changed files, test output, and any remaining risks.
4. **No Nested Hierarchy**: Prefer a single level of well-scoped subagents reporting to the orchestrator.
