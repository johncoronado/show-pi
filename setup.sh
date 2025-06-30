#!/bin/bash

# This start setup script goes through the script-run-order.conf and
# creates a small footprint of interactivity.

# Gets spinner funtion
# spinner example.
#       Command > /tmp/log.txt 2>&1 &
#       spinner $! "Doing something..." /tmp/log.txt
source $HOME/show-pi/scripts/spinner.sh

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
    bash "$script_path" </dev/tty
  else
    echo -e "Show-Pi setup exited\n"
  fi
done <"$ORDER_FILE"
# Clean up packages
sudo apt autoremove -y >/tmp/log.txt 2>&1 &
spinner $! "Cleaning up..." /tmp/log.txt

echo -e "\n\033[1;31mSetup complete. Please reboot your system!\033[0m\n"
