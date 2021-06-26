#!/bin/bash

# Make sure al needed files end up in /tmp/moonlight-qt/

set -e

cd /tmp

# Running AppImage inside docker fails if we don't remove some magic bits first,
# see: https://github.com/AppImage/AppImageKit/issues/828
dd if=/dev/zero bs=1 count=3 seek=8 conv=notrunc of=Moonlight-downloaded.AppImage

chmod +x Moonlight-downloaded.AppImage

# Extract AppImage's contents to /tmp/squashfs-root
./Moonlight-downloaded.AppImage --appimage-extract

# Include dependencies not present in LibreELEC
DEPENDENCIES="
  libbsd.so*
  libICE.so*
  libSM.so*
  libXau.so*
  libxcb.so*
  libXdmcp.so*
"

for DEP in $DEPENDENCIES; do
  cp /usr/lib/x86_64-linux-gnu/$DEP squashfs-root/usr/lib/
  patchelf --set-rpath '$ORIGIN' squashfs-root/usr/lib/$DEP
done

# Recreate Moonlight's AppImage
mksquashfs squashfs-root moonlight.squashfs -root-owned -noappend
cat runtime > Moonlight.AppImage
cat moonlight.squashfs >> Moonlight.AppImage
chmod +x Moonlight.AppImage

mkdir -p /tmp/moonlight-qt/bin/
mv /tmp/Moonlight.AppImage /tmp/moonlight-qt/bin/moonlight-qt
