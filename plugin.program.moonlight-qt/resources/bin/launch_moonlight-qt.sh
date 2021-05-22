#!/bin/bash

. /etc/profile

cd "$(dirname "$0")"
cd ..

HOME="$(pwd)/lib/moonlight-home"
MOONLIGHT_FOLDER="$(pwd)/lib/moonlight-qt"
LIB="$MOONLIGHT_FOLDER/lib"

# Setup library location
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB
export QML_IMPORT_PATH=$LIB/qt5/qml/
export QML2_IMPORT_PATH=$LIB/qt5/qml/
export QT_QPA_PLATFORM_PLUGIN_PATH=$LIB/qt5/plugins/

# Only for debugging
#export QT_DEBUG_PLUGINS=1
#set

# Do not use pulseaudio because LibreElec only uses it for bluetooth speakers
export PULSE_SERVER=none

# Make sure home-dir exists
mkdir -p $HOME

cd "$MOONLIGHT_FOLDER/bin"

# Stop kodi
systemctl stop kodi

# Start moonlight-qt
./moonlight-qt "$@"

# Start kodi
systemctl start kodi
