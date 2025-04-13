#!/bin/bash

set -e

# --- Prompt up front ---
echo "Enter the InfluxDB token:"
read -r INFLUX_TOKEN

echo "Enter a unique device name (e.g., RaspberryPi1):"
read -r DEVICE_NAME

# --- Start setup ---
echo ""
echo "Installing Docker and docker-compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt-get install -y docker-compose
sudo usermod -aG docker scannow

# Enable Docker to start on boot
sudo systemctl enable docker

# --- Define file path ---
COMPOSE_FILE="./docker-compose.yaml"

# --- Check for compose file ---
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Error: $COMPOSE_FILE does not exist."
  exit 1
fi

echo "Customizing docker-compose.yaml..."
cp "$COMPOSE_FILE" "$COMPOSE_FILE.bak"
sed -i "s|<token>|$INFLUX_TOKEN|g" "$COMPOSE_FILE"
sed -i "s|<name>|$DEVICE_NAME|g" "$COMPOSE_FILE"

# --- Build Docker image (Optional) ---
# Only needed if you want to build your own image
echo ""
echo "Building Docker image..."
docker build -t 9saile9/wifiscan-collector:latest .

# --- Start Docker container ---
echo ""
echo "Starting container..."
docker-compose up -d

# --- Final messages ---
echo "Setup complete. Container is running as '$DEVICE_NAME'."
echo "Docker will automatically start on boot."

# Optionally, verify the running container
docker ps
