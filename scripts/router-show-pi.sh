#!/bin/bash

set -e

# Function to get the current wlan0 connection
get_wlan0_connection() {
    nmcli -t -f DEVICE,STATE,CONNECTION device | grep "^wlan0:" | cut -d: -f3
}

# Function to bring down wlan0 if something is active
disconnect_wlan0() {
    local current_conn
    current_conn=$(get_wlan0_connection)

    if [[ -n "$current_conn" && "$current_conn" != "--" ]]; then
        echo "Disconnecting wlan0 from: $current_conn"
        sudo nmcli connection down "$current_conn"
    fi
}

# Function to start the show-pi hotspot
start_hotspot() {
    echo "Starting 'show-pi' hotspot..."

    # Ask for password
    read -rsp "Enter Wi-Fi password for 'show-pi': " WIFI_PASSWORD
    echo

    # Check if 'showpi-hotspot' already exists
    if ! nmcli connection show | grep -q "showpi-hotspot"; then
        echo "Creating hotspot connection..."
        sudo nmcli device wifi hotspot ifname wlan0 ssid show-pi password "$WIFI_PASSWORD"
        sudo nmcli connection modify Hotspot connection.id showpi-hotspot 2>/dev/null
    else
        echo "Hotspot connection already exists."
        sudo nmcli connection modify showpi-hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
        sudo nmcli connection modify showpi-hotspot wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$WIFI_PASSWORD"
    fi
    disconnect_wlan0
    sudo nmcli connection up showpi-hotspot
    sudo nmcli connection modify showpi-hotspot connection.autoconnect yes

    echo "Hotspot 'showpi-hotspot' is now active."
}

# Function to connect to another known Wi-Fi
connect_known_wifi() {
    echo "Available known Wi-Fi connections:"
    nmcli connection show | grep wifi | awk '{print NR ") " $1}' 
    echo -n "Select number to connect or press Enter to cancel: "
    read -r choice

    if [[ -z "$choice" ]]; then
        echo "Cancelled."
        exit 0
    fi

    selected_conn=$(nmcli connection show | grep wifi | awk '{print $1}' | sed -n "${choice}p")

    if [[ -n "$selected_conn" ]]; then
        echo "Connecting wlan0 to '$selected_conn'..."
        disconnect_wlan0
        sudo nmcli connection up "$selected_conn"
    else
        echo "Invalid selection."
        exit 1
    fi
}

# Main menu
echo "wlan0 manager:"
echo "1) Start 'show-pi' hotspot"
echo "2) Connect to known Wi-Fi"
echo "3) Exit"
read -rp "Choose an option: " user_choice

case "$user_choice" in
    1)
      # disconnect_wlan0
        start_hotspot
        ;;
    2)
      # disconnect_wlan0
        connect_known_wifi
        ;;
    3)
        echo "Exiting."
        ;;
    *)
        echo "Invalid selection."
        ;;
esac

