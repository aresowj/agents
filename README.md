# Agent Workflow Framework

A unified framework for agentic workflows and local development. This repository holds the centralized skills and rules for Google Antigravity and Pi Agent workflows.

## Features
- **Antigravity & Subagent Routing**: Optimizes agent delegation across Google Antigravity tiers (`pro`, `flash`, `flash_lite`) and local `llama.cpp` model presets.
- **Testing rituals**: Enforces 80% minimum coverage.
- **PR Rituals**: Uses `gh` CLI for creating PRs and writing descriptions.

## Repository Structure

### .pi/ - Pi Coding Agent Configuration
Local Pi agent settings and package list for easy reinstallation on new environments:
- `settings.json` - Pi agent configuration (theme, default provider/model, package list)
- `packages.json` - List of installed Pi packages with install instructions
- `models-store.json` - Model configuration and provider settings
- `auth.json` - Provider authentication configuration

### Skills
Custom skills and agent definitions used across projects, located at the root of the repository.

## Setup
1. Copy skills from the root directory to your local project's `.agents/skills/` directory, or symlink them, to use with Google Antigravity.
2. Ensure you have the `gh` CLI installed for PR rituals.

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
