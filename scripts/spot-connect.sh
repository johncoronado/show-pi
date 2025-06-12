#!/bin/bash

# Sourcing spinner script in scripts directory
source $HOME/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n  "\n\033[1m"Install Raspotify"\033[0m (y/n): "
    read -r -p "" choice < /dev/tty
    if [[ "$choice" =~ ^[Yy]$ ]]; then


	echo -e "Installing Raspotify"

	# Installs Raspotify from github. 
	sudo apt-get -y install curl > /tmp/log.txt 2>&1 &
    spinner $! "Installing curl..." /tmp/log.txt
    curl -sL https://dtcooper.github.io/raspotify/install.sh | sh > /tmp/log.txt 2>&1 &
    spinner $! "Installing Raspotify..." /tmp/log.txt

	echo -e "Raspotify installed" 
    else
	echo -e "Skipped Raspotify install\n"
    fi
