#!/bin/bash

# ================================
# JoviOS Backup Script
# Backs up critical configs and Docker volumes
# ================================

DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/home/jovi/shares/backups/automated/$DATE"

echo "Starting backup - $DATE"

# Create dated backup folder
mkdir -p "$BACKUP_DIR"

# ---- TIER 1: Critical Configs ----
echo "Backing up configs..."
sudo cp -r /etc/samba "$BACKUP_DIR/samba"
sudo cp -r /etc/pihole "$BACKUP_DIR/pihole"
sudo cp /etc/dhcpcd.conf "$BACKUP_DIR/dhcpcd.conf"
sudo cp /etc/rc.local "$BACKUP_DIR/rc.local"

# ---- TIER 2: Docker Compose Files ----
echo "Backing up Docker compose files..."
cp /home/jovi/docker/nextcloud/docker-compose.yml "$BACKUP_DIR/nextcloud-compose.yml"
cp /home/jovi/docker/sparky/docker-compose.yml "$BACKUP_DIR/sparky-compose.yml"
# ---- TIER 3: Docker Volumes ----
echo "Backing up Docker volumes..."
sudo docker run --rm \
  -v nextcloud_nextcloud_data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/nextcloud-data.tar.gz /data

sudo docker run --rm \
  -v sparky_sparky_db_data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/sparky-db.tar.gz /data

echo "Backup complete - saved to $BACKUP_DIR"
