---
name: subagent-model-routing
description: Routes tasks between high-reasoning orchestrators and efficient local subagents, optimized for single-large-model or multi-small-model resource constraints.
---

# Subagent Model Routing (OpenCode + Local LLM Dev)

This skill optimizes agentic workflows on hardware constrained by VRAM/RAM, prioritizing a "Plan Deeply, Execute Efficiently" cycle. It manages the transition between high-reasoning orchestrators and fast local subagents.

## Core Strategy: The Plan-Execute Cycle

To respect hardware limits (one large model OR multiple small models), all workflows should follow two distinct phases:

1.  **Planning Phase (The Brain):** Use a single, massive reasoning model to decompose the request into a complete execution plan and assign specific subagent models to each task.
2.  **Execution Phase (The Workers):** Unload the large model and load a specialized pool of smaller, faster models to perform the actual implementation.

## Model Routing Table

| Task Category | Recommended Model(s) | Resource Profile | Loading Strategy |
| :--- | :--- | :--- | :--- |
| **Orchestration & Planning** | `gpt-oss 120b` (RAM), OpenAI Codex | Very Large (Single) | Load once. Plan all subtasks, then **unload** before execution. |
| **Default Coding Agent** | **`devstral small 2 24b instruct`** *(Default)* | Medium/Large | Primary default for autonomous code editing, bug fixing, test writing, and multi-file changes. Orchestrator may override if specialist logic is required. |
| **Deep Reasoning & Architecture** | `qwen2.5 coder 32b instruct`, `gpt-oss 20b` | Medium/Large | Unload Orchestrator. Complex algorithms, theoretical designs, or deep math/logic. |
| **Standard / Lightweight Coding** | `gemma-4-26b-a4b-it-ud@q5_k_m`, `omnicoder 9b` | Medium | Can be loaded alongside very small models for routine boilerplate. |
| **Fast/Simple Tasks** | `qwen2.5 coder 1.5b instruct` | Small | Load multiple in parallel for high-throughput, low-reasoning work (regex, log filtering). |


## Routing Rules

### 1. The Orchestration Mandate
*   **Never** attempt to use a subagent to plan its own complex task if it requires high reasoning.
*   The **Orchestrator** must define:
    *   Clear boundaries for each subtask.
    *   The specific model assigned to the subtask (based on the table above).
    *   The expected deliverable and validation criteria.

### 2. Resource Management (VRAM/RAM Hygiene)
*   **Transition Rule:** Before starting any execution phase, ensure the Orchestrator (`gpt-oss 120b`) is unloaded to free up resources for subagents.
*   **Concurrency Rule:** Only attempt parallel subagent execution if the models selected are within the "Small" or "Medium" categories and fit within current hardware limits.

### 3. Model Selection Logic
*   **Complexity Check:** If a task requires cross-file reasoning or architectural understanding, assign a `Complex Implementation` model.
*   **Speed Check:** For reconnaissance (searching files, reading logs), always default to the `Fast/Simple` tier (`qwen2.5 coder 1.5b`).

## Execution Workflow

1.  **Decompose:** The Orchestrator (`gpt-oss 120b`) receives the user prompt and generates a detailed task list.
2.  **Assign:** For each task, the Orchestrator selects a model from the Routing Table based on complexity.
3.  **Transition:** User/System unloads `gpt-oss 120b`.
4.  **Execute:** Subagents are invoked using their assigned models.
5.  **Verify & Synthesize:** Results are collected and passed back to a final validation step (which may require re-loading the Orchestrator if the synthesis is highly complex).

## Dispatching a Subtask

When spawning a subagent, the prompt must include:
1.  **Assigned Model:** Explicitly state which model this agent should use.
2.  **Task Boundary:** Exact files and functions to touch.
3.  **Success Criteria:** What constitutes a "done" state.
4.  **Reporting Requirements:** Changes made, tests run, and any new uncertainties discovered.
