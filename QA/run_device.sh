#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
: "${GF_SIMULATOR_UDID:?Run the whole script through simulator_pool.py}"
label="${1:-phone}"
mkdir -p "QA/$label"
xcrun simctl boot "$GF_SIMULATOR_UDID" || true
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
xcrun simctl status_bar "$GF_SIMULATOR_UDID" override --time '9:41' --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100
attempt=1
while [[ -e "QA/$label/Journey-$attempt.xcresult" ]]; do attempt=$((attempt+1)); done
last_attempt=$((attempt+3))
while true; do
 while [[ -f QA/preparing-tests ]]; do sleep 1; done
 result="QA/$label/Journey-$attempt.xcresult"
 status=0
 xcodebuild -project ChalkOrbit.xcodeproj -scheme ChalkOrbit -configuration Workshop -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO -derivedDataPath Artifacts/UITestCompile -resultBundlePath "$result" -jobs 3 CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO test > "QA/$label/test.log" 2>&1 || status=$?
 echo "$result" > "QA/$label/latest-result.txt"
 cp "QA/$label/test.log" "QA/$label/test-attempt-$attempt.log"
 attachments="QA/$label/Attachments-$attempt"
 xcrun xcresulttool export attachments --path "$result" --output-path "$attachments" > "QA/$label/attachments-$attempt.log" 2>&1 || true
 python3 QA/collect.py "$attachments"
 if data=$(xcrun simctl get_app_container "$GF_SIMULATOR_UDID" com.coachboard.app-c977830d8707 data); then
  cp "$data/Library/Application Support/ChalkOrbit/playbook.json" "QA/$label/persisted-book.json" || true
  find "$data/tmp" -name 'Coach-Board-*.pdf' -exec cp '{}' "QA/$label/" \;
 fi
 if group_data=$(xcrun simctl get_app_container "$GF_SIMULATOR_UDID" com.coachboard.app-c977830d8707 group.com.coachboard.app-c977830d8707 2>"QA/$label/group-access.log"); then
  cp "$group_data/glance.json" "QA/$label/widget-snapshot.json"
  cmp "QA/$label/persisted-book.json" "QA/$label/widget-snapshot.json"
 fi
 echo "$status" > "QA/$label/test-status"
 echo "QA $label attempt $attempt complete (status $status); waiting for local review marker."
 touch "QA/$label/awaiting-review"
 decision=timeout
 for ((i=0;i<600;i++)); do
  if [[ -f "QA/$label/retry" ]]; then rm "QA/$label/retry";decision=retry;break;fi
  if [[ -f "QA/$label/reviewed" ]]; then rm "QA/$label/reviewed";decision=reviewed;break;fi
  sleep 1
 done
 rm -f "QA/$label/awaiting-review"
 if [[ "$decision" == reviewed && "$status" == 0 ]]; then break;fi
 if [[ "$decision" != retry || "$attempt" -ge "$last_attempt" ]]; then exit 75;fi
 attempt=$((attempt+1))
done
if [[ "$label" == phone ]]; then
 xcrun simctl shutdown "$GF_SIMULATOR_UDID"
 factory_root="$(cd ../../../.. && pwd)"
 python3 "$factory_root/gf/genesis/simulator_pool.py" 4671120C-F54F-4008-A170-413F94D007D6 bash "$PWD/QA/run_device.sh" tablet
fi

if [[ "$label" == tablet && -f QA/confirm-phone ]]; then
 xcrun simctl shutdown "$GF_SIMULATOR_UDID"
 factory_root="$(cd ../../../.. && pwd)"
 python3 "$factory_root/gf/genesis/simulator_pool.py" B3A0C1EF-540F-460C-9C1B-F560FB9AE2E4 bash "$PWD/QA/run_device.sh" phone-confirmation
fi
