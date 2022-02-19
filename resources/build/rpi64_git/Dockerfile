
# Use latest compatible Debian version
FROM arm64v8/debian:buster

# Checkout Moonlight-packaging
RUN mkdir -p /opt/scripts && \
    mkdir /out && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y git ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/cgutman/moonlight-packaging && \
    cd moonlight-packaging && \
    git submodule update --init --recursive && \
    mv debian /opt/

WORKDIR /moonlight-packaging

# Copied from Dockerfile.amd64.buster and slightly changed by changing COPY to RUN mv
### start ###
ENV TARGET=rpi64

RUN mv scripts/install-base-deps.sh /opt/scripts/
RUN /bin/bash -c /opt/scripts/install-base-deps.sh && \
    apt-get install -y --no-install-recommends gnupg && \
    echo "deb http://archive.raspberrypi.org/debian/ buster main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 82B129927FA3303E && \
    apt-get update && \
    apt-get install -y --no-install-recommends linux-libc-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN mv rpi-userland /opt/rpi-userland
RUN mv FFmpeg-rpi /opt/FFmpeg
RUN mv SDL2 /opt/SDL2
RUN mv SDL_ttf /opt/SDL_ttf

RUN mv scripts/build-deps.sh /opt/scripts/
RUN /bin/bash -c /opt/scripts/build-deps.sh

RUN mv scripts/build-package.sh /opt/scripts/
### end ###

# Change build-command from Dockerfile to RUN-command
RUN /bin/bash -c /opt/scripts/build-package.sh

# Script to copy the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "/tmp/create_standalone_moonlight_qt.sh" ]

