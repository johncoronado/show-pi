#!/bin/bash

# Sourcing spinner
source "$HOME/show-pi/scripts/spinner.sh"

# Asks to run script
echo -e -n "\n\033[1m"Install Show-Pi Images?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

	IMAGES_DIR="$HOME/show-pi/show-files/show-images"

	# Installs packages for images.
	sudo apt install pqiv inotify-tools -y >/tmp/log.txt 2>&1 &
	spinner $! "Installing images program..." /tmp/log.txt
	echo "Packages installed"

	# Makes directory for playback images.
	mkdir -p "$IMAGES_DIR"
	mkdir -p "$HOME/.config/systemd/user"
	echo "Images directory created"

	# Creates a systemd service file
	sudo cp "$HOME"/show-pi/config-files/show-pi-images.conf "$HOME"/.config/systemd/user/show-pi-images.service
	echo "Copying show-pi-images.conf "

	# Enables and starts service
	echo "Starting service"

	systemctl --user daemon-reload
	systemctl --user enable show-pi-images.service
	systemctl --user start show-pi-images.service

	echo "Show-Pi-Images setup complete"
else
	echo -e "Skipped Show-Pi Images install\n"
fi
