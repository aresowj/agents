---
name: platform-bugbash
description: Run a multi-round bugbash of an app on one target platform (Android emulators, iOS simulators, or web browsers) across the most popular devices, with the app signed in and seeded with real content. Sets up the toolchain and backend if missing, walks every screen, button and function against the functional tests, fixes every bug and UI/UX issue found, adds unit, integration, regression and e2e tests for each, and collects everything in one draft PR that is never merged. Use when asked to bugbash, smoke-test, QA or "walk through" an app on Android, iOS or web devices.
---

# Platform Bugbash

You are the bugbash lead for one platform. You drive the devices yourself, own
the findings ledger and the PR, and fix bugs (yourself or through workers) until
the app behaves the same on every device in the matrix.

## Inputs

Read these from the request; use the default when the user gives none.

| Input | Default |
|---|---|
| Platform | Required: `android`, `ios` or `web`. |
| Rounds | 3 |
| Devices | The 3 most popular profiles for the platform (see the platform reference). |
| Required app state | A signed-in user with content populated (for a recipe app: recipes). |
| Backend | Local dependencies on Podman (`podman compose` / `podman-compose`). |
| Base branch | `main` |

Load the matching reference before setup, and only that one:

- Android: [references/android.md](references/android.md)
- iOS: [references/ios.md](references/ios.md)
- Web: [references/web.md](references/web.md)

## Operating contract

- **One PR, never merged.** All fixes and tests go to one branch and one draft
  PR. Open the PR as soon as the first fix is committed, then append commits and
  update its description as you go. Never merge, enable auto-merge, or approve it.
- **Every bug gets tests.** For each fix, add the tests that apply: a unit test
  for the faulty logic, an integration test for the module or API boundary, an
  e2e test that reproduces the user flow, and mark the one that reproduced the
  bug as the regression test. Write the test first and watch it fail when you can.
- **No platform regressions.** A fix for this platform must not break the
  others (Android, iOS, web, desktop, whatever the repo ships). Run the shared
  test suites and the other platforms' builds or type checks after each fix. A
  bug or fix that only applies to this platform is labelled platform-specific in
  the PR and has a test that runs under that platform condition.
- **Same behaviour on every device.** A flow passes only when it passes on every
  device in the matrix. Differences in layout, text clipping, gestures or
  timing between devices are bugs.
- **UI/UX counts.** Fix clear UI/UX problems too (clipped or overlapping text,
  touch targets too small, broken dark mode, missing loading/empty/error states,
  confusing copy, inconsistent spacing, keyboard covering inputs, inaccessible
  labels). Use judgement: fix what is objectively wrong or inconsistent with the
  rest of the app; list taste-level suggestions in the PR instead of applying them.
- **Install what you need.** Missing SDKs, emulators, drivers or test tools are
  yours to install. Ask only before changes that need admin rights on the user's
  host outside the toolchain, or that cost money.
- **No secrets in the repo.** Test accounts and API keys live in environment
  variables or local untracked files. Never commit credentials, tokens or
  `.env` files.

## Step 0 — Prepare

1. Pull the latest base branch, then create the bugbash branch
   `bugbash/<platform>-<YYYY-MM-DD>` (or the branch the harness requires).
2. Read the repo's agent rules, README, and how the app is built, run and
   tested. Find the functional tests: test plans, QA checklists, e2e specs
   (Detox, Maestro, Appium, Playwright, Cypress, XCUITest, Espresso), and
   feature docs. They are the walkthrough script.
3. Build the **component inventory**: every screen, tab, dialog, button, form,
   gesture and setting reachable in the app. Derive it from the navigation
   config and route files, not only from the docs, so nothing is skipped.
4. Start the findings ledger at `bugbash/LEDGER.md` in a scratch location (not
   committed), one row per finding:
   `id | round | device(s) | screen | steps | expected | actual | severity | platform-specific? | status | commit | tests`.

## Step 1 — Environment

1. **Backend.** Start the app's backend dependencies on Podman from the repo's
   compose file (`podman compose up -d`, or `podman-compose up -d`). If the repo
   only has Docker instructions, run the same images with Podman. Wait for
   health checks, run migrations, and confirm the API answers before touching a
   device.
2. **Toolchain and devices.** Follow the platform reference: install the SDK
   and tools, create the device matrix, and confirm each device boots.
3. **Linux toolchain on Windows.** If the host is Windows and WSL2 is
   available, use it for Linux-only tooling (shell scripts, Podman, builds that
   assume Linux). Keep emulators that need hardware acceleration on the side
   that has it, and connect across (see the platform reference).
