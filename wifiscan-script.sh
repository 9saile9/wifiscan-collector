#!/bin/bash

# Exit on error
set -e

# Prompt for token and device name
read -p "Enter your InfluxDB token: " TOKEN
read -p "Enter a device name (e.g., RaspberryPi1): " DEVICENAME

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo apt-get install -y docker-compose
sudo sh get-docker.sh

# Add user 'scannow' to docker group
sudo usermod -aG docker scannow

# Create target directory
cd ./wifiscan-collector

# Generate docker-compose.yaml
echo "Creating docker-compose.yaml..."

cat <<EOF | sudo tee docker-compose.yaml > /dev/null
services:
  wifiscan-collector:
    cap_add:
      - NET_ADMIN
    container_name: wifiscan-collector
    environment:
      TZ: America/Chicago
      WIFISCAN_COLLECTOR_INFLUXDB_BUCKET: wifi_scan
      WIFISCAN_COLLECTOR_INFLUXDB_ORG: esc_it
      WIFISCAN_COLLECTOR_INFLUXDB_TOKEN: $TOKEN
      WIFISCAN_COLLECTOR_INFLUXDB_URL: https://influx.esc.srfprod.ch:8086
      WIFISCAN_COLLECTOR_LOG_LEVEL: INFO
      WIFISCAN_COLLECTOR_MAX_RETRIES: "3"
      WIFISCAN_COLLECTOR_RETRY_DELAY: "2"
      WIFISCAN_COLLECTOR_SCAN_INTERVAL: "10"
      WIFISCAN_COLLECTOR_DEVICE_NAME: $DEVICENAME
    image: 9saile9/wifiscan-collector:latest
    network_mode: host
    restart: unless-stopped
EOF

# Launch the container
echo "Starting Docker container..."
sudo docker-compose up -d

echo "✅ Setup complete. The WiFi scanner is now running!"
