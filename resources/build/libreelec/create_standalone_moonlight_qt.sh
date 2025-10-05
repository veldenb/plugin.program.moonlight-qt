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
  libEGL.so*
  libGL.so*
  libGLX.so*
  libGLdispatch.so*
  libICE.so*
  libOpenCL.so*
  libOpenGL.so*
  libQt5*
  libQt6*
  libSM.so*
  libSvtAv1Enc.so*
  libX11-xcb.so*
  libX11.so*
  libXau.so*
  libXcursor.so*
  libXdmcp.so*
  libXext.so*
  libXfixes.so*
  libXi.so*
  libXrender.so*
  libaom.so*
  libatomic.so*
  libavcodec.so*
  libavutil.so*
  libb2.so*
  libbrotlicommon.so*
  libbrotlidec.so*
  libbrotlienc.so*
  libbsd.so*
  libcodec2.so*
  libcom_err.so*
  libcrypto.so*
  libdatrie.so*
  libdav1d.so*
  libdouble-conversion.so*
  libffi.so*
  libfribidi.so*
  libgdk_pixbuf-2.0.so*
  libgomp.so*
  libgpg-error.so*
  libgraphite2.so*
  libgsm.so*
  libgssapi_krb5.so*
  libgudev-1.0.so*
  libhwy.so*
  libicudata.so*
  libicui18n.so*
  libicuuc.so*
  libinput.so*
  libjpeg.so*
  libjxl.so*
  libjxl_threads.so*
  libk5crypto.so*
  libkeyutils.so*
  libkrb5.so*
  libkrb5support.so*
  liblcms2.so*
  liblz4.so*
  liblzma.so*
  libmd.so*
  libmd4c.so*
  libmp3lame.so*
  libmtdev.so*
  libogg.so*
  libopenjp2.so*
  libopus.so*
  libpango-1.0.so*
  libpangocairo-1.0.so*
  libpangoft2-1.0.so*
  libpcre2-16.so*
  libpcre2-8.so*
  libpng16.so*
  libproxy.so*
  librav1e.so*
  librsvg-2.so*
  libshine.so*
  libsnappy.so*
  libsoxr.so*
  libssl.so*
  libswscale.so*
  libthai.so*
  libtheoradec.so*
  libtheoraenc.so*
  libts.so*
  libtwolame.so*
  libva-drm.so*
  libva-wayland.so*
  libva-x11.so*
  libva.so*
  libvdpau.so*
  libvorbis.so*
  libvorbisenc.so*
  libvpx.so*
  libwayland-client.so*
  libwebp.so*
  libwebpmux.so*
  libx264.so*
  libx265.so*
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
  libxvidcore.so*
  libzstd.so*
  libzvbi.so*
  vdpau/*
  qt5
  qt6
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
