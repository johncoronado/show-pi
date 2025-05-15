#!/bin/bash

# Echo your message first
echo "Updating system..."

# Run your update commands, suppressing unnecessary output
sudo apt update # > /dev/null 2>&1
sudo apt upgrade -y # > /dev/null 2>&1

# Optional: If you want to suppress autoremove as well
#sudo apt autoremove -y > /dev/null 2>&1

# Echo the final message
echo "System update complete."

