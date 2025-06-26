#!/bin/bash

# Updates the motd file for good info on login and copies it to /etc/motd
cp $HOME/show-pi/config-files/logo $HOME/show-pi/config-files/motd

MOTD_FILE="$HOME/show-pi/config-files/motd"

{
    echo ""
    echo -e "Welcome, \033[1;33m$(logname)\033[0m"
    echo -e "Hostname: \033[1;33m$(hostname)\033[0m"
    echo -e "To control Ontime, \033[1;33mhttp://$(hostname).local:4001/editor\033[0m"
    echo -e "To control Companion, \033[1;33mhttp://$(hostname).local:8000\033[0m"
    echo -e "To play images, navigate to the network share and place an image in the show-images folder"
    echo -e "It is recommended that you bookmark these websites for fast access.\n"
    echo -e "Use ./scripts/hotspot-setup.sh for networking setup. Or nmtui."

} >>"$MOTD_FILE"

sudo cp $MOTD_FILE /etc/motd
echo -e "\nMOTD file has been updated"
