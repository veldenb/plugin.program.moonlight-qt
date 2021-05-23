#!/bin/bash

cd "$(dirname "$0")"

if ! command -v docker &> /dev/null
then
    echo "Docker is not installed, please install Docker from the Kodi add-ons."
    exit 1
fi

# Make sure no previous image exists
docker rmi --force moonlight-qt &> /dev/null || true

# Install moonlight-qt in a container, the whole process will claim about 500MB drive space
docker build --tag moonlight-qt .

# Create an empty temporary folder
rm -rf tmp
mkdir tmp

# Make sure no previous container exists
docker rm --force moonlight-qt &> /dev/null || true

# Extract files from container
docker create --name moonlight-qt moonlight-qt
docker cp moonlight-qt:/home/moonlight-qt tmp

# Clean up
docker rm moonlight-qt
docker container prune --force
docker rmi moonlight-qt
docker rmi navikey/raspbian-buster
docker image prune --force

# Move the moonlight-qt build to the lib-folder
mkdir -p ../lib
rm -rf ../lib/moonlight-qt
mv -v tmp/moonlight-qt ../lib/
rmdir tmp

exit 0