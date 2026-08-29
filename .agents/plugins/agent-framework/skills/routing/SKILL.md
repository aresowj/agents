---
name: subagent_routing
description: Workflow for routing complex tasks to specialized personas.
---

# Subagent Routing

When given a large, ambiguous, or multi-disciplinary task, do not immediately attempt to solve it entirely in your current context.

## Workflow

1. **Invoke the Supervisor**: Call the `route_task_tool` MCP tool, passing the user`s generic task description.
2. **Parse the Plan**: The tool will return a JSON Execution Plan specifying a specialized persona (e.g., `python_developer`, `go_developer`), the required context, and a step-by-step plan.
3. **Adopt the Persona**:
   - If the platform supports it (e.g., Antigravity `invoke_subagent`), spawn a subagent with the exact persona and plan.
   - Otherwise, adopt the persona yourself and execute the step-by-step plan exactly as the Supervisor outlined.
