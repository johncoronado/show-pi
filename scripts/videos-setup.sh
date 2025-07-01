#!/bin/bash

# Sourcing spinner script in scripts directory
source $HOME/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n "\n\033[1m"Install Show-Pi Videos?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

    IMAGES_DIR="$HOME/show-pi/show-files/show-videos"

    # Installs packages for videos.
    sudo apt install mpv inotify-tools -y >/tmp/log.txt 2>&1 &
    spinner $! "Installing videos program..." /tmp/log.txt
    echo "Packages installed"

    # Makes directory for playback videos.
    mkdir -p "$IMAGES_DIR"
    mkdir -p "$HOME/.config/systemd/user"
    echo "Videos directory created"

    # Creates a systemd service file
    sudo cp $HOME/show-pi/config-files/show-pi-videos.conf $HOME/.config/systemd/user/show-pi-videos.service
    echo "Copying show-pi-videos.conf "

    # Enables and starts service
    echo "Starting service"

    systemctl --user daemon-reload
    systemctl --user enable show-pi-videos.service
    systemctl --user start show-pi-videos.service

    echo "Show-Pi-Videos setup complete"
else
    echo -e "Skipped Show-Pi Videos install\n"
fi
