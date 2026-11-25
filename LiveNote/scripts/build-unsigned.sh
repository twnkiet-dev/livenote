#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
xcodebuild -project LiveNote.xcodeproj -scheme LiveNote -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath "$PWD/build/DerivedData" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  build | tee build/xcodebuild.log
app="$PWD/build/DerivedData/Build/Products/Release-iphoneos/LiveNote.app"
test -f "$app/LiveNote"
test -f "$app/PlugIns/LiveNoteWidget.appex/LiveNoteWidget"
rm -rf build/Payload build/LiveNote.ipa
mkdir -p build/Payload
cp -R "$app" build/Payload/
(cd build && /usr/bin/zip -qry LiveNote.ipa Payload)
/usr/bin/unzip -tq build/LiveNote.ipa
