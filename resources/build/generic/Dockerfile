
# Use latest compatible Debian version
FROM debian:bullseye-slim

# Install required packages and download Moonligh-qt AppImage version
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    wget \
    libsm6 \
    libxi6 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && VERSION=$(git ls-remote --tags https://github.com/moonlight-stream/moonlight-qt.git \
   | cut -f2 \
   | sed 's|refs/tags/v||' \
   | grep -E '^[0-9.]+' \
   | sort -r --version-sort \
   | head -n1 \
 ) \
 && wget "https://github.com/moonlight-stream/moonlight-qt/releases/download/v${VERSION}/Moonlight-${VERSION}-x86_64.AppImage" \
   -O /tmp/Moonlight-downloaded.AppImage \
 && chmod a+x /tmp/Moonlight-downloaded.AppImage


# Script to extract the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]