# Agent Workflow Framework

A unified framework for agentic workflows, supporting Python and Go.

## Features
- **MCP Server**: Exposes tools for agents via Model Context Protocol.
- **Supervisor Routing**: Uses `litellm` to route tasks to specific personas via JSON execution plans.
- **Testing rituals**: Enforces 80% minimum coverage via `pytest` and `testify`.
- **PR Rituals**: Uses `gh` CLI for creating PRs and writing descriptions.

## Repository Structure

### .pi/ - Pi Coding Agent Configuration
Local Pi agent settings and package list for easy reinstallation on new environments:
- `settings.json` - Pi agent configuration (theme, default provider/model, package list)
- `packages.json` - List of installed Pi packages with install instructions
- `models-store.json` - Model configuration and provider settings
- `auth.json` - Provider authentication configuration

### .agents/ - User Skills and Agents
Custom skills and agent definitions used across projects.

## Setup
1. `pip install -e .[dev]`
2. `pre-commit install`
3. Run the MCP server: `python -m mcp_server.server`

### Pi Agent Setup (New Environment)
1. Install Pi packages:
```bash
npm install -g \
  @earendil-works/pi-coding-agent@latest \
  @earendil-works/pi-server@latest \
  @earendil-works/pi-client@latest
```
2. Copy `.pi/settings.json` to `~/.pi/agent/settings.json`
3. Install packages: Run `pi install <package>` for each package listed in `.pi/packages.json`