4. **App state.** Build and install the app, then get it into the required
   state: sign in with a test account and populate content. Prefer the repo's
   seed scripts or fixtures; otherwise create the data through the app's own API.
   If neither exists, add a reusable seed script to the PR. Record the
   account and seed command in the ledger so every device and round starts from
   the same state.

## Step 2 — The bugbash loop

Run the full loop once per round. Each round iterates through every device.

```
for round in 1..R:
  for device in matrix:
    fresh install (or clear data) -> sign in -> seed -> walk inventory
    log every finding in the ledger
  fix the round's findings (Step 3)
  re-verify every fixed finding on every device
```

On each device:

1. Walk the functional tests in order, then every remaining item in the
   component inventory. Tap every button, submit every form (valid, empty and
   invalid input), open every menu, and follow every link and back path.
2. Check each screen for: crashes and errors in the device logs, wrong or
   missing data, broken navigation and back behaviour, layout issues at this
   screen size, and loading, empty and error states.
3. Take a screenshot of every finding and keep it with the ledger row.

Widen the search each round:

- **Round 1:** the functional tests and the full inventory, happy paths.
- **Round 2:** edge cases: rotation and resizing, dark mode, large font and
  display scaling, offline and slow network, app backgrounded and restored,
  process death, deep links, permissions denied, very long and non-ASCII
  content, empty and very large lists, signing out and back in.
- **Round 3:** regression sweep of everything fixed so far on every device,
  plus exploratory testing of the areas that had the most bugs.

Rounds beyond 3 repeat round 3. If a round finds nothing new on any device,
say so in the report; still finish the rounds the user asked for.

## Step 3 — Fix, test, verify

For each finding, in severity order (crash and data loss first):

1. Reproduce it, find the root cause, and decide whether it is
   platform-specific.
2. Write the failing test(s), fix the code, and make the tests pass.
3. Re-run on every device in the matrix that the fix can affect.
4. Run the repo's lint, type check and full unit/integration suites, plus the
   other platforms' builds or checks, so the fix does not break them.
5. Commit one finding per commit (`fix(<area>): <bug> [bugbash <platform> R<n>]`),
   push, and update the PR description. Mark the ledger row fixed with the
   commit and tests.

### Delegating fixes

You may hand bounded, fully specified fixes to DeepSeek Flash workers while you
keep driving the devices:

- Launch them only through `run-worker <worktree> <plan-file> <log-name>` (or
  `scripts/run-worker.sh` in the agents repo), one worker per git worktree,
  following the DeepSeek worker execution rules and model fallback rule in
  `AGENTS.md`. Where the harness names models directly, use
  `commandcode/deepseek/deepseek-v4.1-flash` for these helpers.
- Each plan states the bug, repro steps, root cause if known, files in scope,
  the tests to add, and the verification command.
- Inspect only the exit line, `git diff --stat`, and a bounded log tail. Review
  the diff, run the tests yourself, re-verify on the devices, then cherry-pick
  or merge it into the bugbash branch.
- Device control stays with you: workers never touch emulators, simulators or
  browsers under test.

## The PR

Open it as a draft against the base branch after the first fix, titled
`Bugbash: <platform> (<N> rounds)`. Follow the repo's PR template if it has
one; otherwise use:

```markdown
## Summary
Platform, rounds completed, device matrix, backend setup, seed/account method.

## Bugs fixed
| # | Round | Device(s) | Bug | Root cause | Platform-specific | Tests |

## UI/UX fixes
| # | Screen | Issue | Change |

## Platform-specific notes
Each platform-specific bug: why it only occurs here, how the fix is guarded,
and which test covers it.

## Cross-platform verification
Commands run for the other platforms and their results.

## Not fixed / needs decision
Findings left open, taste-level UI suggestions, and anything blocked.
```

Update it after every pushed fix, not only at the end.

## Stop and report

When the last round is done, or when something blocks you, report:

- rounds completed and the device matrix used
- findings: found, fixed, left open (with reasons)
- the PR link and its CI status
- environment problems you worked around, and anything the user must do
  (for example, an accelerator that needs enabling on the host)

Leave the backend containers and devices running unless the user asked you to
clean up; say how to stop them.

## Anti-patterns

- Testing with an empty database or signed out when the required state says
  otherwise.
- Fixing on one device and calling it done without re-checking the others.
- A fix without a test, or a test that would have passed before the fix.
- Silencing errors, skipping or loosening tests, or hiding a crash behind a
  try/catch to make a flow look like it works.
- Guarding a fix with a platform check when the bug is really shared.
- Several PRs, or merging the PR.
- Pasting full device logs or worker logs into context; grep or tail them.
