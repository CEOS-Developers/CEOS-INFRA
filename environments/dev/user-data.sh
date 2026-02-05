#!/bin/bash
set -e

# ==============================================
# EC2 Initial Setup Script (Dev Environment)
# 
# 이 스크립트는 EC2 인스턴스가 처음 시작될 때 실행됩니다.
# Docker와 Docker Compose만 설치하고, 
# 실제 애플리케이션 배포는 CEOS-BE GitHub Actions에서 처리합니다.
# ==============================================

# Log setup
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "=========================================="
echo "Starting EC2 setup for Dev environment..."
echo "=========================================="

# Update system
echo "[1/5] Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Setup Swap Memory (2GB)
echo "[2/5] Setting up 2GB swap memory..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swap memory (2GB) configured successfully"
else
    echo "Swap file already exists"
fi
echo "Current swap status:"
sudo swapon --show

# Install Docker
echo "[3/5] Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
    rm get-docker.sh
    echo "Docker installed successfully"
else
    echo "Docker already installed"
fi

# Install Docker Compose
echo "[4/5] Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully"
else
    echo "Docker Compose already installed"
fi

# Create application directory
echo "[5/5] Creating application directory..."
sudo mkdir -p /home/ubuntu/ceos
sudo chown -R ubuntu:ubuntu /home/ubuntu/ceos

# Print completion message
echo "=========================================="
echo "EC2 instance setup completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Backend 레포의 GitHub Actions가 이 서버에 배포합니다."
echo "2. GitHub Secrets에 다음 값들을 설정하세요:"
echo "   - EC2_HOST_DEV: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo '<EC2_PUBLIC_IP>')"
echo "   - EC2_KEY_DEV: SSH Private Key"
echo ""
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker-compose --version)"
