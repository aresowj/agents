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

### Direct Invocation Pattern (Zero-Configuration Integration)
Antigravity does not need any changes to global CLI settings (`settings.json`) or proxy layers to utilize local LLMs. Because Antigravity has native terminal execution capabilities (`run_command`), the orchestrator or subagent communicates directly with `llama.cpp` using HTTP requests:

1. **How It Works**:
   - The Antigravity orchestrator (e.g. Gemini 3.8 Flash / Gemini 3.1 Pro) manages the user conversation, workspace state, and tool permissions.
   - For offline tasks, boilerplate drafting, heavy code generation, or quota-saving batch edits, the agent crafts a scoped prompt with file context.
   - The agent calls `http://localhost:8080/v1/chat/completions` using `run_command` via `curl` or a Python one-liner.
   - The returned code is parsed, written to disk with write/replace tools, and validated locally against test suites.

2. **Standard Execution Example (`curl`)**:
   ```bash
   curl -s -X POST http://localhost:8080/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "devstral-small-2-24b-q4",
       "messages": [
         {"role": "system", "content": "You are an expert software engineer. Output only the requested code implementation without conversational filler."},
         {"role": "user", "content": "Implement a Python utility function that..."}
       ],
       "temperature": 0.2
     }'
   ```

3. **Python Script Pattern for Structured Tasks**:
   When prompting with large context or multiple files, write a scratch script in `<appDataDir>/brain/<conversation-id>/scratch/` and execute it:
   ```python
   import json, urllib.request

   payload = {
       "model": "devstral-small-2-24b-q4",
       "messages": [
           {"role": "system", "content": "You are a code generation agent."},
           {"role": "user", "content": prompt_with_context}
       ],
       "temperature": 0.1
   }
   req = urllib.request.Request(
       "http://localhost:8080/v1/chat/completions",
       data=json.dumps(payload).encode("utf-8"),
       headers={"Content-Type": "application/json"}
   )
   with urllib.request.urlopen(req) as resp:
       result = json.loads(resp.read().decode("utf-8"))
       print(result["choices"][0]["message"]["content"])
   ```

### Comprehensive Local Model Routing Table & Alternative Presets

All 21 model presets configured in your local environment are categorized below:

| Tier / Task Type | Default Model | Alternative Presets Available | Dispatch Scenario & Trade-offs |
| :--- | :--- | :--- | :--- |
| **1. Default Coding Agent & Multi-File Loops** | **`devstral-small-2-24b-q4`** *(Default)* | • `DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF:Q4_K_M`<br>• `qwen3.8-27b-ud-q6`<br>• `qwen3.8-27b-ud-q4`<br>• `qwen3.6-27b-q6`<br>• `qwen3.6-27b-q4` | **Autonomous coding loops, bug fixing, test authoring, refactoring.** Tailored for tool use, unified diff application, and repository editing. Use Qwen 3.8/3.6 alternatives for high-throughput or uncensored code modification. |
| **2. Deep Algorithmic Reasoning & Architecture** | `qwen2.5-coder-32b-q5` | • `gemma-4-26b-a4b-q6`<br>• `gemma-4-26b-a4b-q5`<br>• `gemma-4-26b-a4b-q4`<br>• `gpt-oss-20b-mxfp4` | Complex algorithmic reasoning, state machines, theoretical software architecture, formal contracts, and strict API specifications. |
| **3. Chain-of-Thought Root-Cause Analysis** | `ministral-14b-reasoning-q4` | • `ministral-8b-reasoning-q4`<br>• `qwen3.5-9b-deepseek-q8` | Step-by-step diagnostic reasoning, subtle race condition analysis, regression debugging, edge-case vulnerability discovery. |
| **4. Fast / Scoped Coding & Boilerplate** | `qwen3.5-9b-deepseek-q8` | • `omnicoder-9b-q6`<br>• `qwen3.5-9b-q8`<br>• `qwen3.5-9b-q4`<br>• `lfm2-24b-a2b-q4`<br>• `lfm2-8b-a1b-q8` | Fast routine function drafting, documentation comments, unit test stubs, high-throughput editing with low VRAM footprint. |
| **5. High-Throughput Parsing & Text Transforms** | `qwen2.5-coder-1.5b-q8` | • `lfm2-8b-a1b-q8` | Regex generation, log parsing, compiler output filtering, and token-efficient repetitive text transforms. |

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
        │   ├── ★ DEFAULT: `devstral-small-2-24b-q4`
        │   └── Alternatives: `DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF:Q4_K_M`, `qwen3.8-27b-ud-q6/q4`, `qwen3.6-27b-q6/q4`
        ├── Complex algorithms or mathematical logic?
        │   ├── Primary: `qwen2.5-coder-32b-q5`
        │   └── Alternatives: `gemma-4-26b-a4b-q6/q5/q4`, `gpt-oss-20b-mxfp4`
        ├── Chain-of-thought root-cause debugging?
        │   ├── Primary: `ministral-14b-reasoning-q4`
        │   └── Alternatives: `ministral-8b-reasoning-q4`, `qwen3.5-9b-deepseek-q8`
        ├── Fast function boilerplate / simple scripts?
        │   ├── Primary: `qwen3.5-9b-deepseek-q8`
        │   └── Alternatives: `omnicoder-9b-q6`, `qwen3.5-9b-q8/q4`, `lfm2-24b-a2b-q4`, `lfm2-8b-a1b-q8`
        └── Fast text extraction / regex parsing?
            ├── Primary: `qwen2.5-coder-1.5b-q8`
            └── Alternative: `lfm2-8b-a1b-q8`
```

---

## 4. Dispatch Guidelines for Antigravity

When dispatching work to a subagent:
1. **Explicit Boundaries**: Clearly state target files, functions, and non-goals.
2. **Acceptance Criteria**: State tests or checks that verify the solution.
3. **Report Back**: Require the subagent to report changed files, test output, and any remaining risks.
4. **No Nested Hierarchy**: Prefer a single level of well-scoped subagents reporting to the orchestrator.
