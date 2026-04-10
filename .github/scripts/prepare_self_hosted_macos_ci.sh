#!/usr/bin/env bash

set -euo pipefail

required_flutter_version="${REQUIRED_FLUTTER_VERSION:-3.41.6}"
required_xcode_major="${REQUIRED_XCODE_MAJOR:-26}"
required_xcode_developer_dir="${REQUIRED_XCODE_DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command '$command_name' is not available on this runner." >&2
    exit 1
  fi
}

require_command flutter
require_command python3
require_command xcodebuild
require_command xcrun

if [[ -d "$required_xcode_developer_dir" ]]; then
  export DEVELOPER_DIR="$required_xcode_developer_dir"
  echo "DEVELOPER_DIR=$required_xcode_developer_dir" >> "$GITHUB_ENV"
fi

current_flutter_version="$(flutter --version --machine | python3 -c 'import json, sys
data = json.load(sys.stdin)
print(data.get("frameworkVersion", ""))')"

if [[ -z "$current_flutter_version" ]]; then
  echo "Unable to determine the installed Flutter version." >&2
  exit 1
fi

if [[ "$current_flutter_version" != "$required_flutter_version" ]]; then
  echo "Updating Flutter from $current_flutter_version to $required_flutter_version"
  flutter channel stable
  flutter version "$required_flutter_version"
fi

flutter precache --ios
flutter config --enable-swift-package-manager

current_xcode_version="$(xcodebuild -version | awk 'NR == 1 { print $2 }')"
current_xcode_major="${current_xcode_version%%.*}"

if [[ -z "$current_xcode_major" ]]; then
  echo "Unable to determine the installed Xcode version." >&2
  exit 1
fi

if (( current_xcode_major < required_xcode_major )); then
  echo "Xcode $current_xcode_version is too old. Install Xcode $required_xcode_major or newer and ensure it is selected before rerunning CI." >&2
  exit 1
fi

simulator_udid=""
if ! simulator_udid="$(xcrun simctl list devices available -j | python3 -c 'import json, sys
data = json.load(sys.stdin)
device_groups = []
for runtime, devices in data.get("devices", {}).items():
  if not runtime.startswith("com.apple.CoreSimulator.SimRuntime.iOS-"):
    continue
  runtime_version = runtime.split("iOS-")[-1]
  runtime_components = tuple(int(part) for part in runtime_version.split("-") if part.isdigit())
  available_devices = [
    device for device in devices
    if device.get("isAvailable") and device.get("name", "").startswith("iPhone")
  ]
  if available_devices:
    device_groups.append((runtime_components, runtime, sorted(available_devices, key=lambda device: (device.get("name", ""), device.get("udid", "")))))

for _, runtime, devices in sorted(device_groups, key=lambda item: (item[0], item[1]), reverse=True):
  chosen_device = devices[0]
  print(chosen_device.get("udid", ""))
  raise SystemExit(0)
raise SystemExit(1)')"; then
  echo "No available iPhone simulator found. Install at least one iOS simulator runtime in Xcode before rerunning CI." >&2
  exit 1
fi

echo "IOS_SIMULATOR_UDID=$simulator_udid" >> "$GITHUB_ENV"