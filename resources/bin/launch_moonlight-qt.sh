#!/bin/bash

# Only for debugging
# set -e
#export QT_DEBUG_PLUGINS=1

. /etc/profile

cd "$(dirname "$0")"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  ADDON_PROFILE_PATH="$(pwd)/../../../../userdata/addon_data/plugin.program.moonlight-qt/"
fi

HOME="$ADDON_PROFILE_PATH/moonlight-home"
MOONLIGHT_PATH="$ADDON_PROFILE_PATH/moonlight-qt"
LIB_PATH="$MOONLIGHT_PATH/lib"

# Setup environment
export XDG_RUNTIME_DIR=/var/run/

# Setup library location
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_PATH
export QML_IMPORT_PATH=$LIB_PATH/qt5/qml/
export QML2_IMPORT_PATH=$LIB_PATH/qt5/qml/
export QT_QPA_PLATFORM_PLUGIN_PATH=$LIB_PATH/qt5/plugins/


# Do not use pulseaudio because LibreELEC only uses it for output to Bluetooth speakers
export PULSE_SERVER=none

# Make sure home path exists
mkdir -p "$HOME"

# Enter the Moonlight bin path
cd "$MOONLIGHT_PATH/bin"

# Stop kodi
systemctl stop kodi

# Start moonlight-qt and log to log file
./moonlight-qt "$@" > "$ADDON_PROFILE_PATH/moonlight-qt.log"

# Start kodi
systemctl start kodi
