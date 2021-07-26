#!/bin/bash

# Only for debugging
# export QT_DEBUG_PLUGINS=1

# To use a specific PulseAudio device:
# export PULSE_SINK="alsa_output.pci-0000_0a_00.1.analog-stereo"

# To disable PulseAudio:
# export PULSE_SERVER="none"

# To use a specific ALSA audio device (after disabling pulse):
# export ALSA_PCM_NAME="hdmi:CARD=PCH,DEV=0"

set -e

. /etc/profile

cd "$(dirname "$0")"

HOME="$ADDON_PROFILE_PATH/moonlight-home"
MOONLIGHT_PATH="$ADDON_PROFILE_PATH/moonlight-qt"

# Setup environment
export XDG_RUNTIME_DIR=/var/run/

# Load platform specific configuration
source ./get-platform.sh
source "../etc/$PLATFORM.sh"

# Make sure home path exists
mkdir -p "$HOME"

# Enter the Moonlight bin path
cd "$MOONLIGHT_PATH/bin"

# Configure audio output device
CONF_FILE="${HOME}/.config/alsa/asoundrc"
mkdir -p "$(dirname "$CONF_FILE")"
rm -f "$CONF_FILE"

if [ "$PULSE_SERVER" == "none" ] && [ -n "$ALSA_PCM_NAME" ]; then
  echo "Custom ALSA audio device: '$ALSA_PCM_NAME'"

  # Create a template file for ALSA
  cat <<EOT >> "$CONF_FILE"
pcm.!default "%device%"

# The audio channels need to be re-mapped for Moonlight, this seems to be a Kodi issue.
# Please file a bug-report if this mapping differs for you, the easiest way to check the channels is to test them using
# speaker setup from Windows while streaming.
pcm.!surround51 {
  type route
  slave.pcm "%device%"
  ttable {
    0.0= 1
    1.1= 1
    2.4= 1
    3.5= 1
    4.3= 1
    5.2= 1
  }
}

# The mapping for 7.1 is currently unknown (no hardware to test this)
pcm.!surround71 "%device%"
EOT

  # Replace the placeholder with the device name
  sed -i "s/%device%/$ALSA_PCM_NAME/g" "$CONF_FILE"
fi

# Stop kodi
systemctl stop kodi

# Start kodi when this script exits
trap "systemctl start kodi" EXIT

# Start moonlight-qt and log to log file
echo "--- Starting Moonlight ---"
./moonlight-qt "$@"
