# awesome_notes

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Serving the web build (previewing a release)

When previewing a release or testing the compiled web app locally, serve the `build/web` directory that Flutter generates. The `build/web` folder contains the generated bootstrap (`flutter_bootstrap.js`), `flutter.js`, `main.dart.js`, and other assets that the loader expects.

Quick local preview (from the project root):

```bash
# using Python 3's simple HTTP server
python -m http.server --directory build/web 8000

# then open http://localhost:8000
```

Why: The generated `build/web/index.html` and `flutter_bootstrap.js` set `_flutter.buildConfig` and other runtime values (engineRevision, builds array, service worker version). Serving the `web/` folder directly may be missing these generated bootstrap values, which causes runtime loader errors (e.g., "Cannot read properties of undefined (reading 'find')").

If you need a development workflow where `web/index.html` is served directly, keep the generated bootstrap in sync: after running `flutter build web`, copy the generated `flutter_bootstrap.js` (and/or the generated `index.html` contents) from `build/web` into `web/` or update `web/index.html` to match the generated bootstrap values.

Developer tip: I added a small dev-time validator into `web/index.html` that logs a clear error if `_flutter.buildConfig` is missing or malformed to help diagnose this issue in the future.
