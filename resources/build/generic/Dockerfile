# Dockerized version for the x86_64 of moonlight-qt (https://github.com/moonlight-stream/moonlight-qt)
#
# Run syntax:
#	docker build --tag moonlight-qt .
#

# Debian Buster has Qt version new enough to fill Moonlight's build
# requirements, Buster is also one of LibreELEC's supported versions
FROM debian:buster-slim

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    libsm-dev \
    patchelf \
    squashfs-tools \
    wget \
 && rm -rf /var/lib/apt/lists/*

RUN VERSION=$(git ls-remote --tags https://github.com/moonlight-stream/moonlight-qt.git \
   | cut -f2 \
   | sed 's|refs/tags/v||' \
   | grep -E '^[0-9.]+' \
   | sort -r --version-sort \
   | head -n1 \
 ) \
 && wget "https://github.com/moonlight-stream/moonlight-qt/releases/download/v${VERSION}/Moonlight-${VERSION}-x86_64.AppImage" \
   -O /tmp/Moonlight-downloaded.AppImage \
 && wget "https://github.com/AppImage/AppImageKit/releases/download/13/runtime-x86_64" \
   -O /tmp/runtime

# Script to copy the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]
