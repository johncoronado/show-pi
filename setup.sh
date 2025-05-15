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
    echo -n "Run script: $script_path? (y/n): "
    read -r -p "" choice < /dev/tty
    if [[ "$choice" =~ ^[Yy]$ ]]; then
     bash "$script_path" < /dev/tty
    else
      echo "Skipped: $script_path"
    fi
  else
    echo "Skipping: $script_path (not found or not executable)"
  fi
done < "$ORDER_FILE"

echo "All scripts processed from $ORDER_FILE."
