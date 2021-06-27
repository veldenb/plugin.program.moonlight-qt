#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

mkdir -p /tmp/moonlight-qt/lib/

# Include dependencies not present in LibreELEC
DEPENDENCIES="
  libGL.so*
  libGLX.so*
  libGLdispatch.so*
  libQt5*
  libX11.so*
  libXau.so*
  libXdmcp.so*
  libXext.so*
  libXv.so*
  libatomic.so*
  libbsd.so*
  libdouble-conversion.so*
  libffi.so*
  libicudata.so*
  libicui18n.so*
  libicuuc.so*
  libmtdev.so*
  libopus.so*
  libpcre2-16.so*
  libpng16.so*
  libwayland-client.so*
  libxcb.so*
  qt5
"

for DEP in $DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/arm-linux-gnueabihf/$DEP /tmp/moonlight-qt/lib/
done

mkdir /tmp/moonlight-qt/bin/
cp -v /usr/bin/moonlight-qt /tmp/moonlight-qt/bin/

