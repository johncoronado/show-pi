#!/bin/bash

# Updates the motd file for good info on login and copies it to /etc/motd
cp "$HOME"/show-pi/config-files/logo "$HOME"/show-pi/config-files/motd

MOTD_FILE="$HOME/show-pi/config-files/motd"

{
    echo ""
    echo -e "To control Ontime, \033[1;33mhttp://$(hostname).local:4001/editor\033[0m"
    echo -e "To control Companion, \033[1;33mhttp://$(hostname).local:8000\033[0m"
    echo -e "To view the offline GitHub Pages, \033[1;33mhttp://$(hostname).local:8010\033[0m"
    echo -e "It is recommended that you bookmark these websites for fast access"
    echo -e "To play content, place file in the respective folder in the show-files directory."
    echo -e "Use ./scripts/hotspot-setup.sh for networking setup. Or nmtui.\n"

} >>"$MOTD_FILE"

# Asks to run script
echo -e -n "\n\033[1m"Update your login motd file?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

    sudo cp "$MOTD_FILE" /etc/motd
    echo -e "\nmotd file has been updated\n"
else
    echo -e "\nmotd file has not been updated.\nView it at ~/show-pi/config-files/motd\n"
fi