# iOS reference

## Toolchain

iOS simulators need macOS with Xcode. If the current machine is not a Mac,
look for an attached Mac (remote machine, SSH host) and run the device steps
there; if there is none, stop and report that iOS is blocked. Do not try to
emulate iOS on Linux or Windows.

1. Check: `xcode-select -p`, `xcodebuild -version`, `xcrun simctl list runtimes`.
2. Install what is missing: the Xcode command line tools, the iOS runtime the
   matrix needs (`xcodebuild -downloadPlatform iOS`), CocoaPods or the
   project's dependency manager, and `idb` or Maestro if you need taps beyond
   what `simctl` offers.
3. Install JS/Flutter/other dependencies the project needs (`pod install` in
   `ios/` for React Native).

## Device matrix

Pick the three most popular profiles, covering screen size and OS version:

1. The current standard iPhone on the latest iOS.
2. A small-screen iPhone (SE-class) on the oldest iOS the app supports that is
   still widely used (check the deployment target).
3. An iPad, latest iOS (skip only if the app is iPhone-only, and say so).

Create with `xcrun simctl create "<name>" "<device-type-id>" "<runtime-id>"`;
boot with `xcrun simctl boot <udid>` and wait with
`xcrun simctl bootstatus <udid> -b`.

## Driving the app

- Install: the project's build (`xcodebuild ... -destination 'id=<udid>'`,
  `npx expo run:ios --device <udid>`, `flutter run -d <udid>`), then
  `xcrun simctl install <udid> <App.app>` and `xcrun simctl launch <udid> <bundle-id>`.
- Fresh state: `xcrun simctl uninstall <udid> <bundle-id>` then reinstall, or
  `xcrun simctl erase <udid>` for a full reset.
- Screenshots: `xcrun simctl io <udid> screenshot shot.png`.
- Input and hierarchy: `idb ui tap`, `idb ui text`, `idb ui describe-all`,
  or Maestro flows.
- Logs: `xcrun simctl spawn <udid> log stream --predicate 'process == "<App>"'`
  in the background to a file; tail the file.
- Edge cases: dark mode (`xcrun simctl ui <udid> appearance dark`), text size
  (`xcrun simctl ui <udid> content_size extra-extra-large`), deep links
  (`xcrun simctl openurl <udid> "<uri>"`), push payloads
  (`xcrun simctl push <udid> <bundle-id> payload.json`), permissions
  (`xcrun simctl privacy <udid> revoke <service> <bundle-id>`), rotation via
  the test framework or Simulator's Device menu.
- Backend from the simulator: `localhost` reaches the Mac host.

## E2E tests

Use the repo's framework (Detox, Maestro, XCUITest, Appium). If it has none,
prefer Maestro for flow tests and document the run command in the PR.
