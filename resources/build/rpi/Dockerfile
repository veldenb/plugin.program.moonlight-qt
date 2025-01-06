
# Use latest compatible Debian version
FROM arm32v7/debian:bookworm-slim

# See Installing Moonlight Qt on Raspberry Pi 4 (https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4)
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y curl apt-transport-https ca-certificates gnupg \
 && echo "deb http://archive.raspberrypi.org/debian/ bookworm main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 82B129927FA3303E \
 && curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | distro=raspbian bash - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y moonlight-qt libgl1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Script to copy the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]
