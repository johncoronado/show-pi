#!/bin/bash

# Asks to run script
echo -e -n  "\n\033[1m"Install Ontime Timer?"\033[0m (y/n): "

read -r -p "" choice < /dev/tty
    if [[ "$choice" =~ ^[Yy]$ ]]; then

        # Install Docker for raspi from official documentation
        echo "Starting Ontime Docker setup..."
        echo "Downloading Docker"
        curl -sSL https://get.docker.com | sh

        # Add current user to docker group
        sudo usermod -aG docker $USER

        # Pull latest Ontime Docker image
        sudo docker pull getontime/ontime

        # Navigate to config-files directory
        cd ~/show-pi/config-files || {
          echo "Error: ~/config-files directory not found."
          exit 1
        }
        # Install docker-compose
        echo "Downloading docker-compose"
        sudo apt install -y docker-compose

        # Start docker-compose in detached mode
        echo "Starting docker with docker compose in detached mode"
        sudo docker-compose up -d 

        echo "Ontime Docker container started."
    else
        echo -e "Skipped Ontimer Timer insatll.\n"
    fi
