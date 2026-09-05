---
name: pi-specific-agent-routing
description: Routes tasks between Pi native subagents and local LLMs. Use when delegating subtasks, orchestrating multi-step work, or routing bounded coding/research tasks in Pi environments. Also use for Pi-specific workflows and model routing.
---

# Pi-Specific Agent Routing

This skill defines the subagent and model routing strategy when working with Pi (the coding agent framework). It coordinates between Pi native subagents and local OpenAI-compatible LLM instances.

## 1. Pi Native Subagents (`subagent` tool)

Pi provides native subagent delegation via the `subagent` tool with extensive capabilities for parallel workflows, async execution, and coordinated delegation.

### Native Subagent Routing Matrix

| Task Category | Subagent Type | When to Use | Model Recommendation |
| :--- | :--- | :--- | :--- |
| **Complex Implementation** | `worker` (pro) | Multi-file changes, architectural refactors, database schema/migrations, complex test suites | `devstral-small-2-24b-q4` or `qwen3.8-27b-ud-q4` |
| **Standard / Scoped Code** | `worker` (flash) | Single-file edits, bug fixes with diagnosed root cause, simple unit tests, i18n/localization updates | `qwen3.5-9b-deepseek-q8` or `omnicoder-9b-q6` |
| **Research & Exploration** | `researcher` | Grep/file searches, documentation queries, log review, read-only surveying | `qwen2.5-coder-1.5b-q8` or `lfm2-8b-a1b-q8` |
| **Code Review** | `reviewer` | Pull request review, code quality assessment, architecture evaluation | `qwen3.8-27b-ud-q4` or `gemma-4-26b-a4b-q4` |
| **Test Coverage** | `test_coverage` | Test generation, coverage analysis, edge case identification | `qwen3.5-9b-deepseek-q8` |
| **Documentation** | `writing-code-comments` | Code comments, docstrings, API documentation | `qwen3.5-9b-q8` |
| **Pull Requests** | `writing-pull-requests` | PR descriptions, change summaries, review guidelines | `qwen3.5-9b-q8` |
| **Software Architecture** | `software-architecture` | Architecture design, system planning, design patterns | `qwen2.5-coder-32b-q5` or `gemma-4-26b-a4b-q4` |

### Subagent Capabilities

- **Parallel execution**: Run multiple subagents simultaneously with `runs.all([...])`
- **Async workflows**: Background execution with `async: true`
- **Structured output**: Define output schemas for verified results
- **Tool budgeting**: Limit tool calls with `toolBudget`
- **Usage constraints**: Enforce token/cost limits with `usageBudget`
- **Isolation modes**: Worktree isolation with `isolation: "worktree"`

## 2. Local LLMs Integration

Pi can interact with local LLM engines via the `bg_run_pi_attested` tool for evidence-oriented direct Pi spawns, or through direct HTTP API calls.

### Local LLM Endpoint Details

- **Base URL**: `http://localhost:8080/v1` (OpenAI-compatible REST API)
- **Models Endpoint**: `GET http://localhost:8080/v1/models`
- **Completions Endpoint**: `POST http://localhost:8080/v1/chat/completions`

### Default Coding Agent Directive

> **Primary Default Coding Model**: `devstral-small-2-24b-q4`
> Unless a task requires a different specialist, route local coding, debugging, test fixing, and multi-file code editing tasks to **`devstral-small-2-24b-q4` by default**. Built specifically for agentic loops (68.0% SWE-bench Verified), it excels at repo navigation, unified diffs, tool calling, and test verification.
> *The orchestrator remains empowered to route to other models when task characteristics demand it*

### Comprehensive Local Model Routing Table

All configured model presets are categorized below:

