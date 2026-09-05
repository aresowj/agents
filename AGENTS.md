# Agent Guidelines & Workflow Rules

## Local Testing Before Every Push
- **Mandatory Local Testing**: Before every `git push` or Pull Request creation, you MUST run all relevant test suites and linters locally first (e.g., `python -m pytest`, `go test ./...`, `ruff check .`).
- **Never Rely on CI as a First Check**: Do NOT push untested changes or incremental fixes just to wait for remote CI to tell you if they pass. Always verify test outcomes and coverage locally beforehand.

## Antigravity (Google / Gemini) Agent & Subagent Routing

When working within Google Antigravity (AGY / Antigravity 2.0 / CLI), follow these rules for model orchestration and delegation:

### 1. Orchestrator Tier
- The primary orchestrator should be the strongest available reasoning model (e.g. **Gemini Pro** or **Claude Opus**).
- Avoid using Flash models as top-level orchestrators for non-trivial, multi-step workflows.

### 2. Antigravity Subagent Dispatch (`invoke_subagent`)
Use the `Model` argument when spawning subagents:
- **`pro`**: Complex implementations, multi-file refactoring, database migrations, architectural changes, or tricky integration test failures.
- **`flash`**: Single-file changes, scoped bug fixes with identified root causes, simple unit tests, localization, and lint fixes.
- **`flash_lite`**: Read-only codebase exploration, regex/grep searches, and file scanning (use `TypeName: "research"` with write tools disabled).
- **`inherit`**: Natural continuation of the orchestrator's immediate reasoning path.

### 3. Local LLMs Integration (`llama.cpp`)
An OpenAI-compatible `llama.cpp` server is available locally at `http://localhost:8080/v1` (with 21 presets configured):
- **Default Coding Agent**: **`devstral-small-2-24b-q4`** (Mistral 24B, 68% SWE-bench Verified). Use this as the **default** model for autonomous local coding, multi-file edits, bug fixes, and test authoring. The orchestrator may route to other models when specific trade-offs warrant it.
- **Deep Algorithmic & Theoretical Coding**: `qwen2.5-coder-32b-q5`, `qwen3.8-27b-ud-q6`, `qwen3.6-27b-q6`, or `DavidAU/Qwen3.8-27B-TURBO-...`.
- **Reasoning Specialists**: `ministral-14b-reasoning-q4`, `ministral-8b-reasoning-q4`.
- **Fast / Medium Coding (8B - 9B)**: `qwen3.5-9b-deepseek-q8`, `qwen3.5-9b-q8`, `omnicoder-9b-q6`, `lfm2-8b-a1b-q8`.
- **Bulk / Lightweight (1.5B)**: `qwen2.5-coder-1.5b-q8`.

Use local LLMs for offline work, quota conservation, or local inference scripts.
