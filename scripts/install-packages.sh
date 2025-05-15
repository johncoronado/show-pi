#!/bin/bash

# Set the path to the package list configuration file
PACKAGE_FILE="./config-files/package-list.conf"

echo "Installing packages..."

# Check if the package list file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: $PACKAGE_FILE not found."
  exit 1
fi

# Extract all non-empty and non-comment lines (ignores lines starting with #)
# and join them into a single space-separated string of package names
packages=$(grep -vE '^\s*#' "$PACKAGE_FILE" | tr '\n' ' ')

# If the resulting string is empty, there are no packages to install
if [[ -z "$packages" ]]; then
  echo "No packages to install."
  exit 0
fi

# Output the list of packages that will be installed
#echo "Installing the following packages:"
#echo "$packages"
#echo ""

# Update package index before installing
sudo apt update

# Install all packages in a single apt command for efficiency
sudo apt install --no-install-recommends -y $packages

# Add current user to docker gro
echo "Package installation complete."
