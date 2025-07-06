#!/bin/bash

# Sourcing spinner function for progress indication
source "$HOME"/show-pi/scripts/spinner.sh

# Asks to run script
echo -e -n "\n\033[1m"Install Show-Pi offline website?"\033[0m (y/n): "
read -r -p "" choice </dev/tty
if [[ "$choice" =~ ^[Yy]$ ]]; then

  # One-time setup for MkDocs offline local server
  VENV_DIR="$HOME/.mkdocs-venv"
  PROJECT_DIR="$HOME/show-pi"
  SERVICE_DIR="$HOME/.config/systemd/user"
  SERVICE_NAME="show-pi-site.service"
  SERVICE_PATH="$SERVICE_DIR/$SERVICE_NAME"
  SERVICE_TEMPLATE="$PROJECT_DIR/config-files/site-services.conf"
  SITE_URL="http://${HOSTNAME:-$(hostname)}.local:8010"

  # Installs python packages
  sudo apt install -y python3-full python3-venv >/tmp/log.txt 2>&1 &
  spinner $! "Installing Python packages..." /tmp/log.txt
  
  # Create virtual environment if it doesn't exist
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR" >/tmp/log.txt 2>&1 &
    spinner $! "Creating virtual environment..." /tmp/log.txt
  else
    echo "Virtual environment already exists at $VENV_DIR"
  fi

  # Activate the virtual environment and install MkDocs Material
  source "$VENV_DIR/bin/activate"
  pip install --upgrade pip >/tmp/log.txt 2>&1 &
  spinner $! "Upgrading pip..." /tmp/log.txt
  pip install mkdocs-material >/tmp/log.txt 2>&1 &
  spinner $! "Installing MkDocs Material..." /tmp/log.txt
  
  # Ensure user systemd dir exists
  mkdir -p "$SERVICE_DIR"

  # Copy the service file
  if [ -f "$SERVICE_TEMPLATE" ]; then
    cp "$SERVICE_TEMPLATE" "$SERVICE_PATH"
  else
    echo "ERROR: Service template not found at $SERVICE_TEMPLATE"
    exit 1
  fi

  # Reload and enable the user service
  systemctl --user daemon-reload
  systemctl --user enable "$SERVICE_NAME"

  ## Build MkDocs site if it doesn't exist yet
  if [ ! -d "$PROJECT_DIR/site" ]; then
    echo -e "Building initial site (mkdocs build)..."
    cd "$PROJECT_DIR" || exit 1
    mkdocs build
  else
    echo -e "Site already exists: $PROJECT_DIR/site"
  fi

  # Start the service
  systemctl --user start "$SERVICE_NAME"
  echo "URL: $SITE_URL"
  echo -e "Show-Pi offline website setup complete."
else
  echo -e "Skipping Show-Pi offline website.\n"
fi
