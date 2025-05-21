#!/bin/bash

# Directory to watch for images
WATCH_DIR="$HOME/show-pi/showfiles/show-images"
APP="pqiv"

# Function to count image files recursively
count_images() {
  find "$WATCH_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \) | wc -l
}

# Start infinite watch loop
while true; do
  # Count current image files
  IMAGE_COUNT=$(count_images)

  # If any images exist
  if [[ $IMAGE_COUNT -gt 0 ]]; then
    # Kill pqiv if it's already running (to refresh image list)
    pkill -x "$APP"
    echo "Restarting pqiv with $IMAGE_COUNT images"
    # Start pqiv with updated image list
    pqiv -fis --watch-directories "$WATCH_DIR" &
  else
    # No images: make sure pqiv is not running
    pkill -x "$APP"
    echo "No images found, pqiv stopped"
  fi

  # Wait for any file-related change in the watched directory or subdirectories
  inotifywait -qr -e create -e delete -e moved_to -e moved_from "$WATCH_DIR"
done
