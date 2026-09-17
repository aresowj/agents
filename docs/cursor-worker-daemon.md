# Cursor worker daemon (macOS)

Run `agent worker start` as a background service that survives terminal closes and restarts at login.

This repo includes scripts under `scripts/cursor-worker/` to install a **launchd LaunchAgent** on macOS. The worker registers this checkout with Cursor Cloud Agents as a **My Machines** worker.

## Prerequisites

1. Install the Cursor CLI:

   ```bash
   curl https://cursor.com/install -fsS | bash
   agent --version
   ```

2. Sign in once (browser login stores credentials for the worker):

   ```bash
   agent login
   ```

3. Clone this repository and `cd` into it.

## Quick install

From the repo root:

```bash
./scripts/cursor-worker/install.sh
./scripts/cursor-worker/status.sh
```

Defaults:

| Setting | Default |
| --- | --- |
| Worker name | `kagami` |
| Worker directory | This repository root |
| LaunchAgent label | `com.cursor.agent-worker` |
| Logs | `~/Library/Logs/cursor-agent-worker.{log,err.log}` |

You do **not** need to keep `agent worker start` running in a terminal after install.

## Configuration

Copy the example config and edit if needed:

```bash
cp scripts/cursor-worker/config.env.example scripts/cursor-worker/config.env
```

Supported variables:

- `WORKER_NAME` — name shown in Cursor and used with `worker=<name>` triggers
- `WORKER_DIR` — checkout exposed to Cloud Agents (must contain this repo's git remote)
- `AGENT_BIN` — path to the `agent` binary

`config.env` is gitignored so machine-specific overrides stay local.

Re-run `install.sh` after changing configuration.

## Manage the service

```bash
# Current health, process, debug report, and log tail
./scripts/cursor-worker/status.sh

# Restart after config or auth changes
./scripts/cursor-worker/restart.sh

# Remove the LaunchAgent and plist
./scripts/cursor-worker/uninstall.sh
```

Equivalent `launchctl` commands:

```bash
launchctl print gui/$(id -u)/com.cursor.agent-worker
launchctl kickstart -k gui/$(id -u)/com.cursor.agent-worker
launchctl bootout gui/$(id -u)/com.cursor.agent-worker
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.cursor.agent-worker.plist
```

## Use the machine from Cursor

1. Open [cursor.com/agents](https://cursor.com/agents).
2. Choose worker **`kagami`** in the environment selector.
3. Or trigger explicitly from integrations:
   - Slack: `@Cursor worker=kagami fix the test`
   - GitHub: `@cursoragent worker=kagami fix the test`

The worker advertises `repo=aresowj/agents` from this checkout's git remote.

## How it works

The LaunchAgent runs:

```bash
agent worker --worker-dir <repo> --name kagami start
```

- **RunAtLoad** — starts when you log in (including after reboot)
- **KeepAlive** — relaunches if the worker exits
- Outbound HTTPS only; no inbound ports required

See Cursor docs: [My Machines](https://cursor.com/docs/cloud-agent/self-hosted-guides/my-machines)

## Troubleshooting

Preflight check:

```bash
agent worker debug
```

Common issues:

| Symptom | Fix |
| --- | --- |
| Machine missing in Cursor | Confirm service is running: `./scripts/cursor-worker/status.sh` |
| `another worker daemon is already running` | Stop foreground `agent worker start` or run `restart.sh` |
| Auth errors after reinstall | Run `agent login`, then `./scripts/cursor-worker/restart.sh` |
| Wrong repo matched | Set `WORKER_DIR` to this checkout and re-run `install.sh` |

Logs:

- `~/Library/Logs/cursor-agent-worker.log`
- `~/Library/Logs/cursor-agent-worker.err.log`

## Optional worker flags

To enable features such as `--computer-use` or extra `--worker-dir` paths, edit `scripts/cursor-worker/com.cursor.agent-worker.plist.in`, then re-run `install.sh`.

Place worker flags **before** `start` in the plist `ProgramArguments` array, per Cursor CLI docs.
