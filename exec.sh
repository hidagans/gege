#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Kredensial
USERNAME="yearigans"
PASSWORD="mantulx10"

# Update sistem
echo -e "${YELLOW}Updating system...${NC}"
apt-get update && apt-get upgrade -y

# Install Squid dan Apache Utils
echo -e "${YELLOW}Installing Squid Proxy and required utilities...${NC}"
apt-get install squid apache2-utils -y

# Buat user dan password
echo -e "${YELLOW}Creating user credentials...${NC}"
htpasswd -bc /etc/squid/passwd $USERNAME $PASSWORD

# Backup konfigurasi asli
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Buat konfigurasi baru
cat > /etc/squid/squid.conf <<EOF
# Port dan nama hostname
http_port 3128
visible_hostname proxy-server

# Autentikasi
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Proxy Authentication Required
auth_param basic credentialsttl 2 hours
acl authenticated proxy_auth REQUIRED

# Access Control
http_access allow authenticated
http_access deny all

# DNS Settings
dns_nameservers 8.8.8.8 8.8.4.4

# Cache Settings
cache_mem 256 MB
maximum_object_size 128 MB
cache_replacement_policy heap LFUDA
memory_replacement_policy heap GDSF

# Performance Optimization
pipeline_prefetch on
ipcache_size 1024
ipcache_low 90
ipcache_high 95
fqdncache_size 1024

# Logging
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
cache_store_log /var/log/squid/store.log

# Basic Configuration
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
EOF

# Set permissions
chown -R proxy:proxy /etc/squid/passwd

# Restart Squid
echo -e "${YELLOW}Restarting Squid service...${NC}"
systemctl restart squid

# Configure firewall (if UFW is installed)
if [ -x "$(command -v ufw)" ]; then
    ufw allow 3128/tcp
    ufw reload
fi

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

# Create simple test script
cat > /root/test-proxy.sh <<EOF
#!/bin/bash
curl -x http://$USERNAME:$PASSWORD@$SERVER_IP:3128 https://api.ipify.org?format=json
EOF
chmod +x /root/test-proxy.sh

echo -e "${GREEN}Proxy server installation completed!${NC}"
echo -e "${GREEN}Your proxy server details:${NC}"
echo -e "IP Address: ${SERVER_IP}"
echo -e "Port: 3128"
echo -e "Username: $USERNAME"
echo -e "Password: $PASSWORD"
echo -e "\nTest your proxy with: ${YELLOW}/root/test-proxy.sh${NC}"

# Test if proxy is running
if systemctl is-active --quiet squid; then
    echo -e "${GREEN}Proxy server is running successfully!${NC}"
else
    echo -e "${RED}Error: Proxy server is not running!${NC}"
fi

# Display proxy format
echo -e "\n${GREEN}Proxy Formats:${NC}"
echo -e "HTTP Proxy: http://$USERNAME:$PASSWORD@$SERVER_IP:3128"
echo -e "HTTPS Proxy: https://$USERNAME:$PASSWORD@$SERVER_IP:3128"
echo -e "Socks Proxy: socks://$USERNAME:$PASSWORD@$SERVER_IP:3128"
