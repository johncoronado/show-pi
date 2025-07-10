#!/bin/bash

# Sourcing spinner
source "$HOME/show-pi/scripts/spinner.sh"

# Asks to run script
echo -e -n "\n\033[1m"Install images module?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

	IMAGES_DIR="$HOME/show-pi/show-files/show-images"

	# Installs packages for images.
	sudo apt install -y pqiv inotify-tools >/tmp/log.txt 2>&1 &
	spinner $! "Installing images program..." /tmp/log.txt
	
	# Makes directory for playback images.
	mkdir -p "$IMAGES_DIR"
	mkdir -p "$HOME/.config/systemd/user"
	
	# Creates a systemd service file
	sudo cp "$HOME"/show-pi/config-files/show-pi-images.conf "$HOME"/.config/systemd/user/show-pi-images.service
	
	# Enables and starts service
	systemctl --user daemon-reload
	systemctl --user enable show-pi-images.service
	systemctl --user start show-pi-images.service

	echo "Images module setup complete"
else
	echo -e "Skipped images module\n"
fi
