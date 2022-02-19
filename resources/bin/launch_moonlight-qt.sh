#!/bin/bash

cd "$(dirname "$0")"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  export ADDON_PROFILE_PATH="$(pwd)/../../../../userdata/addon_data/plugin.program.moonlight-qt/"
fi

bash bootstrap_moonlight-qt.sh "$@" 2>&1 | tee "$ADDON_PROFILE_PATH/moonlight-qt.log"
