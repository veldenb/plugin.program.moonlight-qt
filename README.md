# LibreELEC (Matrix) 10.0 Moonlight-qt launcher for the Raspberry Pi 4
A launcher and updater for running Moonlight-qt on LibreELEC/Raspberry Pi 4 systems.

## Background:
This Kodi addon-on was developed to enable Moonlight game streaming on LibreELEC systems running on a Raspberry Pi 4.
Since LibreELEC is a "just enough" distribution dependencies for Moonlight-qt are missing, requiring some extra steps to get things running. 
A simple add-on lets you install and launch Moonlight-qt from within Kodi and stream games from your PC to your LibreELEC device.
More info on Moonlight-qt for the Raspberry Pi 4 can be found here:
https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4

At the time of writing the only platform that support's Moonlight on a Raspberry Pi 4 without a running X-server seems to be Moonlight-qt. Moonlight-embedded currently doesn't work on a Pi 4. 

## Prerequisites:
- Raspberry Pi 4 device with LibreELEC (Matrix) 10.0 installed, connected to local network via ethernet (preferred) or Wi-Fi
- Gaming PC with Steam and Nvidia GeForce Experience installed, connected to local network via ethernet (preferred) or Wi-Fi
- Enough temporary storage space on your LibreELEC device to install Moonlight-qt (about 500 MB is needed)

## Instructions:
### 1. Install this plugin.
- Download [plugin.program.moonlight-qt.zip](https://github.com/veldenb/plugin.program.moonlight-qt/releases/latest/download/plugin.program.moonlight-qt.zip) and store it on your Kodi device.
- In Kodi install Docker from the LibreELEC repository: Add-ons / Install from repository / LibreELEC Add-ons / Services / Docker 
- Go to Add-ons / Install from zip file
- Select plugin.program.moonlight-qt.zip

   
### 2. Start Moonlight 
- Navigate to Games -> Moonlight Pi 4.
- Start Moonlight from the Games menu.
- The plugin will ask you to install Moonlight, choose yes and wait a few minutes.
- When the plugin has finished installing, Moonlight wil launch it
- Moonlight should start and scan for PC's with Gamestream enabled


### 3. Enable Nvidia Gamestream on your gaming PC

GeForce Experience/Settings/Shield/Gamestream (move slider to right)

![Gamestream host pop-up](https://raw.githubusercontent.com/wiki/moonlight-stream/moonlight-docs/images/gfe-gamestream-enable-small.png)

If your PC is not recognised you can try to turn it off and on again on your gaming PC.

### 4. Pair your gaming PC
Once your PC is recognised by Moonlight, you will be asked to enter a 4-digit code into Gamestream to pair Moonlight with Gamestream.
When the pairing is finished you can use Moonlight to adjust settings for streaming and launch games. Exit Moonlight and you will be returned to Kodi.

### 5. Launch games from Kodi
Because Moonlight saves its configuration and image-cache to Kodi's storage you can now browse and start your games using the Games menu in Kodi by entering the "Moonlight Pi 4" menu item. 
Remember that all games are displayed from local cache, so they are only updated when Moonlight connects to your gaming PC.

<img src="resources/screenshot-01.jpg" width="600">

### 5. Updating
When you want to update Moonlight you can use the update menu in the add-on settings and press "Update Moonlight to the latest version".
The plugin will update Moonlight and will notify you when it's finished.


<img src="resources/screenshot-02.jpg" width="600">


<img src="resources/screenshot-03.jpg" width="600">


## What magic is happening in the background when installing and updating?
Essentially the plugin uses Docker to download Debian Buster and install Moonlight-qt by automating the command's given on this page: \
https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4 \
When that installation procedure is finished the plugin copies the needed executables and libraries from the Docker container and then destroys the container.
The plugin can use the copied files to launch Moonlight-qt from Kodi without the extra overhead from Docker. 

## Help, it doesn't work
You can always open an issue if Moonlight doesn't launch/update on a Raspberry Pi 4 or the game menu doesn't work.
All configuration and streaming problems are probably related to Moonlight self, you can report that on their own GitHub page: https://github.com/moonlight-stream/moonlight-qt   

## Thanks
Thanks to @clarkemw and @peetie2k from [clarkemw/moonlight-embedded-launcher](https://github.com/clarkemw/moonlight-embedded-launcher) for inspiration. 

## TODO:
- Maybe other platforms/distributions
