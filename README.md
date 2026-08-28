# Agent Workflow Framework

A unified framework for agentic workflows, supporting Python and Go.

## Features
- **MCP Server**: Exposes tools for agents via Model Context Protocol.
- **Supervisor Routing**: Uses `litellm` to route tasks to specific personas via JSON execution plans.
- **Testing rituals**: Enforces 80% minimum coverage via `pytest` and `testify`.
- **PR Rituals**: Uses `gh` CLI for creating PRs and writing descriptions.

## Setup
1. `pip install -e .[dev]`
2. `pre-commit install`
3. Run the MCP server: `python -m mcp_server.server`
