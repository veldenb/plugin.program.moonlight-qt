#!/bin/bash

set -e

cd "$(dirname "$0")"

mkdir -p /home/moonlight-qt/lib/
cd /home/moonlight-qt/lib/

# RPi4
cp -vP -r /usr/lib/arm-linux-gnueabihf/qt5 .
cp -vP /usr/lib/arm-linux-gnueabihf/libGL.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libGLX.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libGLdispatch.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libQt5* .
cp -vP /usr/lib/arm-linux-gnueabihf/libX11.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libXau.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libXdmcp.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libXext.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libXv.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libatomic.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libbsd.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libdouble-conversion.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libffi.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libicudata.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libicui18n.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libicuuc.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libmtdev.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libopus.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libpcre2-16.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libpng16.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libwayland-client.so* .
cp -vP /usr/lib/arm-linux-gnueabihf/libxcb.so* .

# Optional
cp -vP /usr/lib/arm-linux-gnueabihf/libopus.so* .

cd ..
mkdir bin
cp -v /usr/bin/moonlight-qt bin/

