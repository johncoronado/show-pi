#!/bin/bash

# Asks to run script
echo -ne "\n\033[1mSet up display output?\033[0m (y/n): "
read -r -p "" choice < /dev/tty

if [[ "$choice" =~ ^[Yy]$ ]]; then

    echo -e "Enabling HDMI output...\n"
    # Check if the script is being run as root, exit if true
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script should not be run as root. Please run as a regular user."
        exit 1
    fi

    # Get the current username
    CURRENT_USER=$(whoami)

    # Install packages
    sudo apt install --no-install-recommends unclutter-xfixes chromium-browser xserver-xorg xinit x11-xserver-utils openbox xterm xserver-xorg-legacy -y

    # Copies .xinitrc file
    cp "/home/$CURRENT_USER/show-pi/config-files/xinitrc.conf" "/home/$CURRENT_USER/.xinitrc"

    # activates x11 session as a systemd service. 
    sudo tee /etc/systemd/system/x11-session.service > /dev/null <<EOF
[Unit]
Description=Start X11 session with Chromium and pqiv
After=network.target

[Service]
User=$CURRENT_USER
Environment=DISPLAY=:0
ExecStart=/usr/bin/startx
Restart=on-failure
SendSIGKILL=yes
KillMode=mixed
TimeoutStopSec=1
ExecStop=/usr/bin/pkill Xorg

[Install]
WantedBy=multi-user.target
EOF

    # checks for config in Xwrapper before trying to add.
    if ! grep -q '^allowed_users=anybody' /etc/X11/Xwrapper.config 2>/dev/null; then
      echo -e "\nallowed_users=anybody\nneeds_root_rights=yes" | sudo tee -a /etc/X11/Xwrapper.config
    else
      echo "Xwrapper.config already contains allowed_users=anybody"
    fi

    # Reloads and enables x11 session service
    sudo systemctl daemon-reload
    sudo systemctl enable x11-session.service
    sudo systemctl start x11-session.service

    echo -e "Display output setup complete."
else
    echo -e "Skipped display output setup\n"
fi
