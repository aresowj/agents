# External Skills Manifest

This file records skills installed outside this repository so the shared Codex skill set can be restored later.

## Installation Details

- Destination: `C:\Users\areso\.agents\skills`
- Installed: 2026-09-02
- Installer: `C:\Users\areso\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py`
- Restart Codex after restoring skills so they are discovered.

## Pinned Sources

### OpenAI Curated Skills

- Repository: `https://github.com/openai/skills.git`
- Ref: `49f948faa9258a0c61caceaf225e179651397431`
- Skills:
  - `gh-fix-ci` from `skills/.curated/gh-fix-ci`
  - `gh-address-comments` from `skills/.curated/gh-address-comments`
  - `security-best-practices` from `skills/.curated/security-best-practices`
  - `security-threat-model` from `skills/.curated/security-threat-model`
  - `playwright` from `skills/.curated/playwright`

### addyosmani Agent Skills

- Repository: `https://github.com/addyosmani/agent-skills.git`
- Ref: `d2c37ef6225dd8726cdd369a8030307f48592d26`
- Skills:
  - `spec-driven-development` from `skills/spec-driven-development`
  - `planning-and-task-breakdown` from `skills/planning-and-task-breakdown`
  - `incremental-implementation` from `skills/incremental-implementation`
  - `debugging-and-error-recovery` from `skills/debugging-and-error-recovery`

## Restore Commands

Run these commands from any directory with network access. The destination directory must exist and the listed skill directories must not already exist, because the installer refuses to overwrite an existing skill.

```powershell
$installer = 'C:\Users\areso\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py'
$destination = 'C:\Users\areso\.agents\skills'

python $installer --repo openai/skills --ref 49f948faa9258a0c61caceaf225e179651397431 --path `
  skills/.curated/gh-fix-ci `
  skills/.curated/gh-address-comments `
  skills/.curated/security-best-practices `
  skills/.curated/security-threat-model `
  skills/.curated/playwright `
  --dest $destination

python $installer --repo addyosmani/agent-skills --ref d2c37ef6225dd8726cdd369a8030307f48592d26 --path `
  skills/spec-driven-development `
  skills/planning-and-task-breakdown `
  skills/incremental-implementation `
  skills/debugging-and-error-recovery `
  --dest $destination
```

## Verification

Validate each restored skill with the local skill validator:

```powershell
$validator = 'C:\Users\areso\.codex\skills\.system\skill-creator\scripts\quick_validate.py'
Get-ChildItem $destination -Directory | ForEach-Object {
  python $validator $_.FullName
}
```

## Maintenance Rules

- Review external skill changes before updating the pinned ref.
- Preserve the source repository and skill path when updating an entry.
- Re-run validation after every restore or upgrade.
- Do not install an entire external collection globally without reviewing overlap, scripts, permissions, and activation behavior.
