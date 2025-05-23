#!/bin/bash

echo -e "Installing Raspotify"

# Installs Raspotify from github. 
sudo apt-get -y install curl && curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

echo -e "Raspotify installed" 
