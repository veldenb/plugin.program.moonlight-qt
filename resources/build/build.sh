#!/bin/bash

set -e

cd "$(dirname "$0")"

source ../bin/get-platform.sh

# Uncomment to build moonlight from source. This is very experimental, cross your fingers and wait for a long time...
# ALTERNATIVE_BUILD="_git"
# Only for Pi experimental 64-bit build, LibreELEC is currently 32-bit:
# ALTERNATIVE_BUILD="64_git"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  ADDON_PROFILE_PATH="$(realpath ~/.kodi/userdata/addon_data/plugin.program.moonlight-qt/)"
fi

TMP_PATH="$ADDON_PROFILE_PATH/tmp"

if ! command -v docker &> /dev/null
then
    echo "Docker is not installed, please install the Kodi Docker add-on."
    exit 1
fi

# Change to the platform specific path
cd "${PLATFORM}${ALTERNATIVE_BUILD}"

# Make sure no previous image exists
docker rmi --force moonlight-qt &> /dev/null || true

# Install moonlight-qt in a container, the whole process will claim about 500MB drive space
docker build --compress --tag moonlight-qt .

# Switch to the add-on profile path
mkdir -p "$ADDON_PROFILE_PATH"
cd "$ADDON_PROFILE_PATH"

# Create an empty temporary folder
rm -rf "$TMP_PATH"
mkdir "$TMP_PATH"

# Make sure no previous container exists
docker rm --force moonlight-qt &> /dev/null || true

# Create a new container
docker create --name moonlight-qt moonlight-qt

# Extract the moonlight-qt files
docker run --volume "$TMP_PATH":/tmp/moonlight-qt moonlight-qt

# Clean up
docker rm moonlight-qt
docker container prune --force
docker rmi moonlight-qt
docker image prune --force

# Move the moonlight-qt build to the lib-folder
rm -rf moonlight-qt
mv tmp moonlight-qt

exit 0
