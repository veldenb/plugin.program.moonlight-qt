#!/bin/bash

set -e

cd "$(dirname "$0")"

source ../bin/get-platform.sh

BUILD_SYSTEM="$PLATFORM_DISTRO"

if [ "$PLATFORM_DISTRO" = "coreelec" ]; then
  # CoreELEC works mostly the same as LibreELEC
  BUILD_SYSTEM="libreelec"
elif { [ "$PLATFORM_DISTRO" = "debian" ] || [ "$PLATFORM_DISTRO" = "osmc" ] || [ "$PLATFORM_DISTRO" = "raspbian" ]; } && { [ "$PLATFORM_ARCH" = "armhf" ] || [ "$PLATFORM_ARCH" = "aarch64" ] ;}; then
  # Only ARM-builds are available through APT
  BUILD_SYSTEM="debian"
elif [ "$PLATFORM_DISTRO" != "libreelec" ] && [ "$PLATFORM_ARCH" = "x86_64" ]; then
  # For platforms other than LibreELEC the x68_64 AppImage can be used
  BUILD_SYSTEM="app_image"
fi

# Check platform support
if [ ! -f "${BUILD_SYSTEM}/build.sh" ]; then
  echo "Sorry, platform ${PLATFORM_DISTRO} currently not supported!"
  exit 1
else
  echo "Building ${BUILD_SYSTEM} ${PLATFORM_ARCH}..."
fi

# Kodi profile path
if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  ADDON_PROFILE_PATH="$(realpath ~/.kodi/userdata/addon_data/plugin.program.moonlight-qt/)"
fi

# Temporary path for building
TMP_PATH="$ADDON_PROFILE_PATH/tmp"

# Create to the add-on profile path
mkdir -p "$ADDON_PROFILE_PATH"

# Create an empty temporary folder
rm -rf "$TMP_PATH"
mkdir "$TMP_PATH"

# Change to the platform specific path
cd "${BUILD_SYSTEM}"

# Build moonlight-qt folder
source ./build.sh

# Switch to the add-on profile path
cd "$ADDON_PROFILE_PATH"

# Move the moonlight-qt build to the lib-folder
rm -rfv moonlight-qt
mv -v tmp moonlight-qt

exit 0
