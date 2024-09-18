#!/bin/bash

# Update system packages
sudo dnf update -y

# Install nano (optional, included as per your commands)
sudo dnf install -y nano

# Create MongoDB repository file
sudo tee /etc/yum.repos.d/mongodb-org.repo > /dev/null <<EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

# Install MongoDB
sudo dnf install -y mongodb-org

# Create disable-thp.service file
sudo tee /etc/systemd/system/disable-thp.service > /dev/null <<EOF
[Unit]
Description=Disable Transparent Huge Pages (THP)
After=sysinit.target local-fs.target
Before=mongod.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'

[Install]
WantedBy=basic.target
EOF

# Reload systemd daemon to recognize new service
sudo systemctl daemon-reload

# Start the disable-thp service
sudo systemctl start disable-thp.service

# Verify that THP is disabled
echo "Checking Transparent Huge Pages status:"
cat /sys/kernel/mm/transparent_hugepage/enabled

# Enable the disable-thp service to start on boot
sudo systemctl enable disable-thp.service

# Create a tuned profile directory
sudo mkdir -p /etc/tuned/no-thp

# Create tuned.conf file to disable THP via tuned profile
sudo tee /etc/tuned/no-thp/tuned.conf > /dev/null <<EOF
[main]
include=virtual-guest

[vm]
transparent_hugepages=never
EOF

# Apply the tuned profile
sudo tuned-adm profile no-thp

# Start and enable MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify MongoDB connection
mongosh --eval 'db.runCommand({ connectionStatus: 1 })'

# Complete
echo "MongoDB v7.0.14 Installed Successfully!"
