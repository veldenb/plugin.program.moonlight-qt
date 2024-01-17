# Start kodi when the launch-script exits
trap "systemctl start kodi" EXIT
