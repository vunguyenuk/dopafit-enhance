#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
export DEVELOPER_DIR="${DOPAFIT_XCODE:-/Users/vunguyen/Desktop/Xcode-beta.app}/Contents/Developer"
dopafit_device="${DOPAFIT_SIMULATOR:-54B67C9B-28C9-4698-98A3-968BA4AB75B6}"
mkdir -p rebuild
python3 scripts/check-opengym-assets.py
python3 scripts/check-form-assets.py
python3 scripts/check-exercise-media.py
xcrun simctl boot "$dopafit_device" 2>/dev/null || true
xcrun simctl bootstatus "$dopafit_device" -b
xcodebuild -project Dopafit.xcodeproj -scheme Dopafit -configuration Debug -sdk iphonesimulator -destination "id=$dopafit_device" -derivedDataPath .build CODE_SIGNING_ALLOWED=NO build > rebuild/build.log 2>&1
xcrun simctl terminate "$dopafit_device" com.local.dopafit.rebuild 2>/dev/null || true
xcrun simctl install "$dopafit_device" .build/Build/Products/Debug-iphonesimulator/Dopafit.app
xcrun simctl launch "$dopafit_device" com.local.dopafit.rebuild --demo
