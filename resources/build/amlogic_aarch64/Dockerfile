
# Use latest compatible Debian version
FROM arm64v8/debian:bookworm-slim

# See Installing Moonlight Qt on Raspberry Pi 4 (https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4)
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y curl apt-transport-https ca-certificates gnupg \
 && curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | bash - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y moonlight-qt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Script to copy the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]
