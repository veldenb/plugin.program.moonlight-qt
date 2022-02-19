
# Use latest compatible Debian version
FROM amd64/debian:buster

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
ENV TARGET=desktop

RUN mv scripts/install-base-deps.sh /opt/scripts/
RUN /bin/bash -c /opt/scripts/install-base-deps.sh && \
    apt-get install -y --no-install-recommends libwayland-dev wayland-protocols libva-dev libvdpau-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN mv FFmpeg /opt/FFmpeg
RUN mv nv-codec-headers /opt/nv-codec-headers
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

