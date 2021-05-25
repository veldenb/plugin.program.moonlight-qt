#!/bin/bash

set -e

cd "$(dirname "$0")"

BUILD_PATH="$(pwd)"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  ADDON_PROFILE_PATH="$(pwd)/../../../../userdata/addon_data/plugin.program.moonlight-qt/"
fi

if ! command -v docker &> /dev/null
then
    echo "Docker is not installed, please install the Kodi Docker add-on."
    exit 1
fi

# Make sure no previous image exists
docker rmi --force moonlight-qt &> /dev/null || true

# Install moonlight-qt in a container, the whole process will claim about 500MB drive space
docker build --tag moonlight-qt .

# Switch to the add-on profile path
mkdir -p "$ADDON_PROFILE_PATH"
cd "$ADDON_PROFILE_PATH"

# Create an empty temporary folder
rm -rf tmp
mkdir tmp

# Make sure no previous container exists
docker rm --force moonlight-qt &> /dev/null || true

# Extract files from container
docker create --name moonlight-qt moonlight-qt
docker cp moonlight-qt:/home/moonlight-qt tmp

# Clean up
docker rm moonlight-qt
docker container prune --force
docker rmi moonlight-qt
docker rmi navikey/raspbian-buster
docker image prune --force

# Move the moonlight-qt build to the lib-folder
rm -rf moonlight-qt
mv tmp/moonlight-qt .
rmdir tmp

exit 0