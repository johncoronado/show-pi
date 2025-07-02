#!/bin/bash

# Sourcing spinner script in scripts directory
# shellcheck source=/dev/null
source "$HOME"/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n "\n\033[1m"Install Ontime Timer?"\033[0m (y/n): "

read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

    # Install Docker for raspberry pi from official documentation
    echo "Starting Ontime Docker setup..."
    curl -sSL https://get.docker.com | sh >/tmp/log.txt 2>&1 &
    spinner $! "Getting Docker..." /tmp/log.txt

    # Add current user to docker group
    sudo usermod -aG docker "$USER"

    # Pull latest Ontime Docker image
    sudo docker pull getontime/ontime >/tmp/log.txt 2>&1 &
    spinner $! "Getting Ontime..." /tmp/log.txt

    # Install docker-compose
    sudo apt install -y docker-compose >/tmp/log.txt 2>&1 &
    spinner $! "Getting docker-compose..." /tmp/log.txt

    # Sets timezone for docker-compose file creation
    TZ=$(cat /etc/timezone)
    export TZ

    cat <<EOF > ~/show-pi/config-files/docker-compose.yml
version: "3"

services:
  ontime:
    container_name: ontime
    image: getontime/ontime:latest
    ports:
      - "4001:4001/tcp"
      - "8888:8888/udp"
      - "9999:9999/udp"
    volumes:
      - "${HOME}/show-pi/ontime-data:/data/"
    environment:
      - TZ=${TZ}
    restart: unless-stopped
EOF

    # Navigate to config-files directory
    cd ~/show-pi/config-files || exit
    
    # Start docker-compose in detached mode
    docker-compose up -d >/tmp/log.txt 2>&1 &
    spinner $! "Starting Ontime..." /tmp/log.txt

    # Sets ownership of the ontime-data directory to the current user
    sudo chown -R "$USER:$USER" "$HOME/show-pi/ontime-data"

else
    echo -e "Skipped Ontime Timer install.\n"
fi
