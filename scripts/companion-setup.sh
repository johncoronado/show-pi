#!/usr/bin/env bash

#Get install script install.sh from github.
curl -O https://raw.githubusercontent.com/bitfocus/companion-pi/main/install.sh

#Make the script executable
chmod +x install.sh

#Sets stable build and runs the script with root privileges using bash
sudo COMPANION_BUILD="v3.5.4" bash install.sh

#Removes the script from show-pi directory
rm install.sh

# Starts the compannion service
sudo systemctl start companion.service
