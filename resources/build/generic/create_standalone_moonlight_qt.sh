#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

mkdir -p /tmp/moonlight-qt/lib/

# Include dependencies not present in LibreELEC
DEPENDENCIES="
  libbsd.so*
  libICE.so*
  libSM.so*
  libXau.so*
  libxcb.so*
  libXdmcp.so*
  libmd.so*
  libXi.so*
"

for DEP in $DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/x86_64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

cp --verbose --no-dereference /lib/x86_64-linux-gnu/libcom_err.so* /tmp/moonlight-qt/lib/
cp --verbose --no-dereference /lib/x86_64-linux-gnu/libkeyutils.so* /tmp/moonlight-qt/lib/

mkdir -p /tmp/moonlight-qt/bin/
cp -v Moonlight-downloaded.AppImage  /tmp/moonlight-qt/bin/moonlight-qt
