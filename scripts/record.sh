#!/bin/bash

# Settings
DEVICE="/dev/video0"
OUTPUT_DIR="$HOME/show-pi/showfiles/recordings"
FILENAME="$(date +%Y-%m-%d_%H-%M-%S).ts"
DURATION="00:00:30" # 30 seconds

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Kill any stuck ffmpeg or V4L2-related processes
pkill -9 -f ffmpeg
sleep 1

# Unload/reload V4L2 codec modules
sudo modprobe -r bcm2835_codec
sleep 1
sudo modprobe bcm2835_codec
sleep 1

# (Optional) Unbind and rebind USB capture device
# Replace with actual USB ID from `lsusb` and match to your capture card if needed

# Check device exists
if [ ! -e "$DEVICE" ]; then
  echo "Device $DEVICE not found. Try replugging the capture card or rebooting."
  exit 1
fi

# Run ffmpeg to record using a crash-safe MPEG-TS container
ffmpeg \
-f v4l2 -framerate 60 -video_size 1280x720 -pix_fmt yuyv422 -i "$DEVICE" \
-vf format=yuv420p \
-c:v libx264 -preset ultrafast -b:v 2M \
-t "$DURATION" "$OUTPUT_DIR/$FILENAME"
