# gramsathi

GramSathi AI – Flutter UI.

## Known issue: Chrome + trackpad

On **Flutter web** in **Chrome**, scrolling with a **trackpad** can trigger an assertion in the framework ([flutter/flutter#174215](https://github.com/flutter/flutter/issues/174215)):

```text
Assertion failed: !identical(kind, PointerDeviceKind.trackpad)
```

**Workarounds:**

- Use a **mouse** to scroll when testing in Chrome, or  
- Run on another device: `flutter run -d edge`, or `flutter run -d android`, or  
- Upgrade Flutter: `flutter upgrade` (fix may land in a future release).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
