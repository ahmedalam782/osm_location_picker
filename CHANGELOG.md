## 1.0.5

- Fix: updated GPS device location fetching to use `LocationAccuracy.high` on native platforms for reliable hardware and simulated GPS fixes.
- Fix: updated macOS CocoaPods minimum deployment target to `12.0` in `example/macos/Podfile` post-install hook to prevent Xcode build failures.
- Web: verified full compatibility with Flutter WebAssembly (WASM) compilation (`flutter build web --wasm`).
- Docs: updated README with comprehensive platform-specific permissions, WebAssembly (WASM) guides, configuration instructions for Android, iOS, macOS, Web, Windows, and Linux, and iOS Simulator location testing instructions.

## 1.0.4

- Fix: added macOS App Sandbox location entitlements and usage description keys to enable GPS location picking.
- Fix: updated GPS fetching to use a 5-second timeout and fallback to the last known position to prevent indefinite hangs.
- Fix: resolved target warnings in Xcode/CocoaPods builds regarding dependency analysis and deployment target versions.
- Updated documentation and README with troubleshooting steps for macOS application run behaviors.

## 1.0.3

- Fix: added required Android permissions (INTERNET, ACCESS_NETWORK_STATE, location) for release builds.
- Fix: network connectivity check now works in Android release builds (added network security config).
- Fix: SVG icon assets not loading after package rename (wrong `package:` reference).
- Fix: error message no longer shown as search bar hint text on offline/failure state.
- Added network and location permissions for iOS, macOS, and documentation for all platforms.
- Updated README with comprehensive platform-specific setup instructions.

## 1.0.2

- Published to pub.dev.
- Package renamed to `osm_location_picker`.
- Improved error widget: pull-to-refresh on mobile, retry button on web & desktop.
- Replaced `dart:io` Platform checks with `defaultTargetPlatform` for full web support.
- Added dartdoc to all public APIs.
- Switched license to MIT.

## 1.0.1+1

- Initial versioned release.