| Tier / Task Type | Default Model | Alternative Presets | Dispatch Scenario |
| :--- | :--- | :--- | :--- |
| **Default Coding Agent** | **`devstral-small-2-24b-q4`** | • `DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF:Q4_K_M`<br>• `qwen3.8-27b-ud-q6`<br>• `qwen3.8-27b-ud-q4`<br>• `qwen3.6-27b-q6`<br>• `qwen3.6-27b-q4` | Autonomous coding loops, bug fixing, test authoring, refactoring |
| **Deep Algorithmic Reasoning** | `qwen2.5-coder-32b-q5` | • `gemma-4-26b-a4b-q6`<br>• `gemma-4-26b-a4b-q5`<br>• `gemma-4-26b-a4b-q4`<br>• `gpt-oss-20b-mxfp4` | Complex algorithms, state machines, theoretical architecture |
| **Chain-of-Thought Reasoning** | `ministral-14b-reasoning-q4` | • `ministral-8b-reasoning-q4`<br>• `qwen3.5-9b-deepseek-q8` | Diagnostic reasoning, race conditions, regression debugging |
| **Fast Coding & Boilerplate** | `qwen3.5-9b-deepseek-q8` | • `omnicoder-9b-q6`<br>• `qwen3.5-9b-q8`<br>• `qwen3.5-9b-q4`<br>• `lfm2-24b-a2b-q4`<br>• `lfm2-8b-a1b-q8` | Function drafting, documentation, unit tests |
| **High-Throughput Parsing** | `qwen2.5-coder-1.5b-q8` | • `lfm2-8b-a1b-q8` | Regex generation, log parsing, text transforms |

## 3. Hybrid Routing Decision Tree

```
Does the task require native Pi subagents?
├── YES → Use Pi subagent:
│   ├── Complex multi-file work? → `worker` with pro-tier model
│   ├── Single-file scoped work? → `worker` with flash-tier model
│   ├── Research/exploration? → `researcher`
│   ├── Code review? → `reviewer`
│   └── Specialized task? → Use specialized subagent
│
└── NO (Local batch task, offline, or quota saving)
    └── Route to local LLM API:
        ├── General coding/debugging?
        │   ├── ★ DEFAULT: `devstral-small-2-24b-q4`
        │   └── Alternatives: `qwen3.8-27b-ud-q6/q4`, `qwen3.6-27b-q6/q4`
        ├── Complex algorithms? → `qwen2.5-coder-32b-q5`
        ├── Root-cause debugging? → `ministral-14b-reasoning-q4`
        ├── Fast boilerplate? → `qwen3.5-9b-deepseek-q8`
        └── Text parsing? → `qwen2.5-coder-1.5b-q8`
```

## 4. Dispatch Guidelines for Pi

When dispatching work to a subagent:

1. **Explicit Boundaries**: Clearly state target files, functions, and non-goals
2. **Acceptance Criteria**: Define tests, checks, or evidence that verify completion
3. **Report Requirements**: Require subagents to report changed files, test output, and risks
4. **Structured Output**: Use `outputSchema` for verified, machine-readable results
5. **Tool Budgeting**: Set `toolBudget` to prevent runaway tool calls
6. **Usage Constraints**: Enforce limits with `usageBudget` for cost control

### Example Dispatch Patterns

#### Parallel Implementation with Review

```javascript
// Orchestrate parallel implementation and review
const results = await runs.all([
  {
    key: 'implementation',
    agent: 'worker',
    task: 'Implement the authentication middleware',
    model: 'qwen3.5-9b-deepseek-q8',
    outputSchema: {
      type: 'object',
      properties: {
        filesChanged: { type: 'array', items: { type: 'string' } },
        testsAdded: { type: 'array', items: { type: 'string' } },
        risks: { type: 'array', items: { type: 'string' } }
      }
    }
  },
  {
    key: 'tests',
    agent: 'test_coverage',
    task: 'Generate comprehensive tests for authentication',
    model: 'qwen3.5-9b-deepseek-q8'
  },
  {
    key: 'review',
    agent: 'reviewer',
    task: 'Review the authentication implementation',
    model: 'qwen3.8-27b-ud-q4',
    output: 'review-results.md'
  }
]);
```

