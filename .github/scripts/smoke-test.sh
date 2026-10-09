#!/usr/bin/env bash
# يثبّت التطبيق على المحاكي ويشغّله، ويفشل إذا انهار التطبيق خلال ٢٠ ثانية.
set -u
APK="$1"
PKG="$2"
adb install -r "$APK"
adb logcat -c
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1
sleep 20
echo "===== crash log ====="
adb logcat -d -b crash
adb logcat -d | grep -E "AndroidRuntime|FATAL|flutter|Ads" | tail -80
if adb shell pidof "$PKG" >/dev/null; then
  echo "App is running"
else
  echo "App is NOT running (crashed)"
  exit 1
fi
