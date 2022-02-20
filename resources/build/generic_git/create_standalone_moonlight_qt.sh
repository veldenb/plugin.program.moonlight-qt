#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

mkdir -p /tmp/moonlight-qt/lib/

apt update
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y \
  libmd0 \
  libxcb-cursor0 \
  qml-module-qtquick-controls2 \
  qml-module-qtquick-layouts \
  qml-module-qtquick-window2 \
  qml-module-qtquick2

# Include dependencies not present in LibreELEC
DEPENDENCIES="
  libGL.so*
  libGLX.so*
  libGLdispatch.so*
  libICE.so*
  libQt5*
  libSM.so*
  libX11.so*
  libXau.so*
  libXcursor.so*
  libXdmcp.so*
  libXext.so*
  libXfixes.so*
  libXi.so*
  libXrender.so*
  libXv.so*
  libatomic.so*
  libbsd.so*
  libdouble-conversion.so*
  libffi.so*
  libgudev-1.0.so*
  libicudata.so*
  libicui18n.so*
  libicuuc.so*
  libinput.so*
  libjpeg.so*
  libmd.so*
  libmtdev.so*
  libopus.so*
  libpcre2-16.so*
  libpng16.so*
  libva-wayland.so*
  libwacom.so*
  libwayland-client.so*
  libxcb*
  libxkbcommon-x11.so*
  libxkbcommon.so*
  qt5
"

for DEP in $DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/*-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

mkdir /tmp/moonlight-qt/bin/
cp -v /opt/build/moonlight-qt-*/debian/moonlight-qt/usr/bin/moonlight-qt /tmp/moonlight-qt/bin/

chown -R --reference=/tmp/moonlight-qt /tmp/moonlight-qt/
