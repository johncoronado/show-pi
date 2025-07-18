#!/bin/bash

# Sourcing spinner script in scripts directory
source "$HOME/show-pi/scripts/spinner.sh"

# Asks to run script
echo -ne "\n\033[1mSet up display outputs?\033[0m (y/n): "
read -r -p "" choice </dev/tty

if [[ "$choice" =~ ^[Yy]$ ]]; then

    # Check if the script is being run as root, exit if true
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script should not be run as root. Please run as a regular user."
        exit 1
    fi

    # Get the current username
    CURRENT_USER=$(whoami)

    # Creates .cache directory
    mkdir ~/.cache

    # Install packages
    sudo apt install --no-install-recommends greetd unclutter-xfixes chromium-browser xserver-xorg xinit x11-xserver-utils openbox xterm xserver-xorg-legacy -y >/tmp/log.txt 2>&1 &
    spinner $! "Setting up display outputs..." /tmp/log.txt

    # Copies .xinitrc file
    cp "/home/$CURRENT_USER/show-pi/config-files/xinitrc.conf" "/home/$CURRENT_USER/.xinitrc"

    # Sets greetd service file
    sudo tee /etc/greetd/config.toml > /dev/null <<EOF
[terminal]
vt = 7

[default_session]
command = "startx $HOME/.xinitrc"
user = "$CURRENT_USER"
EOF

    # Enable greetd
    sudo systemctl enable greetd
    sudo systemctl set-default graphical.target

    # checks for config in Xwrapper before trying to add.
    if ! grep -q '^allowed_users=anybody' /etc/X11/Xwrapper.config 2>/dev/null; then
        echo -e "\nallowed_users=anybody\nneeds_root_rights=yes" | sudo tee -a /etc/X11/Xwrapper.config > /dev/null
    fi

    # Copies config to force rpi5 to used correct setting for gpu
    sudo cp "$HOME"/show-pi/config-files/99-v3d.conf /etc/X11/xorg.conf.d/

    # Disable gett@tty service
    sudo systemctl disable getty@tty1.service
    sudo systemctl mask getty@tty1.service

    echo -e "Display outputs setup complete."
else
    echo -e "Skipped display outputs setup\n"
fi
