#!/bin/bash

# Sourcing spinner script in scripts directory
source "$HOME"/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n "\n\033[1m"Install video module?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

    IMAGES_DIR="$HOME/show-pi/show-files/show-videos"

    # Installs packages for videos.
    sudo apt install mpv inotify-tools -y >/tmp/log.txt 2>&1 &
    spinner $! "Installing videos program..." /tmp/log.txt
    
    # Makes directory for playback videos.
    mkdir -p "$IMAGES_DIR"
    mkdir -p "$HOME/.config/systemd/user"
    
    # Creates a systemd service file
    sudo cp "$HOME"/show-pi/config-files/show-pi-videos.conf "$HOME"/.config/systemd/user/show-pi-videos.service
    
    # Enables and starts service
    systemctl --user daemon-reload
    systemctl --user enable show-pi-videos.service
    systemctl --user start show-pi-videos.service

    echo "Video module setup complete"
else
    echo -e "Skipped video module install\n"
fi
