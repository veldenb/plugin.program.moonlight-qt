# Use latest compatible Debian version
FROM debian:bookworm-slim

# Install required packages and download Moonligh-qt AppImage version
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libatomic1 \
    libfuse2 \
    libgl1 \
    libgl1-mesa-dri \
    libgudev-1.0-0 \
    libinput10 \
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
    qml-module-qtquick2 \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && wget "https://github.com/moonlight-stream/moonlight-qt/releases/download/v6.0.0/Moonlight-6.0.0-x86_64.AppImage" -O /tmp/Moonlight-downloaded.AppImage \
 && chmod a+x /tmp/Moonlight-downloaded.AppImage


# Script to extract the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]