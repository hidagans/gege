#!/bin/bash

# Setup Docker experimental features
echo "Setting up Docker..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
    "experimental": true,
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF

# Restart Docker service
systemctl restart docker || {
    echo "Failed to restart Docker"
}
