#!/bin/bash

# Install git dan unzip
sudo apt install git -y
sudo apt install unzip -y

# Buat dan aktifkan swap 4GB
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Clone repository GitHub
git clone https://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@github.com/hidagans/gege

# Masuk ke direktori dan jalankan script
cd gege
bash internetIncome.sh --install
bash internetIncome.sh --start
