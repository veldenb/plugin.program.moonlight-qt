LIB_PATH="$MOONLIGHT_PATH/lib"

# Setup library locations
export LD_LIBRARY_PATH=/usr/lib/:$LIB_PATH:$LD_LIBRARY_PATH

# Nvidia VA-API not stable yet (segfault): https://github.com/elFarto/nvidia-vaapi-driver
if [[ "$LIBVA_DRIVER_NAME" -eq "nvidia" ]]; then
  LIBVA_DRIVER_NAME=""
fi
