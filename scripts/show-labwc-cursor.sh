#!/bin/bash

# Restores cursor in labwc by moving left pointer cursor backup file to original state. 

# Renames the left pointer icon to left_ptr
sudo mv /usr/share/icons/Adwaita/cursors/left_ptr.backup /usr/share/icons/Adwaita/cursors/left_ptr

# Kills labwc , which restarts right after
sudo killall labwc

# Complete with feedback.
echo -e "Pointer is now restored." 
