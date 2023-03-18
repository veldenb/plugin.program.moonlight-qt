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
  libpcre2-16.so*
  libpng16.so*
  libssl.so*
  libwacom.so*
  libwayland-client.so*
  libxcb-icccm.so*
  libxcb-image.so*
  libxcb-keysyms.so*
  libxcb-render-util.so*
  libxcb-util.so*
  libxcb.so*
  libxkbcommon-x11.so*
  libxkbcommon.so*
  libzstd.so*
  qt5
"

for DEP in $DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/x86_64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

cp --verbose --no-dereference /lib/x86_64-linux-gnu/libcom_err.so* /tmp/moonlight-qt/lib/
cp --verbose --no-dereference /lib/x86_64-linux-gnu/libfuse.so* /tmp/moonlight-qt/lib/
cp --verbose --no-dereference /lib/x86_64-linux-gnu/libkeyutils.so* /tmp/moonlight-qt/lib/

mkdir /tmp/moonlight-qt/bin/
cp -v Moonlight-downloaded.AppImage  /tmp/moonlight-qt/bin/moonlight-qt

chown -R --reference=/tmp/moonlight-qt /tmp/moonlight-qt/
