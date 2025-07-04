#!/usr/bin/env bash

# Gets spinner function
# spinner example.
#       Command > /tmp/log.txt 2>&1 &
#       spinner $! "Doing something..." /tmp/log.txt

source "$HOME/show-pi/scripts/spinner.sh"

# Asks to run script
echo -e -n "\n\033[1m"Install Companion?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

	# Get install script install.sh from github.
	curl -O https://raw.githubusercontent.com/bitfocus/companion-pi/main/install.sh

  # Make the script executable
	chmod +x install.sh

	# Sets stable build and runs the script with root privileges using bash
	sudo COMPANION_BUILD=stable bash install.sh >/tmp/log.txt 2>&1 &
	spinner $! "Installing Companion. Be ready to select build..." /tmp/log.txt
	sudo companion-update

	# Removes the script from show-pi directory
	rm install.sh

	# Starts the companion service
	sudo systemctl start companion.service
else
	echo -e "Skipped Companion install\n"
fi