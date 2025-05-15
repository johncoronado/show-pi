#!/bin/bash

echo "Starting Ontime Docker setup..."

# Install Docker for raspi from official documentation
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

# Start docker-compose in detached mode
sudo docker-compose up -d 

echo "Ontime Docker container started."

