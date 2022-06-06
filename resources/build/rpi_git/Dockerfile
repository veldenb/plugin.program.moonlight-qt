
# Use latest compatible Debian version
FROM arm32v7/debian:buster

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

# Workaround and SDL issue to prevent segfaulting: https://github.com/moonlight-stream/moonlight-qt/issues/645 and
# https://github.com/libsdl-org/SDL/pull/5296/commits/e02b454e7b6a18a0993a997ba19f1b83ee8cc2f6
RUN cd /moonlight-packaging/SDL2/ && git checkout tags/release-2.0.20 -b 2.0.20

WORKDIR /moonlight-packaging

# Add --arch=armv7 so no 64-bit code is compiled
RUN sed -i 's/.\/configure $BASE_FFMPEG_ARGS $EXTRA_FFMPEG_ARGS/.\/configure --arch=armv7 $BASE_FFMPEG_ARGS $EXTRA_FFMPEG_ARGS/g' scripts/build-deps.sh

# Fix automake error
RUN sed -i 's/cd \/opt\/SDL_ttf/cd \/opt\/SDL_ttf; autoreconf/g' scripts/build-deps.sh

# Copied from Dockerfile.amd64.buster and slightly changed by changing COPY to RUN mv
### start ###
ENV TARGET=rpi

RUN mv scripts/install-base-deps.sh /opt/scripts/
RUN /bin/bash -c /opt/scripts/install-base-deps.sh && \
    apt-get install -y --no-install-recommends gnupg && \
    echo "deb http://archive.raspberrypi.org/debian/ buster main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 82B129927FA3303E && \
    apt-get update && \
    apt-get install -y --no-install-recommends libraspberrypi-dev linux-libc-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

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

