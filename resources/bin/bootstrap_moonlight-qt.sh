#!/bin/bash

# Only for debugging
# export QT_DEBUG_PLUGINS=1
# set -e
# set -x

# To use a specific PulseAudio device:
# export PULSE_SINK="alsa_output.pci-0000_0a_00.1.analog-stereo"

# To disable PulseAudio:
# export PULSE_SERVER="none"

cd "$(dirname "$0")"

# Get platform and distro
source ./get-platform.sh

# Backup paths
HOME_BACKUP="$HOME"
LD_LIBRARY_PATH_BACKUP="$LD_LIBRARY_PATH"

# Load profile on LibreELEC
if [ "$PLATFORM_DISTRO" == "libreelec" ]; then
  # Setup environment
  echo "Loading LibreELEC profile for setting up environment..."
  source /etc/profile
  export XDG_RUNTIME_DIR=/var/run/
fi

# Paths
ADDON_BIN_PATH=$(realpath ".")
MOONLIGHT_PATH="$ADDON_PROFILE_PATH/moonlight-qt"

# Alter HOME var to contain all settings in the addon profile path
export HOME="$ADDON_PROFILE_PATH/moonlight-home"

# Setup library locations
# If libraries are missing the following command on a working instance (i.e. Raspbian) can help finding the necessary libs after finding moonlight-qt's PID:
# ls -al /proc/{$MOONLIGHT-PID}/map_files/ | tr -s ' ' | grep '>' | cut -d '>' -f 2 | sort | uniq
if [ -d "$MOONLIGHT_PATH/lib" ]; then
  LIB_PATH="$MOONLIGHT_PATH/lib"
  echo "Using custom libraries from $LIB_PATH..."
  export LD_LIBRARY_PATH=/usr/lib/:$LIB_PATH:$LD_LIBRARY_PATH

  # Setup Qt library locations if present
  if [ -d "$LIB_PATH/qt5" ]; then
    echo "Using Qt library from $LIB_PATH/qt5..."
    export QML_IMPORT_PATH=$LIB_PATH/qt5/qml/
    export QML2_IMPORT_PATH=$LIB_PATH/qt5/qml/
    export QT_QPA_PLATFORM_PLUGIN_PATH=$LIB_PATH/qt5/plugins/
  fi
fi

# Hack to scale interface on EGLFS, QT_SCALE_FACTOR higher than 1.28 corrupts the layout.
if [ -z "$DISPLAY" ]; then
  echo "Running without window manager..."

  # Force display mode if needed
  KMS_CONFIG_FILE="$ADDON_PROFILE_PATH/qt_qpa_eglfs_kms_config.json"
  if [ -f "$KMS_CONFIG_FILE" ]; then
    FORCE_EGL_MODE="$(grep '"mode":' "$KMS_CONFIG_FILE" | cut -d ':' -f 2 | tr -d '[:space:]"')"
    echo "Forcing KMS mode:"
    cat "$KMS_CONFIG_FILE" && echo -e "\n"
    export QT_QPA_EGLFS_KMS_CONFIG="$KMS_CONFIG_FILE"
  fi

  # Default mode based on 1080p
  export QT_SCALE_FACTOR=0.64

  if [ -n "$FORCE_EGL_MODE" ]; then
    RESOLUTION="${FORCE_EGL_MODE/x/,}"
  elif [ -r "/sys/class/graphics/fb0/virtual_size" ]; then
    RESOLUTION=$(cat /sys/class/graphics/fb0/virtual_size)
    echo "Detected resolution $RESOLUTION..."
  fi

  # Choose a scale factor based on resolution - this scales the layout
  RESOLUTION_Y=${RESOLUTION##*,}
  if [ "$RESOLUTION_Y" = "720" ]; then
    export QT_SCALE_FACTOR=0.51
  fi

  if [ "$RESOLUTION_Y" = "1440" ]; then
    export QT_SCALE_FACTOR=1.03
  fi

  if [ "$RESOLUTION_Y" = "2160" ]; then
    export QT_SCALE_FACTOR=1.28
  fi
  echo "Using Qt scale factor $QT_SCALE_FACTOR..."

  # This setting makes the fonts conveniently large on a TV, the lower the size the bigger the fonts.
  # Use the scale factor to dynamically scale the fonts compared to the UI scaling.
  export QT_QPA_EGLFS_PHYSICAL_WIDTH=$( awk "BEGIN { print int($QT_SCALE_FACTOR*437)}" )
  export QT_QPA_EGLFS_PHYSICAL_HEIGHT=$( awk "BEGIN { print int($QT_SCALE_FACTOR*250)}" )
else
  echo "Running with window manager..."
fi

# Make sure home path exists
mkdir -p "$HOME"

# Enter the Moonlight bin path
cd "$MOONLIGHT_PATH/bin"

# Check for distro specific hooks
if [ -d "$ADDON_BIN_PATH/kodi_hooks/$PLATFORM_DISTRO" ]; then
  echo "Using Kodi hooks for $PLATFORM_DISTRO..."
  # Stop kodi using hook
  source "$ADDON_BIN_PATH/kodi_hooks/$PLATFORM_DISTRO/stop.sh"

  # Start kodi when this script exits using trap in hook
  source "$ADDON_BIN_PATH/kodi_hooks/$PLATFORM_DISTRO/start.sh"
fi

# Start moonlight-qt and log to log file
echo "--- Starting Moonlight ---"
./moonlight-qt "$@"

# For debugging, put .debug files in bin-folder for backtraces
# gdb --directory="$MOONLIGHT_PATH/bin/" ./moonlight-qt

# Restore paths
export HOME="$HOME_BACKUP"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH_BACKUP"
