# Agent Configuration

Portable Pi configuration and extensions for local agent workflows.

## Pi configuration

The `.pi/` directory contains settings and a package manifest for restoring a Pi environment. The root `@aresowj/pi-lazy-tools` Pi package provides the `lazy-tools` extension, which keeps heavyweight capability groups hidden until searched and activated. Install it with `pi install npm:@aresowj/pi-lazy-tools` after publishing.

Review `.pi/auth.json` before sharing or restoring configuration. Never commit live credentials.

External skills installed outside this repository are pinned in `EXTERNAL_SKILLS.md`.

## Validate changes

Run the repository hooks before submitting changes:

```powershell
pre-commit run --all-files
```

CI runs the repository hooks on pull requests and changes to `main`.
