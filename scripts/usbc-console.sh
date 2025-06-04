#!/bin/bash

# Ensure script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (e.g., sudo $0)"
  exit 1
fi

# Set variables
CONFIG=/boot/firmware/config.txt
CMDLINE=/boot/firmware/cmdline.txt

# Add dtoverlay to config.txt if not present
if ! grep -q "^dtoverlay=dwc2,dr_mode=peripheral" "$CONFIG"; then
  echo "Adding dtoverlay=dwc2,dr_mode=peripheral to $CONFIG"
  echo "dtoverlay=dwc2,dr_mode=peripheral" >> "$CONFIG"
else
  echo "dtoverlay line already present in $CONFIG"
fi

# Append modules-load to cmdline.txt if not present
if ! grep -q "modules-load=dwc2,g_serial" "$CMDLINE"; then
  echo "Appending modules-load=dwc2,g_serial to $CMDLINE"
  sed -i 's|$| modules-load=dwc2,g_serial|' "$CMDLINE"
else
  echo "modules-load line already present in $CMDLINE"
fi

# Add tty restart to crontab for the invoking user
CRON_ENTRY='@reboot sudo systemctl restart getty@ttyGS0'
TARGET_USER="$SUDO_USER"

# Check if the cron entry already exists
if ! sudo crontab -u "$TARGET_USER" -l 2>/dev/null | grep -Fxq "$CRON_ENTRY"; then
  (
    sudo crontab -u "$TARGET_USER" -l 2>/dev/null
    echo "$CRON_ENTRY"
  ) | sudo crontab -u "$TARGET_USER" -
  echo "Added '@reboot sudo systemctl restart getty@ttyGS0' to $TARGET_USER's crontab."
else
  echo "Cron entry already present for $TARGET_USER."
fi

echo "Done. Reboot to apply changes."
