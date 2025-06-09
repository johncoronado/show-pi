#!/bin/bash

echo -e "Enabling HDMI output...\n"
# Check if the script is being run as root, exit if true
if [ "$(id -u)" -eq 0 ]; then
  echo "This script should not be run as root. Please run as a reg>
  exit 1
fi

# Get the current username
CURRENT_USER=$(whoami)

# sets Ontime Timer URL to local host
USER_URL="127.0.0.1:4001/timer"

# Install packages
sudo apt install --no-install-recommends xserver-xorg xinit x11-xserver-utils openbox xterm xserver-xorg-legacy -y

# Copies .xinitrc file
cp /home/$CURRENT_USER/show-pi/config-files/xinitrc.conf /home/$CURRENT_USER/.xinitrc

# Appends Xwrapper.config file
echo -e "\nallowed_users=anybody\nneeds_root_rights=yes" | sudo tee -a /etc/X11/Xwrapper.config

# Creates a systemd service file
sudo cp $HOME/show-pi/config-files/x11-session.conf $HOME/.config/systemd/user/x11-session.service
echo "Copying x11-session.conf "

# Enables and starts service
echo "Starting service"

systemctl --user daemon-reload
systemctl --user enable x11-session.service
systemctl --user start x11-session.service

echo -e "Display output setup complete."

