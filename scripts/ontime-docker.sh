#!/bin/bash

# Sourcing spinner script in scripts directory
source $HOME/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n  "\n\033[1m"Install Ontime Timer?"\033[0m (y/n): "

read -r -p "" choice < /dev/tty
    if [[ "$choice" =~ ^[Yy]$ ]]; then

        # Install Docker for raspi from official documentation
        echo "Starting Ontime Docker setup..."
        curl -sSL https://get.docker.com | sh > /tmp/log.txt 2>&1 &
        spinner $! "Getting Docker..." /tmp/log.txt

        # Add current user to docker group
        sudo usermod -aG docker $USER

        # Pull latest Ontime Docker image
        sudo docker pull getontime/ontime > /tmp/log.txt 2>&1 &
        spinner $! "Getting Ontime..." /tmp/log.txt

        # Navigate to config-files directory
        cd ~/show-pi/config-files || {
          echo "Error: ~/config-files directory not found."
          exit 1
        }
        # Install docker-compose
        sudo apt install -y docker-compose > /tmp/log.txt 2>&1 &
        spinner $! "Getting docker-compose..." /tmp/log.txt

        # Start docker-compose in detached mode
        sudo docker-compose up -d > /tmp/log.txt 2>&1 & 
        spinner $! "Starting Ontime..." /tmp/log.txt
        echo "Ontime container started."
    else
        echo -e "Skipped Ontimer Timer install.\n"
    fi
