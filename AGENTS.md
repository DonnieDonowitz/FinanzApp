# FinanzApp is a native iOS app

There is no Expo/React Native project in this repository anymore. The app is
100% native SwiftUI, living in `Native_iOS/`, targeting iOS 17+.

- Xcode project is generated from `Native_iOS/project.yml` via XcodeGen
  (`xcodegen generate`), not checked in directly.
- Main app target: `Native_iOS/FinanzApp/` (bundle `marino.finanzapp.app`).
- Widget extension: `Native_iOS/FinanzAppWidget/` (bundle
  `marino.finanzapp.app.widget`), sharing data with the app via the
  `group.com.finanzapp.app` App Group (SQLite DB + `UserDefaults` suite) —
  see `Native_iOS/Shared/SharedData.swift`.
- Build a sideloadable IPA with `./build-ipa.sh` (requires Xcode/macOS).
