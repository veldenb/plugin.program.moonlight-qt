#!/bin/bash

set -e

# Kodi only picks up the PATH of the Docker add-on after a restart, add it so building works right after installing Docker
export PATH="$PATH:/storage/.kodi/addons/service.system.docker/bin"

# Figure out which build is needed based on LibreELEC platform data
if [ "$PLATFORM_ARCH" = "armv7l" ]; then
  BUILD_FLAVOR="arm"
  BUILD_ARCH="arm"
elif [ "$PLATFORM_ARCH" = "aarch64" ]; then
  BUILD_FLAVOR="arm"
  BUILD_ARCH="arm64"
elif [ "$PLATFORM_ARCH" = "x86_64" ]; then
  BUILD_FLAVOR="amd64"
  BUILD_ARCH="amd64"
  # Without X11 (non-legacy Generic) VAAPI needs libva-drm, which the AppImage lacks, so Moonlight is built from source
  if [ "$LIBREELEC_DEVICE" = "Generic" ]; then
    BUILD_FLAVOR="amd64-gbm"
  fi
fi

# Use specific platform for Raspberry Pi builds, override the default ARM flavor
if [ "$PLATFORM" = "rpi" ]; then
  BUILD_FLAVOR="rpi"
fi

LOCAL_PATH=${TMP_PATH:-/tmp/moonlight-qt/${BUILD_PLATFORM}/}

if [ ! -f "Dockerfile.${BUILD_FLAVOR}" ]; then
  echo "Sorry, LibreELEC platform ${PLATFORM_ARCH} currently not supported!"
  exit 1
else
  echo "Building ${PLATFORM_ARCH} with ${BUILD_FLAVOR} using arch ${BUILD_ARCH}..."
fi

# Clean up
docker rm --force moonlight-qt &> /dev/null || true
docker rmi --force moonlight-qt &> /dev/null || true

# Build
docker build --pull --file "./Dockerfile.${BUILD_FLAVOR}" --compress --tag moonlight-qt --platform "linux/${BUILD_ARCH}" .

# Run and get files
mkdir -p "$LOCAL_PATH"
docker run --rm --name moonlight-qt --volume "$LOCAL_PATH":/tmp/moonlight-qt moonlight-qt

# Clean up
docker rmi --force moonlight-qt &> /dev/null || true
