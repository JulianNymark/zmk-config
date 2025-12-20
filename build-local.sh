#!/bin/bash

# Default values
SHIELD=${1:-totem_left}
BOARD=${2:-xiao_ble}
EXTRA_ARGS=${@:3}
ZMK_CONFIG="/workspace/config"

# Ensure the build directory exists
mkdir -p build

echo "Building $SHIELD for $BOARD..."

docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  zmkfirmware/zmk-dev-arm:3.5 \
  bash -c "
    git config --global --add safe.directory '*'
    if [ ! -d '.west' ]; then
      west init -l config
    fi
    
    if [ ! -d 'zephyr' ] || [ ! -d 'zmk/app' ]; then
      echo 'Workspace incomplete. Running west update...'
      west update
      west zephyr-export
    fi
    
    # Remove symlink if it exists to avoid Kconfig recursion
    [ -L 'zmk/zephyr' ] && rm 'zmk/zephyr'
    
    export ZEPHYR_BASE='/workspace/zephyr'
    
    cd zmk/app
    # Pass Zephyr_DIR to help find_package(Zephyr) without symlinks
    west build -p always -b $BOARD -d /workspace/build -- -DSHIELD=$SHIELD -DZMK_CONFIG=\"$ZMK_CONFIG\" -DZephyr_DIR=/workspace/zephyr/share/zephyr-package/cmake $EXTRA_ARGS
    
    if [ -f /workspace/build/zephyr/zmk.uf2 ]; then
      cp /workspace/build/zephyr/zmk.uf2 /workspace/${SHIELD}-${BOARD}.uf2
    else
      echo 'Error: Build failed, no .uf2 file generated.'
      exit 1
    fi
  "
