#!/bin/bash

#This start setup script goes through the script-run-order.conf and creates a small footprint of interactivity. 

ORDER_FILE="config-files/script-run-order.conf"

# Check if the order file exists
if [[ ! -f "$ORDER_FILE" ]]; then
  echo "Error: $ORDER_FILE not found."
  exit 1
fi

# Loop through each script path in the order file
while IFS= read -r script_path; do
  # Check if the script exists and is executable
  if [[ -x "$script_path" && -f "$script_path" ]]; then
    echo -e -n  "\nRun script: \033[1m$(basename "$script_path")\033[0m? (y/n): "
    read -r -p "" choice < /dev/tty
    if [[ "$choice" =~ ^[Yy]$ ]]; then
     bash "$script_path" < /dev/tty
    else
      echo -e "Skipped: $(basename "$script_path")"
    fi
  else
    echo -e "Skipping: $(basename "$script_path")"
  fi
done < "$ORDER_FILE"

# Updates the motd file for good info on login and copies it to /etc/motd
cp $HOME/show-pi/config-files/logo $HOME/show-pi/config-files/motd

MOTD_FILE="$HOME/show-pi/config-files/motd"

{
  echo ""
  echo -e "Welcome, \033[1;33m$(logname)\033[0m"
  echo -e "Hostname: \033[1;33m$(hostname)\033[0m"
  echo -e "To control Ontime, \033[1;33mhttp://$(hostname).local:4001/editor\033[0m"
  echo -e "To control Companion, \033[1;33mhttp://$(hostname).local:8000\033[0m"
  echo -e "To play images, navigate to the network share and place an image in the show-images folder."
  echo -e "It is recommended that you bookmark these websites for fast access.\n"
} >> "$MOTD_FILE"

sudo cp $MOTD_FILE /etc/motd
echo -e "\nMOTD file has been updated"
echo -e "\n\033[1;31mSetup complete. Please reboot your system!\033[0m\n"
