#!/bin/bash
# Cài bản V2 "time-gift-waves" lên app chính (simulator), giữ nguyên dữ liệu đã lưu.
# Lặp lại đúng quy trình Codex: chụp state.json trước/sau, so sánh, mở app, gỡ bản QA.
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR=/Users/vunguyen/Desktop/Xcode-beta.app/Contents/Developer
DEV=54B67C9B-28C9-4698-98A3-968BA4AB75B6
B=com.local.dopafit.v2
QA=com.local.dopafit.v2.designqa
APP=.build/v2-home-qa/Build/Products/Debug-iphonesimulator/DopafitV2.app
R=rebuild/verification/v2-time-gift-waves-2026-11-25
state() { echo "$(xcrun simctl get_app_container $DEV $B data)/Library/Application Support/DopafitV2/state.json"; }

cp "$(state)" "$R/main-preinstall.json"
xcrun simctl terminate $DEV $B 2>/dev/null || true
xcrun simctl install $DEV "$APP"
cp "$(state)" "$R/main-afterinstall.json"
python3 - "$R" <<'PY'
import json,sys
r=sys.argv[1]
a=json.load(open(r+'/main-preinstall.json'));b=json.load(open(r+'/main-afterinstall.json'))
assert a==b, 'Dữ liệu app chính bị đổi sau khi cài — dừng lại!'
print('OK: dữ liệu app chính giữ nguyên. onboarded=%s, history=%d, isPro=%s'%(b['onboarded'],len(b['history']),b['isPro']))
PY
xcrun simctl launch $DEV $B
if xcrun simctl get_app_container $DEV $QA >/dev/null 2>&1; then
  xcrun simctl terminate $DEV $QA 2>/dev/null || true
  xcrun simctl uninstall $DEV $QA && echo "OK: đã gỡ bản QA"
fi
python3 - "$R" <<'PY'
import json,sys
r=sys.argv[1];b=json.load(open(r+'/main-afterinstall.json'))
json.dump({'mainFullJSONPreservedAcrossInstall':True,'onboarded':b['onboarded'],'historyCount':len(b['history']),'isPro':b['isPro'],'qaRemoved':True,'deviceErased':False,'deviceShutdown':False},open(r+'/preservation.json','w'),ensure_ascii=False,indent=2)
PY
echo "XONG: app chính đã chạy bản mới."
