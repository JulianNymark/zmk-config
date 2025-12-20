#!/bin/bash

set -e

echo "Starting parallel build for all Totem configurations..."

# Prepare the workspace once to avoid race conditions in parallel builds
echo "Ensuring workspace is initialized..."
./build-local.sh totem_left xiao_ble --nothing > /dev/null 2>&1 || true

# Build all configurations in parallel
./build-local.sh totem_left xiao_ble &
PID_LEFT=$!

./build-local.sh totem_right xiao_ble &
PID_RIGHT=$!

./build-local.sh totem_dongle xiao_ble -DCONFIG_ZMK_STUDIO=y -DSNIPPET=studio-rpc-usb-uart &
PID_DONGLE=$!

./build-local.sh settings_reset xiao_ble &
PID_RESET=$!

# Waiting for all builds to complete and checking exit codes
FAIL=0

for job in $PID_LEFT $PID_RIGHT $PID_DONGLE $PID_RESET; do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" -gt 0 ]; then
    echo "----------------------------------------"
    echo "Error: $FAIL build(s) failed."
    exit 1
fi

echo "----------------------------------------"
echo "All builds completed! Check the root directory for .uf2 files."
ls -1 *.uf2
