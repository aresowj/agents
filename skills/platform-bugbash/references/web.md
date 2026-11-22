# Web reference

## Toolchain

1. Use the repo's Playwright or Cypress setup if it exists. Otherwise install
   Playwright as a dev dependency and its browsers
   (`npx playwright install --with-deps chromium firefox webkit`), unless a
   browser is already provided by the environment.
2. Start the backend on Podman, then the web app the way the repo documents it
   (dev server or a production build served locally, which catches more bugs).

## Device matrix

Pick the three most popular profiles:

1. Desktop Chromium (Chrome/Edge) at 1920×1080 or 1366×768.
2. Mobile Safari: Playwright WebKit with an iPhone device descriptor.
3. Mobile Chrome: Chromium with a Pixel/Android device descriptor.

Add desktop Firefox and Safari (WebKit desktop) as extra checks in round 3,
or as the main matrix if the project's analytics say so.

## Driving the app

- Script each walkthrough in Playwright (headed or headless) rather than
  clicking by hand; keep the scripts, they become the e2e tests.
- Screenshots: `page.screenshot({ fullPage: true })` per screen and finding.
- Console and network: record `page.on('console')`, `page.on('pageerror')` and
  failed requests (`page.on('requestfailed')`, responses with status >= 400)
  for every flow; any of them is a finding until explained.
- Edge cases: viewport resizing and orientation, `colorScheme: 'dark'`,
  browser zoom and large fonts, `context.setOffline(true)` and throttled
  networks, back/forward and refresh on every route, direct navigation to deep
  URLs, session expiry, keyboard-only navigation and focus order, and an
  accessibility scan (`@axe-core/playwright`) per screen.

## E2E tests

Add regression flows to the repo's existing e2e suite, run across the same
browser/device projects as the matrix.
