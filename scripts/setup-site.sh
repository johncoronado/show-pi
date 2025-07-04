#!/bin/bash

# One-time setup for MkDocs offline local server
VENV_DIR="$HOME/.mkdocs-venv"
PROJECT_DIR="$HOME/show-pi"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_NAME="show-pi-site.service"
SERVICE_PATH="$SERVICE_DIR/$SERVICE_NAME"
SERVICE_TEMPLATE="$PROJECT_DIR/config-files/site-services.conf"

echo -e "\nInstalling required packages..."
sudo apt update
sudo apt install -y python3-full python3-venv

echo -e "\n🔧 Creating virtual environment (if needed)..."
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
  echo "Virtual environment created at $VENV_DIR"
else
  echo "Virtual environment already exists at $VENV_DIR"
fi

echo -e "\nInstalling MkDocs and Material theme..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install mkdocs-material

echo -e "\nSetting up systemd user service..."

# Ensure user systemd dir exists
mkdir -p "$SERVICE_DIR"

# Copy the service file
if [ -f "$SERVICE_TEMPLATE" ]; then
  cp "$SERVICE_TEMPLATE" "$SERVICE_PATH"
  echo "Service file copied to: $SERVICE_PATH"
else
  echo "ERROR: Service template not found at $SERVICE_TEMPLATE"
  exit 1
fi

# Reload and enable the user service
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"

echo -e "\nService ready: $SERVICE_NAME"
echo "It will serve the site from: $PROJECT_DIR/site"
echo "Auto-starts at login via systemd --user"
echo "URL: http://showpi.local:8010 or Pi's IP"
