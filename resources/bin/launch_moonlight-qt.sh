#!/bin/bash

cd "$(dirname "$0")"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  export ADDON_PROFILE_PATH="$(realpath ~/.kodi/userdata/addon_data/plugin.program.moonlight-qt/)"
fi

LOCAL_BOOTSTRAP_SCRIPT="$ADDON_PROFILE_PATH/bootstrap_moonlight-qt.local.sh"

if [ -f "$LOCAL_BOOTSTRAP_SCRIPT" ]; then
  BOOTSTRAP_SCRIPT="$LOCAL_BOOTSTRAP_SCRIPT"
else
  BOOTSTRAP_SCRIPT="bootstrap_moonlight-qt.sh"
fi

bash "$BOOTSTRAP_SCRIPT" "$@" 2>&1 | tee "$ADDON_PROFILE_PATH/moonlight-qt.log"
