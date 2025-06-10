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
    sudo apt install chromium-browser xserver-xorg xinit x11-xserver-utils openbox xterm -y

    # Copies .xinitrc file
    cp "/home/$CURRENT_USER/show-pi/config-files/xinitrc.conf" "/home/$CURRENT_USER/.xinitrc"

    sudo tee /etc/systemd/system/x11-session.service > /dev/null <<EOF
[Unit]
Description=Start X11 session with Chromium and pqiv
After=network.target

[Service]
User=$CURRENT_USER
Environment=DISPLAY=:0
ExecStart=/usr/bin/startx
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable x11-session.service
    sudo systemctl start x11-session.service

    echo -e "Display output setup complete."
else
    echo -e "Skipped display output setup\n"
fi
