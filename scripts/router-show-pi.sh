#!/bin/bash

# Prompts user for show-pi wifi password.
read -rsp "Enter Wi-Fi password: " WIFI_PASSWORD
echo

# Sets hotspot connection
sudo nmcli device wifi hotspot ssid show-pi password $WIFI_PASSWORD

# Rename connection to showpi-hotspot for clarity (optional)
sudo nmcli connection modify Hotspot connection.id showpi-hotspot

# Set the connections on
sudo nmcli connection up showpi-hotspot

# Auto starts connection on boot
sudo nmcli connection modify showpi-hotspot connection.autoconnect yes

echo "Show-pi hotspot is aready"
