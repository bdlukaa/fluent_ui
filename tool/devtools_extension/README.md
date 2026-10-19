# Fluent UI DevTools extension

This Flutter web application is the source for the `fluent_ui` DevTools icon
browser. It is intentionally outside the published package so its development
dependencies do not affect package consumers.

## Develop

```sh
cd tool/devtools_extension
flutter pub get
flutter run -d chrome --dart-define=use_simulated_environment=true
```

## Test and package

From the repository root, rebuild the distributable extension with:

```sh
./tool/rebuild_devtools_extension.sh
```

Validate its metadata and bundled web resources with:

```sh
cd tool/devtools_extension
flutter pub get
dart run devtools_extensions validate --package=../..
flutter test
flutter analyze
```

The resulting `extension/devtools/build` directory is intentionally tracked and
is included in pub packages by `extension/devtools/.pubignore`.
