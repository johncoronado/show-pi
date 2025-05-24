#!/bin/bash

# Directory to watch for videos
WATCH_DIR="$HOME/show-pi/showfiles/show-videos"
APP="mpv"

# Function to count videos files recursively
count_videos() {
  find "$WATCH_DIR" -type f \( -iname "*.mov" -o -iname "*.mp4" -o -iname "*.m4a" \) | wc -l
}

# Start infinite watch loop
while true; do
  # Count current videos files
  VIDEO_COUNT=$(count_videos)

  # If any videos exist
  if [[ $VIDEO_COUNT -gt 0 ]]; then
    # Kill mpv if it's already running (to refresh video list)
    pkill -x "$APP"
    echo "Restarting mpv with $VIDEO_COUNT videos"
    # Start mpv with updated video list
    mpv --fs --no-osd-bar --loop-playlist "$WATCH_DIR" &
  else
    # No videos: make sure mpv is not running
    pkill -x "$APP"
    echo "No videos found, mpv stopped"
  fi

  # Wait for any file-related change in the watched directory or subdirectories
  inotifywait -qr -e create -e delete -e moved_to -e moved_from "$WATCH_DIR"
done
