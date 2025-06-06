#!/bin/bash
 
# Set variables
CONFIG=/boot/firmware/config.txt
CMDLINE=/boot/firmware/cmdline.txt

# Add dtoverlay to config.txt if not present
if ! sudo grep -q "^dtoverlay=dwc2,dr_mode=peripheral" "$CONFIG"; then
  echo "Adding dtoverlay=dwc2,dr_mode=peripheral to $CONFIG"
  echo "dtoverlay=dwc2,dr_mode=peripheral" | sudo tee -a "$CONFIG" > /dev/null
else
  echo "dtoverlay line already present in $CONFIG"
fi

# Append modules-load to cmdline.txt if not present
if ! sudo grep -q "modules-load=dwc2,g_serial" "$CMDLINE"; then
  echo "Appending modules-load=dwc2,g_serial to $CMDLINE"
  sudo sed -i 's|$| modules-load=dwc2,g_serial|' "$CMDLINE"
else
  echo "modules-load line already present in $CMDLINE"
fi

# Add tty restart to crontab for the invoking user
CRON_ENTRY='@reboot sudo systemctl restart getty@ttyGS0'
TARGET_USER=$(whoami)

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