#### Async Workflow with Background Processing

```javascript
// Start async workflow
const backgroundTask = subagent({
  agent: 'worker',
  task: 'Process large dataset in background',
  model: 'qwen3.5-9b-deepseek-q8',
  async: true,
  timeoutMs: 3600000 // 1 hour
});

// Continue with other work while background task runs
// ... other work ...

// Later, check results
await bg_wait({ id: backgroundTask.id });
const result = await bg_result({ taskId: backgroundTask.id });
```

#### Local LLM Integration Example

```javascript
// Use local LLM for offline processing
const response = await fetch('http://localhost:8080/v1/chat/completions', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    model: 'devstral-small-2-24b-q4',
    messages: [{ role: 'user', content: 'Analyze this code pattern...' }],
    temperature: 0.1
  })
});

const data = await response.json();
```

## 5. Workflow Patterns

### Incremental Implementation

Use `todo` for complex multi-step work:

1. Create tasks: `todo action=create subject="Research authentication options"`
2. Mark in progress: `todo action=update id=1 status=in_progress activeForm="researching auth options"`
3. Update dependencies: `todo action=update id=2 addBlockedBy=[1]`
4. Complete tasks: `todo action=update id=1 status=completed`

### Context Engineering

Use `ctx_index`, `ctx_search`, and `ctx_execute` for large-scale analysis:

```javascript
// Index documentation for later search
ctx_index({
  path: '/path/to/docs',
  source: 'project-docs'
});

// Search indexed content
const results = ctx_search({
  queries: ['authentication flow', 'error handling'],
  source: 'project-docs'
});

// Execute code analysis
const stats = ctx_execute({
  language: 'javascript',
  code: 'const files = fs.readdirSync("src"); console.log(files.filter(f => f.endsWith(".ts")).length);'
});
```

### Debugging Workflows

Systematic root-cause debugging:

1. Reproduce issue
2. Analyze logs with `ctx_execute`
3. Isolate component with bounded subagent
4. Apply fix and verify
5. Document root cause and solution

## 6. Best Practices

### When to Use Subagents

- **Good**: Independent, bounded tasks with clear acceptance criteria
- **Good**: Parallelizable work (implementation, testing, review)
- **Good**: Offloading research or exploration
- **Avoid**: Frequent user interaction or shared mutable state
- **Avoid**: Vague or open-ended tasks without clear boundaries
- **Avoid**: Tasks requiring continuous parent judgment

### Model Selection

- **Start lightweight**: Use smaller models for simple tasks
- **Escalate thoughtfully**: Move to larger models only when needed
- **Match capability to task**: Don't over-provision or under-provision
- **Consider cost**: Balance quality with usage constraints

### Error Handling

- Always include error handling in workflows
- Use `try/catch` blocks for subagent calls
- Implement retry logic for transient failures
- Provide fallback mechanisms

### Monitoring

- Track subagent progress with status checks
- Set appropriate timeouts
- Monitor tool budgets and usage
- Implement health checks for long-running tasks

## 7. Pi-Specific Tools

### Core Tools

- `subagent`: Native subagent delegation
- `bg_run`: Background task execution
- `bg_wait`: Wait for background tasks
- `bg_result`: Retrieve task results
- `bg_kill`: Stop running tasks
- `todo`: Task list management

### Context Tools

- `ctx_execute`: Sandboxed code execution
- `ctx_execute_file`: File-based code execution
- `ctx_index`: Content indexing
- `ctx_search`: Knowledge base search
- `ctx_batch_execute`: Parallel command execution

### Utility Tools

- `bg_run_pi_attested`: Evidence-oriented Pi spawns
- `bg_status`: Task status inspection
- `bg_logs`: Log retrieval
- `lens_diagnostics`: Code quality checks
- `lsp_diagnostics`: Language server diagnostics
- `lsp_diagnostics`: Language server diagnostics
