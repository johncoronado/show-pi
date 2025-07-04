# Show-Pi Production Toolkit

A streamlined Raspberry Pi 4/5 configuration designed as a compact, deployable video engineering and production toolkit for corporate live event workflows.

## Overview

This project automates the setup of a Raspberry Pi to serve as a multifunctional utility device in production environments. It includes tools for show control, timing, file sharing, and visual overlays.

### Key Components

- **Bitfocus Companion**  
  Manages device control via stream decks or web interface. <https://github.com/bitfocus/companion>

- **OnTime**  
  Runs a show timer server inside Docker. The system automatically launches the full-screen timer output on HDMI0 using a minimal GUI environment. When both HDMI outputs are active on boot, the timer goes to HDMI-1. So that images and videos can play back fullscreen on HDMI-0.  <https://github.com/cpvalente/ontime>

- **Samba**  
  Provides simple file sharing between the Pi and other devices over the network. <https://github.com/samba-team/samba>

- **Image Playback**  
  Using Samba and pqiv, drop image file or files into the images share folder for immediate playback over the timer output or on HDMI-0 when timer is use on HDMI-1. Great for still-stores and looping slideshow playback. <https://github.com/phillipberndt/pqiv>

- **Video Playback**  
  Using Samba and mpv, drop a video or video files into the video share folder, for immediate playback over the timer output or on HDMI-0 when timer is use on HDMI-1. Great for looping a video/videos. 1080p max and videos should be encoded for the Pi. <https://github.com/mpv-player/mpv>

- **Spotify Connect**  
  Use your premium spotify account to play back audio for testing or private listening. Shows up on list of devices to playback on your mobile spotify app. Works with Raspberry Pi 4's built-in headphone jack. This will work with Raspberry Pi 5 with additional sound card and setup of the asound.conf file. <https://github.com/dtcooper/raspotify>

- **USB-C Serial Console**  
  Enables a serial terminal connection over the Raspberry Pi 4/5’s USB-C port. Ideal for adjusting network or router settings without needing a monitor. A single USB-C cable provides both power and serial access (via /dev/ttyGS0), making field deployment simpler and cleaner. This script is available but not run on the main setup.

- **Hotspot Router**  
  Enables a wifi hotspot for easy control and logon in the field. Timer and companion can be accessed without a full network/router deployment.

- **Dual Screen Output**  
  Use both HDMI ports for timer and image/video playback. Enables always on timer mode (HDMI-0) with playback out on black in standby for content. (HDMI-0)

## Features

- Headless-friendly setup with minimal GUI footprint.
- HDMI output of timer, images, and videos with autostart.
- Drag-and-drop images and videos to play folders to auto-play via Samba file share.
- Git-based workflow for deploying and updating config files.
- Hotspot for wireless control and config while in the field.

## Use Cases

- Backstage or FOH utility system for show calling.
- Operator station for timers, control, and playback.
- Digital signage and client branding display.
- Test video and audio signals.

## Installation

- Use the official Raspberry Pi Imager (<https://www.raspberrypi.com/software/>) to download and install Raspberry Pi OS Lite (64-bit) on your connected boot drive of choice (SD card or USB).
- Customize your OS setting on Raspberry Pi Imager to preconfigure your hostname, username, wifi, etc.
- Boot your fresh install of Raspberry Pi OS Lite. It may reboot several times on first boot.
- Log into your Pi via SSH or by connecting a keyboard/mouse into your Pi.
- Run the update commands (Each line is a separate command)

```bash
sudo apt update
sudo apt upgrade -y
```

- Reboot your system

```bash
sudo reboot
```

- Install git

```bash
sudo apt install git -y
```

- Clone the repository and run the setup script:

```bash
git clone https://github.com/johncoronado/show-pi.git
cd show-pi
./setup.sh
```

- Reboot your Pi after all scripts have finished.

```bash
sudo reboot
```

## USB-C Console Access (Mac/PC)

- Run the USB-C Console script prior to use. It is recommended use is during times of hotspot or networking changes. This ensures a connection is available to revert settings if connection or access is lost.

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

## Disclaimer

- Using all tools simultaneously can impact performance. Companion triggers and large pages can use a lot of resources. Please, test for your use cases thoroughly before using in the field.
