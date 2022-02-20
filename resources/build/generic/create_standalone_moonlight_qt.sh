#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

apt update
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y \
  libxcb-cursor0 \
  libxcursor1 \
  libgudev-1.0-0 \
  libinput10

mkdir -p /tmp/moonlight-qt/lib/

# Include dependencies not present in LibreELEC
DEPENDENCIES="
  libICE.so*
  libSM.so*
  libXau.so*
  libXcursor.so*
  libXdmcp.so*
  libXfixes.so*
  libXi.so*
  libXrender.so*
  libbsd.so*
  libgudev-1.0.so*
  libinput.so*
  libmd.so*
  libwacom.so*
  libxcb.so*
"

for DEP in $DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/x86_64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

cp --verbose --no-dereference /lib/x86_64-linux-gnu/libcom_err.so* /tmp/moonlight-qt/lib/
cp --verbose --no-dereference /lib/x86_64-linux-gnu/libkeyutils.so* /tmp/moonlight-qt/lib/

mkdir /tmp/moonlight-qt/bin/
cp -v Moonlight-downloaded.AppImage  /tmp/moonlight-qt/bin/moonlight-qt

chown -R --reference=/tmp/moonlight-qt /tmp/moonlight-qt/
