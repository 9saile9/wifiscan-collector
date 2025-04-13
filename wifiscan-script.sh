#!/bin/bash

set -e

echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo apt-get install -y docker-compose
sudo sh get-docker.sh
sudo usermod -aG docker scannow

echo ""
echo "Enter the InfluxDB token:"
read -r INFLUX_TOKEN

echo "Enter a unique device name (e.g., RaspberryPi1):"
read -r DEVICE_NAME

COMPOSE_FILE="./wifiscan-collector/docker-compose.yaml"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Error: $COMPOSE_FILE does not exist."
  exit 1
fi

echo "Customizing docker-compose.yaml with provided token and device name..."
# Backup first
cp "$COMPOSE_FILE" "$COMPOSE_FILE.bak"

# Replace placeholders
sed -i "s|<token>|$INFLUX_TOKEN|g" "$COMPOSE_FILE"
sed -i "s|<name>|$DEVICE_NAME|g" "$COMPOSE_FILE"

echo ""
echo "Building Docker image from Dockerfile..."
cd wifiscan-collector || exit
docker build -t 9saile9/wifiscan-collector:latest .

echo ""
echo "Starting container..."
docker-compose up -d

echo "Setup complete. Container is running."
