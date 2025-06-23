#!/bin/bash

# This script only works when sudo is configured without a password

set -e

cd "$(dirname "$0")"

# Destination for the executable
TARGET_PATH="$TMP_PATH/bin/moonlight-qt"


if [ ! -f /usr/bin/moonlight-qt ]; then
  if grep -q "Raspbian" /etc/os-release; then
    # For Raspbian
    curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | distro=raspbian codename=$(lsb_release -cs) sudo -E bash
  else
    # For Debian, Armbian and Ubuntu based ARM distro's like OSMC
    curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | sudo -E bash
  fi
fi

sudo apt update
sudo apt install -y moonlight-qt libgl1

# Create symlink
mkdir -p "$(dirname "$TARGET_PATH")"
ln -s /usr/bin/moonlight-qt "${TARGET_PATH}"
