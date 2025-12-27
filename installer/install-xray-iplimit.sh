#!/bin/bash

# XRAY IP Limiter - Installer Script
# Multi-VPS Support with Sync Capability

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║      ${CYAN}XRAY IP LIMITER - INSTALLER${GREEN}                    ║${NC}"
echo -e "${GREEN}║      ${YELLOW}Multi-VPS Support with Sync${GREEN}                    ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗${NC} Please run as root"
    exit 1
fi

echo -e "${CYAN}[INFO]${NC} Installing XRAY IP Limiter..."

# Create directories
mkdir -p /var/lib/xray-iplimit/backups
mkdir -p /var/log/xray

# Install main script
if [ -f "xray-iplimit.sh" ]; then
    cp xray-iplimit.sh /usr/bin/xray-iplimit
    chmod +x /usr/bin/xray-iplimit
    echo -e "${GREEN}✓${NC} Main script installed: /usr/bin/xray-iplimit"
else
    echo -e "${RED}✗${NC} xray-iplimit.sh not found!"
    exit 1
fi

# Install menu script
if [ -f "menu-xray-iplimit.sh" ]; then
    cp menu-xray-iplimit.sh /usr/bin/menu-xray-iplimit
    chmod +x /usr/bin/menu-xray-iplimit
    echo -e "${GREEN}✓${NC} Menu script installed: /usr/bin/menu-xray-iplimit"
fi

# Install cron job
echo -e "\n${YELLOW}[SETUP]${NC} Configure auto-monitoring:"
echo "  [1] Every 2 minutes (fastest unlock)"
echo "  [2] Every 5 minutes (recommended)"
echo "  [3] Every 10 minutes"
echo "  [4] Every 15 minutes"
echo "  [5] Skip cron setup"
read -p "Select option [2]: " cron_option
cron_option=${cron_option:-2}

case $cron_option in
    1) interval="*/2" ;;
    2) interval="*/5" ;;
    3) interval="*/10" ;;
    4) interval="*/15" ;;
    5) 
        echo -e "${YELLOW}⚠${NC} Skipping cron setup"
        interval=""
        ;;
    *) interval="*/5" ;;
esac

if [ ! -z "$interval" ]; then
    echo "# XRAY IP Limiter Auto-Monitor" > /etc/cron.d/xray-iplimit
    echo "$interval * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1" >> /etc/cron.d/xray-iplimit
    chmod 644 /etc/cron.d/xray-iplimit
    service cron restart > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} Cron job installed: Every $interval minutes"
fi

# Create initial config files
touch /var/lib/xray-iplimit/locked_users.txt
touch /var/lib/xray-iplimit/user_uuid_map.txt
touch /var/lib/xray-iplimit/ip_sessions.txt
touch /var/lib/xray-iplimit/user_limits.conf
touch /var/log/xray/iplimit.log
touch /var/log/xray/iplimit-cron.log

echo -e "${GREEN}✓${NC} Configuration files created"

# Optional: Import existing config
echo -e "\n${YELLOW}[IMPORT]${NC} Do you want to import existing user limits config?"
echo "  [1] Yes, import from file"
echo "  [2] No, start fresh"
read -p "Select option [2]: " import_option
import_option=${import_option:-2}

if [ "$import_option" = "1" ]; then
    read -p "Enter config file path: " config_path
    if [ -f "$config_path" ]; then
        cp "$config_path" /var/lib/xray-iplimit/user_limits.conf
        echo -e "${GREEN}✓${NC} Config imported successfully"
    else
        echo -e "${RED}✗${NC} File not found, starting fresh"
    fi
fi

# Setup sync (optional)
echo -e "\n${YELLOW}[SYNC]${NC} Enable multi-VPS sync?"
echo "  [1] Yes, setup sync to master server"
echo "  [2] No, standalone mode"
read -p "Select option [2]: " sync_option
sync_option=${sync_option:-2}

