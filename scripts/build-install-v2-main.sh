#!/bin/bash
# Build DopafitV2 (Debug, simulator) rồi cài lên app chính, giữ nguyên dữ liệu đã lưu.
# Dùng: scripts/build-install-v2-main.sh <tên-lượt>   (vd: v2-joint-icons-2026-11-25)
set -euo pipefail
cd "$(dirname "$0")/.."
RUN=${1:?Cần tên lượt}
export DEVELOPER_DIR=/Users/vunguyen/Desktop/Xcode-beta.app/Contents/Developer
DEV=54B67C9B-28C9-4698-98A3-968BA4AB75B6
B=com.local.dopafit.v2
APP=.build/v2-home-qa/Build/Products/Debug-iphonesimulator/DopafitV2.app
R=rebuild/verification/$RUN; mkdir -p "$R"
LOG=.build/$RUN.log
echo "Đang build… (log: $LOG)"
if ! xcodebuild -project DopafitV2/DopafitV2.xcodeproj -scheme DopafitV2 -configuration Debug \
  -sdk iphonesimulator -destination "id=$DEV" -derivedDataPath .build/v2-home-qa \
  CODE_SIGNING_ALLOWED=NO build > "$LOG" 2>&1; then
  grep -E "error:" "$LOG" | head -20; echo "BUILD LỖI — chưa cài gì lên app chính."; exit 1
fi
echo "BUILD SUCCEEDED"
state() { echo "$(xcrun simctl get_app_container $DEV $B data)/Library/Application Support/DopafitV2/state.json"; }
cp "$(state)" "$R/main-preinstall.json"
xcrun simctl terminate $DEV $B 2>/dev/null || true
xcrun simctl install $DEV "$APP"
cp "$(state)" "$R/main-afterinstall.json"
python3 - "$R" <<'PY'
import json,sys
r=sys.argv[1];a=json.load(open(r+'/main-preinstall.json'));b=json.load(open(r+'/main-afterinstall.json'))
assert a==b,'Dữ liệu app chính bị đổi sau khi cài — dừng lại!'
json.dump({'mainFullJSONPreservedAcrossInstall':True,'onboarded':b['onboarded'],'historyCount':len(b['history']),'isPro':b['isPro']},open(r+'/preservation.json','w'),ensure_ascii=False,indent=2)
print('OK: dữ liệu app chính giữ nguyên. onboarded=%s, history=%d'%(b['onboarded'],len(b['history'])))
PY
xcrun simctl launch $DEV $B >/dev/null
echo "XONG: app chính đã chạy bản mới."
