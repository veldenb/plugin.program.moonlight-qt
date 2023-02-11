
# Use latest compatible Debian version
FROM debian:bullseye-slim

# Install required packages and download Moonligh-qt AppImage version
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libfuse2 \
    libgudev-1.0-0 \
    libinput10 \
    libsm6 \
    libxcb-cursor0 \
    libxcursor1 \
    libxi6 \
    qml-module-qtquick2 \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && DOWNLOAD_URL=$(wget --quiet --header "Accept: application/vnd.github.v3+json" --output-document - https://api.github.com/repos/moonlight-stream/moonlight-qt/releases/latest | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep ".AppImage") \
 && wget "$DOWNLOAD_URL" -O /tmp/Moonlight-downloaded.AppImage \
 && chmod a+x /tmp/Moonlight-downloaded.AppImage


# Script to extract the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]