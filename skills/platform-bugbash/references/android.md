# Android reference

## Toolchain

1. Check what exists: `ANDROID_HOME` / `ANDROID_SDK_ROOT`, `sdkmanager`,
   `avdmanager`, `emulator`, `adb`, and a JDK the project's Gradle accepts.
2. Install what is missing: a JDK (Temurin or the version in the project's
   Gradle/CI config), the Android command-line tools, then:

   ```bash
   sdkmanager "platform-tools" "emulator" "platforms;android-<api>" \
     "system-images;android-<api>;google_apis;x86_64"
   ```

   Use `arm64-v8a` images on Apple silicon or ARM hosts. Use the API levels the
   matrix needs and the project's `compileSdk`.
3. Hardware acceleration: KVM on Linux (`/dev/kvm` readable), the Hypervisor
   framework on macOS, WHPX (Windows Hypervisor Platform) on Windows. Without
   it the emulator is too slow to bugbash; report it instead of grinding on.
4. **Windows with WSL2:** run the emulator on Windows (it has WHPX), and use
   WSL2 for Linux tooling. Reach the Windows adb server from WSL2 by using the
   Windows `adb.exe`, or by pointing WSL2's adb at the host
   (`ADB_SERVER_SOCKET=tcp:<windows-host-ip>:5037` with the Windows server
   started as `adb -a nodaemon server`). Metro or other dev servers in WSL2
   need `adb reverse` or the host IP so the emulator can reach them.

## Device matrix

Pick the three most popular profiles, covering screen size and OS version
rather than three near-identical phones:

1. A current mainstream phone (Pixel-class, ~6.1–6.7") on the latest stable API
   level.
2. A smaller or lower-density phone on an older API level that the app still
   supports (check `minSdk`; pick a widely used version above it).
3. A large-screen device: tablet or foldable, latest stable API.

If the project's analytics or docs name its top devices, use those instead.
Create them with `avdmanager create avd -n <name> -k "<system-image>" -d <device-id>`
(`avdmanager list device` lists ids). Run one emulator at a time unless the
host clearly has headroom; boot with
`emulator -avd <name> -no-snapshot-load -no-boot-anim` (add `-no-window`
when no display is needed) and wait for
`adb wait-for-device shell getprop sys.boot_completed` to return `1`.

## Driving the app

- Install: the project's build (`./gradlew installDebug`, `npx expo run:android`,
  `npx react-native run-android`, `flutter run`, ...), or `adb install -r <apk>`.
- Fresh state: `adb shell pm clear <package>`.
- Inspect the screen: `adb exec-out screencap -p > shot.png`, and
  `adb exec-out uiautomator dump /dev/tty` for the view hierarchy and tap
  coordinates.
- Input: `adb shell input tap <x> <y>`, `input text`, `input keyevent KEYCODE_BACK`,
  `input swipe`.
- Logs: `adb logcat -c` before a flow, then
  `adb logcat -d *:E | tail -n 50` (or filter by the app's pid) after it.
- Edge cases: rotation (`adb shell settings put system user_rotation 1` with
  auto-rotate off), dark mode (`adb shell cmd uimode night yes`), font scale
  (`adb shell settings put system font_scale 1.3`), offline
  (`adb shell svc wifi disable; adb shell svc data disable`), process death
  (background the app, `adb shell am kill <package>`, reopen), deep links
  (`adb shell am start -W -a android.intent.action.VIEW -d "<uri>"`).
- Backend from the emulator: the host is `10.0.2.2`; or use
  `adb reverse tcp:<port> tcp:<port>`.

## E2E tests

Use the e2e framework the repo already has (Detox, Maestro, Espresso, Appium).
If it has none, prefer Maestro for flow tests (YAML, works for native and
React Native) and keep the new tests runnable from one command documented in
the PR.
