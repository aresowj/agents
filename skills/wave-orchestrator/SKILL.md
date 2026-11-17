---
name: wave-orchestrator
description: Execute pre-written plans in plans/*.md as dependency-ordered parallel waves, one isolated Git worktree per plan, using headless OpenCode workers launched only through the run-worker wrapper. Use when asked to implement, orchestrate, schedule, resume, or merge a plans/ backlog, or to run several plan files in parallel and merge the results.
---

# Wave Orchestrator

You are the orchestrator for a backlog of pre-written plans. You do not implement
plans yourself; you schedule them, launch one worker per plan, verify their
branches, and merge them into `main` wave by wave.

## Operating contract

- **One model for workers.** `opencode-go/deepseek-v4.1-flash`, set explicitly.
  Do not change it, do not pass a different `--model`, and do not spawn
  subagents, reviewers, or helper agents for this workflow. The orchestrator
  also verifies, merges, and fixes scheduling itself.
- **One worker per worktree, one worktree per plan.** Never point two workers at
  the same directory or at overlapping files.
- **The wrapper is the only launch path.** Never run `opencode run` directly.
  Never let worker stdout/stderr reach the orchestrator's context.
- **Context hygiene.** From a worker you may inspect only three things: its exit
  code, `git -C <worktree> diff --stat`, and `tail -n 30 <log>`. Never `cat`,
  `grep -c`, or summarize a full worker log. Never paste the whole test output
  into context; keep a bounded tail.
- **No publishing.** Do not push, open PRs, deploy, or publish unless the user
  asks. Merges are local. Never force-push or delete branches with unmerged work.
- **`plans/STATUS.md` is yours alone.** Workers must not edit it. Keep it
  current at every transition, not only at the end.

## Inputs and preconditions

Run from the repository that owns `plans/`. Confirm before scheduling:

1. `plans/*.md` exists and each file has enough detail to implement (scope,
   files, acceptance criteria, verification command). A plan without a file list
   is still runnable, but it must be scheduled alone in its wave.
2. The plans are committed on the base branch; workers get a clean checkout.
3. Working tree is clean, or unrelated user changes are understood and left
   untouched. Never stash, reset, or discard user work.
4. `run-worker` resolves (`command -v run-worker`), else use
   `$HOME/agents/scripts/run-worker.sh`. Read it once per session if you have not
   already; it already pins the default model and redirects both streams.
5. Pick the base branch (`main` unless the user names another) and record its
   SHA. If the user asked for a push/PR workflow, fetch and merge upstream
   `main` first; otherwise do not touch the remote.
6. Set the concurrency cap. Default **3**, maximum 4. More workers than that
   slows every worker and multiplies context-free failures.

## Step 1 — Read plans and build the wave schedule

Read every plan file. For each, extract:

- id and title, dependencies it names
- files/directories it creates or modifies
- verification command and any required setup (env, migrations, generated code)
- risky shared surfaces: route registries, DI wiring, package manifests and
  lockfiles, migrations, generated clients, shared types/constants, config files

Then group plans into waves:

- A plan may share a wave only if its file set is **provably disjoint** from every
  other plan in that wave.
- Anything that touches the same manifest/lockfile, migration chain, route table,
  shared type module, or config file is **serialized** even if the rest of its
  files differ.
- When a plan does not enumerate its files, or its scope is vague, it runs alone
  in its own wave.
- Dependencies are transitive: a wave starts only when every plan it depends on
  is merged and green.
- Prefer smaller waves that merge cleanly over a large wave that conflicts at
  merge time.

Write the result to `plans/STATUS.md` before launching anything:

```markdown
# Plan Execution Status

Updated: <ISO timestamp>
Base: main @ <sha>
Worker model: opencode-go/deepseek-v4.1-flash
Concurrency: <n>

## Schedule

| Wave | Plan | Branch | Worktree | Depends on | Files owned | Status |
| ---- | ---- | ------ | -------- | ---------- | ----------- | ------ |
| 1 | plans/001-api.md | feat/001-api | ../repo-wt-001-api | — | internal/api/** | queued |
| 1 | plans/002-ui.md  | feat/002-ui  | ../repo-wt-002-ui  | — | app/(tabs)/** | queued |
| 2 | plans/003-db.md  | feat/003-db  | ../repo-wt-003-db  | 001 | db/migrations/** | blocked |

## Parallel-wave rationale

- Wave 1: 001 and 002 touch disjoint trees; no shared manifest changes.
- Wave 2: 003 depends on 001's API types and edits the migration chain.

## Shared surfaces / serialization decisions

<list, with the file that forces the ordering>

## Verification log

| Plan | Command | Result | Evidence |
| ---- | ------- | ------ | -------- |

## Blocked / needs human

<empty, or one line per blocker with log path and failing command>
```

Status vocabulary: `queued`, `running`, `verifying`, `retry-1`/`retry-2`/`retry-3`,
`merged`, `blocked`, `failed`.

Show the schedule to the user, then launch Wave 1 without waiting for further
approval unless a plan is ambiguous or the user asked to review the schedule
first.

## Step 2 — Create worktrees for the wave

Use deterministic, sanitized names (lowercase, `[a-z0-9-]` only):

```bash
set -euo pipefail
REPO=$(git rev-parse --show-toplevel)
BRANCH=feat/<id>
WT="$(dirname "$REPO")/$(basename "$REPO")-wt-<id>"

git rev-parse --verify --quiet "refs/heads/$BRANCH" >/dev/null && {
  echo "branch already exists: $BRANCH" >&2; exit 1
}
git worktree add "$WT" -b "$BRANCH" main
```

Rules:

- Never create a worktree inside the repository; use a sibling directory.
- Never reuse an existing branch blindly. If `feat/<id>` already exists, either
  resume it (it is this plan's prior attempt) or use `feat/<id>-r2`; never
  `-f`/force.
- If `git worktree add` fails, fix the cause or mark the plan `blocked`. Do not
  fall back to running two workers in one directory.
- Each worktree is created from the current tip of `main`, so later waves pick
  up earlier merges automatically.

## Step 3 — Launch the wave

Launch every plan in the current wave in parallel and block until all exit:

```bash
set -euo pipefail
export OPENCODE_WORKER_MODEL=opencode-go/deepseek-v4.1-flash
export OPENCODE_WORKER_LOG_DIR="${TMPDIR:-/tmp}/opencode-orchestrator"
mkdir -p "$OPENCODE_WORKER_LOG_DIR"
WORKER=$(command -v run-worker || echo "$HOME/agents/scripts/run-worker.sh")
REPO=$(git rev-parse --show-toplevel)
WT_ROOT="$(dirname "$REPO")/$(basename "$REPO")-wt"

pids=""
"$WORKER" "$WT_ROOT-001" "$REPO/plans/001-api.md" w1-001-api & pids="$pids $!"
"$WORKER" "$WT_ROOT-002" "$REPO/plans/002-ui.md"  w1-002-ui  & pids="$pids $!"

fail=0
for pid in $pids; do wait "$pid" || fail=1; done
exit "$fail"
```

Notes:

- Log names must be unique per run (`w<wave>-<id>`); `run-worker` writes
  `<log-dir>/opencode-<log-name>.log`. If two runs would share a log name, the
  second silently overwrites the first.
- Never `--model` anything, never `--dir` (unsupported), and never launch a
  worker without the wrapper's redirection.
- Update `plans/STATUS.md` to `running` for each launched plan before you `wait`.
- If the harness supports background commands, launch the wave once in the
  background and wait for completion notification instead of polling. Do not
  sleep-and-check loops.

## Step 4 — Triage each worker

For each plan, inspect only:

1. the summary line / exit code (`worker=<id> exit=<code> log=<path>`, where the
   log is `$OPENCODE_WORKER_LOG_DIR/opencode-<log-name>.log`)
2. `git -C "$WT" diff --stat main...HEAD` and `git -C "$WT" log --oneline main..HEAD`
3. `tail -n 30 "$LOG"` on failure, plus `git -C "$WT" status --short`

Accept a worker result only if:

- exit code is `0`
- at least one commit exists on the branch
- the diff stays inside the plan's declared file set; flag (do not silently
  merge) changes to `plans/`, `plans/STATUS.md`, lockfiles, or unrelated modules
- the working tree is clean (worker committed its work)

Mark `failed` and move to the fix loop when exit is non-zero, the worker produced
no commit, or the diff is out of scope.

## Step 5 — Verify and repair

Run the project's real suite inside the worktree, in the foreground, redirecting
large output to a log:

```bash
set -euo pipefail
REPO=$(git rev-parse --show-toplevel)
WT="$(dirname "$REPO")/$(basename "$REPO")-wt-<id>"
export OPENCODE_WORKER_LOG_DIR="${TMPDIR:-/tmp}/opencode-orchestrator"
cd "$WT"
# Go Workers
go vet ./... && go test ./... 2>&1 | tee "$OPENCODE_WORKER_LOG_DIR/verify-<id>.log"
# Node / Expo / React Native
npx tsc --noEmit 2>&1 | tee "$OPENCODE_WORKER_LOG_DIR/verify-<id>.log"
npm test 2>&1 | tee -a "$OPENCODE_WORKER_LOG_DIR/verify-<id>.log"
```

Detect, don't guess: `go.mod` → Go commands; `package.json` scripts → use the
repo's own `test`/`typecheck`/`lint` scripts; Expo/React Native with
`tsconfig.json` → `npx tsc --noEmit`; then any extra commands the plan requires
(migrations, codegen, `go build`). If the repo defines a CI-equivalent script,
prefer it. If the plan names a verification command, that command is mandatory.

Record the command and result in `plans/STATUS.md`.

### Retry loop (max 3 attempts per plan)

On red, do not fix the code yourself and do not paste the full log. Write a
bounded retry plan and hand it back to the same worktree:

```bash
cat > "$OPENCODE_WORKER_LOG_DIR/retry-<id>-<n>.md" <<EOF
# Retry <n> for <id>

Original plan: <absolute path to plans/<id>.md>
Stay on branch feat/<id> in this worktree. Fix the failures below without
expanding the plan's scope. Do not edit plans/ or plans/STATUS.md.

## Verification command

<exact command>

## Failure output (tail)

<last 40 lines, secrets redacted>

## Already committed on this branch

$(git -C "$WT" log --oneline main..HEAD)

## Definition of done

- <command> exits 0
- no changes outside <declared file set>
- all work committed
EOF

"$WORKER" "$WT" "$OPENCODE_WORKER_LOG_DIR/retry-<id>-<n>.md" "w<wave>-<id>-r<n>"
```

Then re-run Step 5 from the top. After 3 failed attempts, mark the plan
`blocked`, keep the worktree and branch for a human, and continue with plans
that do not depend on it.

## Step 6 — Merge and close

Merge only plans that are green **and** cleanly scoped. One plan at a time:

```bash
set -euo pipefail
REPO=$(git rev-parse --show-toplevel)
WT="$(dirname "$REPO")/$(basename "$REPO")-wt-<id>"
cd "$REPO"
git switch main

# Guard: worktree must be clean and contain commits.
test -z "$(git -C "$WT" status --porcelain)"
git -C "$WT" log --oneline main..HEAD

git merge --no-ff "feat/<id>" -m "merge: <id> (<plan file>)"
```

If the merge conflicts:

```bash
git merge --abort
```

...mark the plan `blocked` with the conflicting paths, keep branch and worktree,
and report. Do not resolve conflicts by guessing and do not force the merge.
Re-run the affected verification after any conflict resolution a human performs.

After a clean merge:

1. Re-run the verification that is cheap enough on `main` (at minimum the
   affected package's tests/typecheck) and record it.
2. `git worktree remove "$WT"` — if it refuses because of untracked files,
   inspect them first; never `--force` while work could be unmerged.
3. `git branch -d "feat/<id>"`.
4. Set the plan `merged` with the merge commit SHA in `plans/STATUS.md`.
5. Commit the status update on `main` (`docs: update plan status`) unless the
   user said not to commit to `main`; otherwise leave it staged-free but current.

## Step 7 — Next wave

Re-select the next wave from `plans/STATUS.md`: all `merged` prerequisites,
disjoint file sets, current `main` tip. Repeat Steps 2–6. Worktrees must be
created *after* the previous wave's merges so they include them.

Waves are not all-or-nothing: if one plan in a wave is blocked, start the next
wave for plans that do not depend on it, and leave the blocked worktree in place.

## Stop and report

Stop the current wave and report in `plans/STATUS.md` when:

- a plan file is missing, unreadable, or too vague to bound
- worktree or branch creation fails for a reason you cannot fix safely
- a worker fails 3 attempts
- a merge conflicts
- verification is still red after merging (treat as an incident: keep the merge
  commit, report the exact failing command)
- a worker touches files outside its declared scope, or edits `plans/`
- tests require secrets, services, or migrations you cannot safely run

Report format: plan id, status, branch/worktree, last log path, exact failing
command, and the next decision the human must make. Keep it to one line per
problem.

## Resume behavior

When asked to resume: read `plans/STATUS.md` first. Trust `merged` only if the
merge commit is an ancestor of `main`; otherwise re-verify and correct the
status. Reuse existing worktrees/branches for plans marked `running`, `retry-*`,
or `blocked` instead of recreating them. Never start a plan whose prerequisites
are not merged.

## Anti-patterns

- Running `opencode run` directly, or without stdout/stderr redirected.
- Two workers in one worktree, or parallel plans that touch the same file.
- `cat`-ing a worker log, or pasting raw test output into the orchestrator.
- Reusing `feat/<id>` with `-f`, or merging a branch with a dirty worktree.
- Updating `plans/STATUS.md` only at the end.
- Fixing worker code by hand instead of writing a bounded retry plan.
- Pushing, opening PRs, or force-pushing during orchestration.
