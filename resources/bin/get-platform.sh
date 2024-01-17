#!/bin/bash

# This script resolves a string to describe the platform where this script is
# executed. Information is pulled from /etc/os-release. For more info see:
#   https://www.linux.org/docs/man5/os-release.html

set -e

cd "$(dirname "$0")"

for file in /etc/os-release /usr/lib/os-release; do
  if [ -f $file ]; then
    source $file
    break
  fi
done

# Parse project var remove "-ce" suffix for CoreELEC and convert to lower case
PLATFORM="$(echo "${LIBREELEC_PROJECT%-ce}" | tr '[:upper:]' '[:lower:]')"

if [ "$LIBREELEC_ARCH" == "RPi4.arm" ] \
  || [ "$LIBREELEC_ARCH" == "Amlogic-ng.arm" ] \
  || [ "$LIBREELEC_ARCH" == "AMLGX.arm" ]; then
  # Some builds run a aarch64 kernel with arm32v7 libraries
  PLATFORM_ARCH="armhf"
else
  PLATFORM_ARCH=$(uname -m)
fi

# If platform is empty try uname
if [ "$PLATFORM" == "" ]; then
  PLATFORM="$PLATFORM_ARCH"
fi

# Figure out distro (libreelec, ubuntu)
PLATFORM_DISTRO="$ID"
PLATFORM_DISTRO_RELEASE="$VERSION_ID"

if [ -d "../build/$PLATFORM" ]; then
  echo "Platform $PLATFORM ($PLATFORM_ARCH) running $PLATFORM_DISTRO $PLATFORM_DISTRO_RELEASE detected..."
else
  echo "Platform $PLATFORM ($PLATFORM_ARCH) running $PLATFORM_DISTRO $PLATFORM_DISTRO_RELEASE detected, using platform generic..."
  PLATFORM="generic"
fi
