#!/bin/bash

# Hides cursor in labwc by moving left pointer cursor.
# Mouse movemoent is still being track. If the pointer is moved over area
# with different pointer icon, the pointer will show. 

# Renames the left pointer icon to left_ptr.backup so system does not load it. 
sudo mv /usr/share/icons/Adwaita/cursors/left_ptr /usr/share/icons/Adwaita/cursors/left_ptr.backup

# Kills labwc , which restarted right after
sudo killall labwc

# Complete with feedback.
echo -e "Pointer is now hidden." 
