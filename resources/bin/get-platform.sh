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

# Parse project var and convert to lower case
PLATFORM="$(echo "$LIBREELEC_PROJECT" | tr '[:upper:]' '[:lower:]')"

if [ -f "../etc/${PLATFORM}.sh" ]; then
  echo "Platform $PLATFORM detected..."
else
  echo "ERROR: Unknown platform: $PLATFORM" 1>&2
  return 2
fi
