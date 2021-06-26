#!/bin/bash

set -e

cd "$(dirname "$0")"

mkdir -p /home/moonlight-qt/lib/
cd /home/moonlight-qt/lib/

cp -v -r /usr/lib/arm-linux-gnueabihf/qt5 .
cp -v /usr/lib/arm-linux-gnueabihf/libGL.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libGLX.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libGLdispatch.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libQt5* .
cp -v /usr/lib/arm-linux-gnueabihf/libXv.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libatomic.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libdouble-conversion.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libffi.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libicudata.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libicui18n.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libicuuc.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libmtdev.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libopus.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libpcre2-16.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libpng16.so* .
cp -v /usr/lib/arm-linux-gnueabihf/libwayland-client.so* .
# Optional
cp -v /usr/lib/arm-linux-gnueabihf/libopus.so* .


cd ..
mkdir bin
cp -v /usr/bin/moonlight-qt bin/

