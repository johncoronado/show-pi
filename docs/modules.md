### Bitfocus Companion  
  To control Companion, http://hostname.local:8000 or http://YOUR-IP-ADDRESS:8000  
  The main local UI web page is dependant on your network and Raspberry Pi hostname.  When you use the Raspberry Pi Imager to download your OS, you have a chance to set your hostname. The URL will be displayed once the module finishes installing. For example, if your hostname was set to show-pi during set up, then your URL will be http://show-pi.local:8000. If you have work with companion before, this process has not changed. Please refer to (<https://github.com/bitfocus/companion/wiki>)

### Ontime  
  To control Ontime, http://hostname.local:4001/editor or http://YOUR-IP-ADDRESS:4001/editor  
  The main local UI web page is dependant on your network and Raspberry Pi hostname.  When you use the Raspberry Pi Imager to download your OS, you have a chance to set your hostname. The URL will be displayed once the module finishes installing. For example, if your hostname was set to show-pi during set up, then your URL will be http://show-pi.local:8000. Please refer to (<https://docs.getontime.no/ontime/>)

### Samba File Share  
  This module sets up two directories for file sharing over the network, your home directory and the newly created "show-files" directory. Both directories are password protected with the password that you set in the module install. This can be the same as your user login for ease of use. But, you may choose another password as well. The "show-files" directory is located on the pi at ~/show-pi/show-files. This module was made with sharing productions assets and client content like PowerPoints over the network. Typical use case would be, receiving PowerPoint files in one location, and coping the files over to each playback, notes, and backup machines. This does assume that all playback machines will be networked together. This is useful for GFX, Playback, V2 operators.

  To access the share on MacOS, the share may populate on the Finder window sidebar if the "Bonjour computers" locations is selected in the Finder settings. For manual access press command-K to bring up the Connect to Server window. Then, type smb://HOSTNAME.local where the HOSTNAME is the name you set the Raspberry Pi during imager process on Raspberry Pi Imager. If you did not set a HOSTNAME during the setup, the Raspberry Pi default hostname is raspberrypi. 

### Image Playback  
  This module doesn't need tha Samba file share module but it would greatly benefit from having it installed. The images module creates a "show-images" directory in the show-files directory and looks for image files to be played out on display output HDMI0. Regardless if one or two monitors are connected. The show-images directory will auto-play most image files dropped into it at full-screen. You may also drop a folder with multiple images in and the program is designed to auto play all images as a slideshow. The slideshow timing is not customizable at the moment but may be in the future. Typical use case will be when using the Samba module, and dropping a last second still store image that you do not have time to load into your production switcher. Or, if your switcher doesn't have a still store option. Another common use case will be to create a bare-bones slideshow loop from a existing PowerPoint loop to free up a machine. This folder operates on a LTP (Last Touch Priority) meaning if you use the videos playback module, it will play from the last interacted folder. It will not mix videos and image playback. If you have a animated slide deck you need to off load onto the pi, consider making it a 1080p30 video and playing it back in a loop from the videos module. You can export the video direct from PowerPoint. 

### Video Playback  
  This module doesn't need tha Samba file share module but it would greatly benefit from having it installed. The video module creates a "show-video" directory in the show-files directory and looks for video files to be played out on display output HDMI0. Regardless if one or two monitors are connected. The show-video directory will auto-play most video files dropped into it at full-screen. You may also drop a folder with multiple video in and the program is designed to auto play all video as a loop. Typical use case will be when using the Samba module, to create a slideshow loop video from a existing PowerPoint slide show loop with animation, to free up a machine. This folder operates on a LTP (Last Touch Priority) meaning if you use the image playback module, it will play from the last interacted folder. It will not mix videos and audio playback. You can export a video direct from PowerPoint. This module may have sound on playback depending on your pi configuration. The Raspberry Pi 4 has a built-in headphones jack, but the 5 does not. External sound cards are supported on Raspberry Pi 5. 

### Spotify Connect  
  This module sets up a spotify connect device on the Raspberry Pi using Raspotify. Use your premium spotify account to play back audio for testing or private listening. Shows up on list of devices to playback on your mobile spotify app. Works with Raspberry Pi 4's built-in headphone jack. This will work with Raspberry Pi 5 with additional sound card. This module needs internet to use as the spotify connect device does not playback locally. You can select the Raspberry Pi in the Spotify app under the device selection on the Now Playing window. It's under the shuffle button on iOS. 
  
### Display Setup  
  This module is needed for anything playback or HDMI out related. This is separated in the case of user wanting to set up only the timer and companion module only without the need to display the timer locally on the Raspberry Pi. This module sets up a minimal display environment to use the chromium browser to display the timer from Ontime. It can be use for 1 or 2 screen outputs. However, in single screen mode, the timer is set to always display. Only, with playback is triggered with the image/video play over the timer. To use this module properly, the Raspberry Pi needs to boot up with the number of displays it will use, connected. So, if you need to change from 1 to 2 display use, please connect and reboot. 

### Local Website Setup  
  This module deploys a local website on the Raspberry Pi with the documentation you are currently reading. It is accessed http://HOSTNAME.local:8010.  
  The website is static with minimal components that is very lightweight and easy for the Raspberry Pi to handle. 

### USB-C Console Connect  
 This module sets up a way to communicate to the Raspberry Pi by way of a single USB-C to USB-C cable from another computer. It was made to ease the setup of the networking module. This module may be needed to change the Raspberry Pi from one networking configuration to another. This is an advanced connection topic but may be needed for some advance networking use. This module is not in the default setup script and is accessed using the instruction below.
  
- Run the USB-C Console script prior to use if you plan to change networking settings. It is recommended use is during times of hotspot or networking changes. This ensures a connection is available to revert settings if connection or access is lost.

```bash
./scripts/usbc-console.sh
```

- Connect
   Plug a USB-C cable from your Mac or PC into the Raspberry Pi’s USB-C port.

- Find the Serial Port
  - Mac: Open Terminal and run:
     ls /dev/tty.usb*
  - Windows: Open Device Manager and check under “Ports (COM & LPT)” for “USB Serial”

- Open Terminal Connection
  - Mac/Linux:
     screen /dev/tty.usbXXXXX 115200
  - Windows:
     Use PuTTY → select the correct COM port → set Speed to 115200

- Login to Pi
   When the console appears, log in with your Raspberry Pi username and password.
 
 **Hotspot Router**  
  Enables a wifi hotspot for easy control and logon in the field. Timer and companion can be accessed without a full network/router deployment. Not included in main setup script, but accessible in scripts directory. The script runs a script to ease the setup of a hot-spot name "show-pi". This hotspot can act as a quick way to control the Raspberry Pi if there is no network infrastructure. Please keep in mind, if you are not hard wired into the Pi via ethernet, you may lose access. 