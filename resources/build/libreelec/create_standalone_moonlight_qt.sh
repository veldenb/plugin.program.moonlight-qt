#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd "$(dirname "$0")"

mkdir -p /tmp/moonlight-qt/bin/ /tmp/moonlight-qt/lib/

# When found use the app-image
if [ -f "./Moonlight-downloaded.AppImage" ]; then
  ./Moonlight-downloaded.AppImage --appimage-extract usr/bin/moonlight
  ./Moonlight-downloaded.AppImage --appimage-extract usr/lib
  cp --verbose --no-dereference --recursive squashfs-root/usr/bin/moonlight /tmp/moonlight-qt/bin/moonlight-qt
  cp --verbose --no-dereference --recursive squashfs-root/usr/lib/* /tmp/moonlight-qt/lib/
else
  # Otherwise use APT installed binary
  cp -v /usr/bin/moonlight-qt /tmp/moonlight-qt/bin/
fi

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
  libpcre2-8.so*
  libpng16.so*
  libssl.so*
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
  libfuse.so*
  libkeyutils.so*
  libdbus-1.so*
  liblzma.so*
  libpcre.so*
"

# Dependencies from /usr/lib
for DEP in $USR_DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/*/$DEP /tmp/moonlight-qt/lib/ || echo "Skipping $DEP..."
done

# Dependencies from /lib
for DEP in $LIB_DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /lib/*/$DEP /tmp/moonlight-qt/lib/ || echo "Skipping $DEP..."
done

chown -R --reference=/tmp/moonlight-qt /tmp/moonlight-qt/
