#!/bin/bash


# Asks to run script
echo -e -n  "\n\033[1m"Install Raspotify"\033[0m (y/n): "
    read -r -p "" choice < /dev/tty
    if [[ "$choice" =~ ^[Yy]$ ]]; then


	echo -e "Installing Raspotify"

	# Installs Raspotify from github. 
	sudo apt-get -y install curl && curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

	echo -e "Raspotify installed" 
    else
	echo -e "Skipped Raspotify install\n"
    fi
