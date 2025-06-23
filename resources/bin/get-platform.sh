#!/bin/bash

# This script resolves a string to describe the platform where this script is
# executed. Information is pulled from /etc/os-release. For more info see:
#   https://www.linux.org/docs/man5/os-release.html

set -e

cd "$(dirname "$0")"

for OS_RELEASE in /etc/os-release /usr/lib/os-release; do
  if [ -f "$OS_RELEASE" ]; then
    source $OS_RELEASE
    break
  fi
done

# Parse project var remove "-ce" suffix for CoreELEC and convert to lower case
PLATFORM="$(echo "${LIBREELEC_PROJECT%-ce}" | tr '[:upper:]' '[:lower:]')"

if [ "$LIBREELEC_ARCH" = "RPi4.arm" ] \
  || { [ "$LIBREELEC_ARCH" = "RPi5.arm" ] && [ "$VERSION_ID" = "11.0" ] ;} \
  || [ "$LIBREELEC_ARCH" = "Amlogic-ng.arm" ] \
  || [ "$LIBREELEC_ARCH" = "AMLGX.arm" ]; then
  # Some builds run a aarch64 kernel with arm32v7 libraries
  PLATFORM_ARCH="armv7l"
else
  PLATFORM_ARCH=$(uname -m)
fi

# Older kernels report 32-bit ARM as armhf
if [ "$PLATFORM_ARCH" = "armhf" ]; then
  PLATFORM_ARCH="armv7l"
fi

# Figure out distro (libreelec, ubuntu etc)
PLATFORM_DISTRO="$ID"
PLATFORM_DISTRO_RELEASE="$VERSION_ID"

# If LibreELEC platform is empty try distro
if [ "$PLATFORM" = "" ]; then
  PLATFORM="$PLATFORM_DISTRO"
fi

# Show some details about the current LibreELEC install
if [ "$LIBREELEC_PROJECT" != "" ]; then
  echo "LibreELEC project: ${LIBREELEC_PROJECT} version ${VERSION_ID}"
  echo "LibreELEC arch: ${LIBREELEC_ARCH}"
fi

echo "Platform $PLATFORM ($PLATFORM_ARCH) running $PLATFORM_DISTRO $PLATFORM_DISTRO_RELEASE detected..."