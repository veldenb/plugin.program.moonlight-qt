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
  libbsd.so*
  libdouble-conversion.so*
  libffi.so*
  libgssapi_krb5.so*
  libgudev-1.0.so*
  libicudata.so*
  libicui18n.so*
  libicuuc.so*
  libjpeg.so*
  libk5crypto.so*
  libkrb5.so*
  libkrb5support.so*
  libpcre2-16.so*
  libpcre2-8.so*
  libmd.so*
  libmd4c.so*
  libmtdev.so*
  libopus.so*
  libpng16.so*
  libxcb.so*
  libzstd.so*
  libwayland-client.so*
  qt5
"

LIB_DEPENDENCIES="
  libcom_err.so*
  libkeyutils.so*
  libdbus-1.so*
  liblzma.so*
"

for DEP in $DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /usr/lib/aarch64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

# Dependencies from /lib
for DEP in $LIB_DEPENDENCIES; do
  cp --verbose --no-dereference --recursive /lib/aarch64-linux-gnu/$DEP /tmp/moonlight-qt/lib/
done

mkdir /tmp/moonlight-qt/bin/
cp -v /usr/bin/moonlight-qt /tmp/moonlight-qt/bin/

chown -R --reference=/tmp/moonlight-qt /tmp/moonlight-qt/
