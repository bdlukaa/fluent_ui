#!/usr/bin/env sh
set -eu

cd tool/devtools_extension
flutter pub get
dart run devtools_extensions build_and_copy --source=. --dest=../../extension/devtools
