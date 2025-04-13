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
sudo apt-get install -y docker-compose
sudo sh get-docker.sh
sudo usermod -aG docker scannow

# --- Define file path ---
COMPOSE_FILE="./docker-compose.yaml"

# --- Replace placeholders in compose file ---
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Error: $COMPOSE_FILE does not exist."
  exit 1
fi

echo "Customizing docker-compose.yaml..."
cp "$COMPOSE_FILE" "$COMPOSE_FILE.bak"
sed -i "s|<token>|$INFLUX_TOKEN|g" "$COMPOSE_FILE"
sed -i "s|<name>|$DEVICE_NAME|g" "$COMPOSE_FILE"

# --- Build and start container ---
echo ""
echo "Building Docker image..."
docker build -t 9saile9/wifiscan-collector:latest .

echo "Starting container..."
docker-compose up -d

echo "Setup complete. Container is running as '$DEVICE_NAME'"
