#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

# Destination for the executable
TARGET_PATH="$TMP_PATH/bin/moonlight-qt"


# When armv7l is detected we'll assume we are running Raspbian and use the official install script
if [ ! -f /usr/bin/moonlight-qt ]
then
  curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | distro=raspbian codename=buster sudo -E bash
fi

sudo apt update
sudo apt install -y moonlight-qt

# Create symlink
mkdir -p "$(dirname "$TARGET_PATH")"
ln -s /usr/bin/moonlight-qt "${TARGET_PATH}"