if [ "$sync_option" = "1" ]; then
    read -p "Enter master VPS IP: " master_ip
    read -p "Enter master VPS SSH port [22]: " master_port
    master_port=${master_port:-22}
    
    # Install sync script
    cat > /usr/bin/xray-iplimit-sync << 'EOFSYNCSYNC'
#!/bin/bash
# XRAY IP Limiter - Sync Script

MASTER_IP="MASTER_IP_PLACEHOLDER"
MASTER_PORT="MASTER_PORT_PLACEHOLDER"
LOCAL_CONFIG="/var/lib/xray-iplimit/user_limits.conf"
REMOTE_CONFIG="/var/lib/xray-iplimit/user_limits.conf"

# Pull config from master
sshpass -p "$VPS_PASSWORD" scp -P $MASTER_PORT -o StrictHostKeyChecking=no \
    root@$MASTER_IP:$REMOTE_CONFIG $LOCAL_CONFIG 2>/dev/null

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Config synced from master" >> /var/log/xray/iplimit-sync.log
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sync failed" >> /var/log/xray/iplimit-sync.log
fi
EOFSYNCSYNC

    sed -i "s/MASTER_IP_PLACEHOLDER/$master_ip/g" /usr/bin/xray-iplimit-sync
    sed -i "s/MASTER_PORT_PLACEHOLDER/$master_port/g" /usr/bin/xray-iplimit-sync
    chmod +x /usr/bin/xray-iplimit-sync
    
    # Add to cron (sync every 10 minutes)
    echo "*/10 * * * * root /usr/bin/xray-iplimit-sync" >> /etc/cron.d/xray-iplimit
    
    echo -e "${GREEN}✓${NC} Sync enabled to master: $master_ip"
    echo -e "${YELLOW}⚠${NC} Note: Setup SSH key or save password in script for auto-sync"
fi

# Installation summary
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              INSTALLATION COMPLETED!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${CYAN}Installed Files:${NC}"
echo "  • /usr/bin/xray-iplimit          (main script)"
echo "  • /usr/bin/menu-xray-iplimit     (management menu)"
[ ! -z "$interval" ] && echo "  • /etc/cron.d/xray-iplimit       (cron job: $interval min)"
[ "$sync_option" = "1" ] && echo "  • /usr/bin/xray-iplimit-sync     (sync script)"

echo -e "\n${CYAN}Data Directory:${NC}"
echo "  • /var/lib/xray-iplimit/"
echo "  • /var/log/xray/iplimit.log"

echo -e "\n${CYAN}Available Commands:${NC}"
echo "  ${GREEN}xray-iplimit${NC} set USER MAX_IP LOCK_MIN   - Set user limit"
echo "  ${GREEN}xray-iplimit${NC} lock USER                  - Lock user"
echo "  ${GREEN}xray-iplimit${NC} unlock USER                - Unlock user"
echo "  ${GREEN}xray-iplimit${NC} status                     - Show status"
echo "  ${GREEN}xray-iplimit${NC} list                       - List all users"
echo "  ${GREEN}xray-iplimit${NC} monitor                    - Run monitoring"
echo "  ${GREEN}menu-xray-iplimit${NC}                        - Interactive menu"

echo -e "\n${CYAN}Example Usage:${NC}"
echo "  ${YELLOW}# Set limit: max 2 IPs, lock 60 minutes${NC}"
echo "  xray-iplimit set john 2 60"
echo ""
echo "  ${YELLOW}# Lock user immediately${NC}"
echo "  xray-iplimit lock john"
echo ""
echo "  ${YELLOW}# Check status${NC}"
echo "  xray-iplimit status"

echo -e "\n${CYAN}Next Steps:${NC}"
echo "  1. Set limits for your users"
echo "  2. Test lock/unlock functionality"
echo "  3. Monitor logs: tail -f /var/log/xray/iplimit.log"

echo -e "\n${GREEN}✓${NC} Ready to use!"
echo ""
