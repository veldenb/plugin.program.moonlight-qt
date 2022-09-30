# Start kodi when the launch-script exits
trap "systemd-run --user kodi" EXIT
