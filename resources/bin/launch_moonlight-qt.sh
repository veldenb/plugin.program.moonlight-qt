#!/bin/bash

set -e

. /etc/profile

cd "$(dirname "$0")"
cd ..

RESOURCE_PATH="$(pwd)"
HOME="$RESOURCE_PATH/lib/moonlight-home"
MOONLIGHT_PATH="$RESOURCE_PATH/lib/moonlight-qt"
LIB_PATH="$MOONLIGHT_PATH/lib"

# Setup library location
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_PATH
export QML_IMPORT_PATH=$LIB_PATH/qt5/qml/
export QML2_IMPORT_PATH=$LIB_PATH/qt5/qml/
export QT_QPA_PLATFORM_PLUGIN_PATH=$LIB_PATH/qt5/plugins/

# Only for debugging
#export QT_DEBUG_PLUGINS=1

# Do not use pulseaudio because LibreELEC only uses it for output to Bluetooth speakers
export PULSE_SERVER=none

# Make sure home path exists
mkdir -p "$HOME"

# Enter the Moonlight bin path
cd "$MOONLIGHT_PATH/bin"

# Stop kodi
systemctl stop kodi

# Start moonlight-qt
./moonlight-qt "$@"

# Start kodi
systemctl start kodi
