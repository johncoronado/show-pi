#!/bin/bash

# Sourcing spinner function for progress indication
source "$HOME"/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n "\n\033[1m"Install Show-Pi file sharing?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

	# Install samba with packages recommends
	sudo apt install samba -y >/tmp/log.txt 2>&1 &
	spinner $! "Installing Samba file share..." /tmp/log.txt

	# Get the current user and home directory
	current_user=$(whoami)
	user_home=$(eval echo "~$USER")

	#adds user to samba user list gives terminal input
	sudo smbpasswd -a "$current_user" </dev/tty

	# Create the 'show-files' directory if it doesn't exist
	mkdir -p show-files

	#Copy Samba template conf to new file
	cp ~/show-pi/config-files/smb-temp.conf ~/show-pi/config-files/smb.conf

	# Path to smb.conf
	smb_conf="$user_home/show-pi/config-files/smb.conf"

	# Append the share configuration for the current user
	cat <<EOL >>"$smb_conf"

[show-files]
  path = $user_home/show-pi/show-files
  browsable = yes
  writable = yes
  guest ok = yes
  force user = $current_user
  force group = $current_user
  create mask = 0664
  directory mask = 0775
  locking = no
  valid users = $current_user, nobody
  read list = nobody
EOL

	# Notify the user
	echo "Samba share configuration for 'show-files' added for user '$current_user'"

	# Define source and destination paths
	source="$user_home/show-pi/config-files/smb.conf"
	destination="/etc/samba/smb.conf"

	# Check if the source file exists
	if [[ -f "$source" ]]; then
		# Copy smb.conf to /etc/samba/
		sudo cp "$source" "$destination"

		# Set the correct permissions for the file (optional)
		sudo chmod 644 "$destination"
		sudo chown root:root "$destination"
	else
		echo "Error: $source does not exist. Please check the file path."
	fi
	# Restart Samba services to apply changes
	sudo systemctl restart smbd
	echo "Samba service has been restarted."
else
	echo -e "Skipped Show-Pi file sharing."
fi
