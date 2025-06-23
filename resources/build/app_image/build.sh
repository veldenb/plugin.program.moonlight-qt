#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

# Destination for the executable
TARGET_PATH="$TMP_PATH/bin/moonlight-qt"

# Get AppImage download-url
DOWNLOAD_URL=$(wget --quiet --header "Accept: application/vnd.github.v3+json" --output-document - https://api.github.com/repos/moonlight-stream/moonlight-qt/releases/latest | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep ".AppImage")

# Download it
mkdir -p "$(dirname "$TARGET_PATH")"
wget "$DOWNLOAD_URL" --output-document "$TARGET_PATH"

# Make sure it's executable
chmod a+x "$TARGET_PATH"
