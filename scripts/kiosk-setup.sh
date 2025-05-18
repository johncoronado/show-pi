#!/bin/bash

# Check if the script is being run as root, exit if true
if [ "$(id -u)" -eq 0 ]; then
  echo "This script should not be run as root. Please run as a regular user with sudo permissions."
  exit 1
fi

# Get the current username
CURRENT_USER=$(whoami)

# Install greetd
sudo apt install -y greetd > /dev/null 2>&1 &

# Create or overwrite /etc/greetd/config.toml
sudo mkdir -p /etc/greetd
sudo bash -c "cat <<EOL > /etc/greetd/config.toml
[terminal]
vt = 7
[default_session]
command = \"/usr/bin/labwc\"
user = \"$CURRENT_USER\"
EOL"

# Enable greetd service and set graphical target
sudo systemctl enable greetd > /dev/null 2>&1 &
sudo systemctl set-default graphical.target > /dev/null 2>&1 &

# create an autostart script for labwc?
USER_URL="127.0.0.1:4001/timer"

# Create or overwrite /etc/greetd/config.toml
LABWC_AUTOSTART_DIR="/home/$CURRENT_USER/.config/labwc"
LABWC_AUTOSTART_FILE="$LABWC_AUTOSTART_DIR/autostart"
    
    
# Create or append Chromium start command to the autostart file
if grep -q "chromium" "$LABWC_AUTOSTART_FILE"; then
   echo "Chromium autostart entry already exists in $LABWC_AUTOSTART_FILE."
else
   echo "/usr/bin/chromium-browser --incognito --autoplay-policy=no-user-gesture-required --kiosk $USER_URL &" >> "$LABWC_AUTOSTART_FILE"
fi
    
# cleaning up apt caches
sudo apt clean > /dev/null 2>&1 &

# Runs hide-cursor script
bash scripts/hide-labwc-cursor.sh

# Print completion message
echo -e "Ontime Kiosk created"
