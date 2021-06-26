#!/bin/bash

# Only for debugging
#export QT_DEBUG_PLUGINS=1

set -e

usage() {
  echo "Usage: $0 [OPTION]... -- [MOONLIGHT_ARG]..."
  echo "Configure and run Moonlight."
  echo
  echo "Options:"
  echo "  -a NAME    use given NAME as default ALSA audio output device"
  echo "  -h         display this help and exit"
  echo
  echo "Examples:"
  echo "  $0 -a hw:0,0"
  echo "    Start Moonlight using default audio output device"
  echo "  $0 -a hdmi:CARD=PCH,DEV=0 -- stream 192.168.1.2 Desktop"
  echo "    Start streaming Desktop through Moonlight using HDMI audio output"
}

. /etc/profile

cd "$(dirname "$0")"

while getopts ":a:h" opt; do
  case $opt in
    a)
      ALSA_PCM_NAME="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $(($OPTIND -1))
MOONLIGHT_ARGS="$@"

HOME="$ADDON_PROFILE_PATH/moonlight-home"
MOONLIGHT_PATH="$ADDON_PROFILE_PATH/moonlight-qt"

# Setup environment
export XDG_RUNTIME_DIR=/var/run/

# Do not use pulseaudio because LibreELEC only uses it for output to Bluetooth speakers
export PULSE_SERVER=none

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
if [ ! -z "$ALSA_PCM_NAME" ]; then
  echo "Custom audio device: '$ALSA_PCM_NAME'"
  echo "pcm.!default \"$ALSA_PCM_NAME\"" >> "$CONF_FILE"
fi

# Stop kodi
systemctl stop kodi

# Start moonlight-qt and log to log file
echo "--- Starting Moonlight ---"
./moonlight-qt "$@"

# Start kodi
systemctl start kodi
