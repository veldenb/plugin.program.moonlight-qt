#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

mkdir -p /tmp/moonlight-qt/lib/

apt update
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y \
  libatomic1 \
  libfuse2 \
  libgl1 \
  libgl1-mesa-dri \
  libgudev-1.0-0 \
  libinput10 \
  libmd0 \
  libmd4c0 \
  libopus0 \
  libpcre3 \
  libqt5core5a \
  libqt5gui5 \
  libqt5network5 \
  libqt5qml5 \
  libqt5quickcontrols2-5 \
  libqt5svg5 \
  libsm6 \
  libva-wayland2 \
  libvdpau-va-gl1 \
  libvdpau1 \
  libxcb-cursor0 \
  libxcursor1 \
  libxi6 \
  qml-module-qtquick-controls2 \
  qml-module-qtquick-layouts \
  qml-module-qtquick-window2 \
  qml-module-qtquick2

# Include dependencies not present in LibreELEC
USR_DEPENDENCIES="
  libGL.so*
  libGLX.so*
  libGLdispatch.so*
  libICE.so*
  libQt5*
  libSM.so*
  libX11-xcb.so*
  libX11.so*
  libXau.so*
  libXcursor.so*
  libXdmcp.so*
  libXext.so*
  libXfixes.so*
  libXi.so*
  libXrender.so*
  libatomic.so*
  libbsd.so*
  libcrypto.so*
  libdouble-conversion.so*
  libffi.so*
  libgssapi_krb5.so*
  libgudev-1.0.so*
  libicudata.so*
  libicui18n.so*
  libicuuc.so*
  libinput.so*
  libjpeg.so*
  libk5crypto.so*
  libkrb5.so*
  libkrb5support.so*
  libmd.so*
  libmd4c.so*
  libmtdev.so*
  libopus.so*
  libpcre2-16.so*
  libpng16.so*
  libva-wayland.so*
  libva-x11.so*
  libvdpau.so*
  libwayland-client.so*
  libxcb-dri3.so*
  libxcb-icccm.so*
  libxcb-image.so*
  libxcb-keysyms.so*
  libxcb-randr.so*
  libxcb-render-util.so*
  libxcb-render.so*
  libxcb-shape.so*
  libxcb-shm.so*
  libxcb-sync.so*
  libxcb-util.so*
  libxcb-xfixes.so*
  libxcb-xinerama.so*
  libxcb-xinput.so*
  libxcb-xkb.so*
  libxcb.so*
  libxkbcommon-x11.so*
  libxkbcommon.so*
  libzstd.so*
  vdpau/*
  qt5
"

LIB_DEPENDENCIES="
  libcom_err.so*
  libdbus-1.so*
  libfuse.so*
  libkeyutils.so*
  liblzma.so*
  libpcre.so*
"

# Dependencies from /usr/lib
for DEP in $USR_DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/x86_64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

# Dependencies from /lib
for DEP in $LIB_DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /lib/x86_64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

mkdir /tmp/moonlight-qt/bin/
cp -v /opt/build/moonlight-qt-*/debian/moonlight-qt/usr/bin/moonlight-qt /tmp/moonlight-qt/bin/

chown -R --reference=/tmp/moonlight-qt /tmp/moonlight-qt/
