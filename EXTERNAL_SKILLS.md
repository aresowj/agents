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
  - `api-and-interface-design` from `skills/api-and-interface-design`
  - `browser-testing-with-devtools` from `skills/browser-testing-with-devtools`
  - `ci-cd-and-automation` from `skills/ci-cd-and-automation`
  - `code-review-and-quality` from `skills/code-review-and-quality`
  - `code-simplification` from `skills/code-simplification`
  - `constraint-driven-development` from `skills/constraint-driven-development`
  - `context-engineering` from `skills/context-engineering`
  - `deprecation-and-migration` from `skills/deprecation-and-migration`
  - `documentation-and-adrs` from `skills/documentation-and-adrs`
  - `doubt-driven-development` from `skills/doubt-driven-development`
  - `frontend-ui-engineering` from `skills/frontend-ui-engineering`
  - `git-workflow-and-versioning` from `skills/git-workflow-and-versioning`
  - `idea-refine` from `skills/idea-refine`
  - `interview-me` from `skills/interview-me`
  - `observability-and-instrumentation` from `skills/observability-and-instrumentation`
  - `performance-optimization` from `skills/performance-optimization`
  - `security-and-hardening` from `skills/security-and-hardening`
  - `shipping-and-launch` from `skills/shipping-and-launch`
  - `source-driven-development` from `skills/source-driven-development`
  - `spec-driven-development` from `skills/spec-driven-development`
  - `planning-and-task-breakdown` from `skills/planning-and-task-breakdown`
  - `incremental-implementation` from `skills/incremental-implementation`
  - `debugging-and-error-recovery` from `skills/debugging-and-error-recovery`
  - `test-driven-development` from `skills/test-driven-development`
  - `using-agent-skills` from `skills/using-agent-skills`

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
  skills/api-and-interface-design `
  skills/browser-testing-with-devtools `
  skills/ci-cd-and-automation `
  skills/code-review-and-quality `
  skills/code-simplification `
  skills/constraint-driven-development `
  skills/context-engineering `
  skills/deprecation-and-migration `
  skills/documentation-and-adrs `
  skills/doubt-driven-development `
  skills/frontend-ui-engineering `
  skills/git-workflow-and-versioning `
  skills/idea-refine `
  skills/interview-me `
  skills/observability-and-instrumentation `
  skills/performance-optimization `
  skills/security-and-hardening `
  skills/shipping-and-launch `
  skills/source-driven-development `
  skills/spec-driven-development `
  skills/planning-and-task-breakdown `
  skills/incremental-implementation `
  skills/debugging-and-error-recovery `
  skills/test-driven-development `
  skills/using-agent-skills `
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
