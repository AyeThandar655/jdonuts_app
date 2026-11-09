#!/usr/bin/env bash
# One-time setup: generates the Android/iOS host projects, patches them for
# this app, fetches packages and runs code generation (Drift + l10n).
# Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d android ] || [ ! -d ios ]; then
  echo "› Generating Android and iOS host projects"
  flutter create --platforms=android,ios --org com.madivizion --project-name jdonuts .
fi

MANIFEST=android/app/src/main/AndroidManifest.xml
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  echo "› Android: INTERNET permission, cleartext for the local mock server, app label"
  perl -0pi -e 's#(<manifest[^>]*>)#$1\n    <uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>#' "$MANIFEST"
  perl -0pi -e 's#<application#<application\n        android:usesCleartextTraffic="true"#' "$MANIFEST"
  perl -0pi -e "s#android:label=\"jdonuts\"#android:label=\"J'Donuts\"#" "$MANIFEST"
fi

PLIST=ios/Runner/Info.plist
if command -v plutil >/dev/null 2>&1; then
  if ! plutil -extract NSAppTransportSecurity xml1 -o /dev/null "$PLIST" 2>/dev/null; then
    echo "› iOS: allow plain HTTP to localhost for the mock server, display name"
    plutil -insert NSAppTransportSecurity -json '{"NSAllowsLocalNetworking":true}' "$PLIST"
    plutil -replace CFBundleDisplayName -string "J'Donuts" "$PLIST"
  fi
fi

echo "› flutter pub get"
flutter pub get
echo "› Localizations (gen-l10n)"
flutter gen-l10n
echo "› Drift code generation"
dart run build_runner build --delete-conflicting-outputs

echo "✓ Ready. Run: flutter run"
