# Stop kodi
killall -9 kodi.bin # hard kill so it does not send HDMI CEC Off command to the TV 
sudo stop xbmc      # stop the service so it does not auto respawn kodi
