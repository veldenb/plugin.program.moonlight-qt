# Dockerized version for the Raspberry Pi 4 of moonlight-qt (https://github.com/moonlight-stream/moonlight-qt)
#
# Run syntax: 
#	docker build --tag moonlight-qt .
#

FROM navikey/raspbian-buster

RUN sudo apt-get update

# If you want to update all the libraries to the latest version you can but it takes a long time
# RUN sudo apt dist-upgrade -y

RUN sudo apt-get --no-install-recommends install -y curl apt-transport-https

# See Installing Moonlight Qt on Raspberry Pi 4 (https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4)
RUN curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | sudo -E bash
RUN sudo apt update
RUN sudo apt --no-install-recommends install -y moonlight-qt libgl1

# Copy the needed libraries
COPY create_standalone_moonlight_qt.sh /tmp/
RUN chmod a+x /tmp/create_standalone_moonlight_qt.sh
RUN /tmp/create_standalone_moonlight_qt.sh

ENTRYPOINT [ "bash" ]
