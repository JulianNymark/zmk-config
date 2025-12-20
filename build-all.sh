#!/bin/bash

set -e

echo "Starting build for all Totem configurations..."

# Build Left
./build-local.sh totem_left xiao_ble

# Build Right
./build-local.sh totem_right xiao_ble

# Build Dongle (with ZMK Studio)
./build-local.sh totem_dongle xiao_ble -DCONFIG_ZMK_STUDIO=y -DSNIPPET=studio-rpc-usb-uart

# Build Settings Reset
./build-local.sh settings_reset xiao_ble

echo "----------------------------------------"
echo "All builds completed! Check the root directory for .uf2 files."
ls -1 *.uf2
