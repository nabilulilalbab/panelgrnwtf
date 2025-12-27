#!/bin/bash

# XRAY IP Limiter + Quota Management - Complete Installer
# Includes: IP Limiter, Quota System, Auto-Monitor Cron

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║      ${CYAN}XRAY IP LIMITER + QUOTA - INSTALLER${GREEN}        ║${NC}"
echo -e "${GREEN}║      ${YELLOW}Complete System with Auto-Monitor${GREEN}          ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗${NC} Please run as root"
    exit 1
fi

echo -e "${CYAN}[INFO]${NC} Installing XRAY IP Limiter + Quota System..."
echo ""

# Create directories
mkdir -p /var/lib/xray-iplimit/backups
mkdir -p /var/log/xray
echo -e "${GREEN}✓${NC} Directories created"

# Install main script
if [ -f "xray-iplimit.sh" ]; then
    cp xray-iplimit.sh /usr/bin/xray-iplimit
    chmod +x /usr/bin/xray-iplimit
    echo -e "${GREEN}✓${NC} Main script installed: /usr/bin/xray-iplimit"
else
    echo -e "${RED}✗${NC} xray-iplimit.sh not found!"
    exit 1
fi

# Install menu-xray-iplimit
if [ -f "menu-xray-iplimit.sh" ]; then
    cp menu-xray-iplimit.sh /usr/bin/menu-xray-iplimit
    chmod +x /usr/bin/menu-xray-iplimit
    echo -e "${GREEN}✓${NC} IP Limit menu installed: /usr/bin/menu-xray-iplimit"
fi

# Install menu-quota (NEW!)
if [ -f "menu-quota.sh" ]; then
    cp menu-quota.sh /usr/bin/menu-quota
    chmod +x /usr/bin/menu-quota
    echo -e "${GREEN}✓${NC} Quota menu installed: /usr/bin/menu-quota"
else
    echo -e "${YELLOW}⚠${NC} menu-quota.sh not found, skipping"
fi

# Install other menu files if available
for menu_file in menu-vmess.sh menu-vless.sh menu-trojan.sh menu-ssh.sh; do
    if [ -f "$menu_file" ]; then
        menu_name=$(basename "$menu_file" .sh)
        cp "$menu_file" /usr/bin/"$menu_name"
        chmod +x /usr/bin/"$menu_name"
        echo -e "${GREEN}✓${NC} ${menu_name} installed"
    fi
done

# Install backup & restore scripts
echo ""
echo -e "${CYAN}[BACKUP]${NC} Installing backup & restore scripts..."

if [ -f "backup.sh" ]; then
    cp backup.sh /root/backup.sh
    chmod +x /root/backup.sh
    echo -e "${GREEN}✓${NC} backup.sh installed"
fi

if [ -f "menu-bckp-telegram.sh" ]; then
    cp menu-bckp-telegram.sh /root/menu-bckp-telegram.sh
    chmod +x /root/menu-bckp-telegram.sh
    echo -e "${GREEN}✓${NC} menu-bckp-telegram.sh installed"
fi

if [ -f "restore.sh" ]; then
    cp restore.sh /root/restore.sh
    chmod +x /root/restore.sh
    echo -e "${GREEN}✓${NC} restore.sh installed"
fi

if [ -f "backup-telegram-auto.sh" ]; then
    cp backup-telegram-auto.sh /usr/bin/backup-telegram-auto
    chmod +x /usr/bin/backup-telegram-auto
    echo -e "${GREEN}✓${NC} backup-telegram-auto installed"
fi

echo ""
echo -e "${YELLOW}[SETUP]${NC} Configure Auto-Monitoring Cron:"
echo ""
echo -e "${CYAN}IP Limit Monitoring:${NC}"
echo "  [1] Every 2 minutes (fastest)"
echo "  [2] Every 5 minutes (recommended)"
echo "  [3] Every 10 minutes"
echo "  [4] Every 15 minutes"
echo ""
read -p "Select IP Limit interval [2]: " ip_option
ip_option=${ip_option:-2}

case $ip_option in
    1) IP_INTERVAL="*/2" ;;
    2) IP_INTERVAL="*/5" ;;
    3) IP_INTERVAL="*/10" ;;
    4) IP_INTERVAL="*/15" ;;
    *) IP_INTERVAL="*/5" ;;
esac

echo ""
echo -e "${CYAN}Quota Monitoring:${NC}"
echo "  [1] Every 5 minutes"
echo "  [2] Every 10 minutes (recommended)"
echo "  [3] Every 15 minutes"
echo "  [4] Every 30 minutes"
echo "  [5] Skip quota monitoring"
echo ""
read -p "Select Quota interval [2]: " quota_option
quota_option=${quota_option:-2}

case $quota_option in
    1) QUOTA_INTERVAL="*/5" ;;
    2) QUOTA_INTERVAL="*/10" ;;
    3) QUOTA_INTERVAL="*/15" ;;
    4) QUOTA_INTERVAL="*/30" ;;
    5) QUOTA_INTERVAL="" ;;
    *) QUOTA_INTERVAL="*/10" ;;
esac

# Create cron job
if [ ! -z "$IP_INTERVAL" ] || [ ! -z "$QUOTA_INTERVAL" ]; then
    cat > /etc/cron.d/xray-iplimit << EOFCRON
# XRAY IP Limiter + Quota Monitor

EOFCRON

    if [ ! -z "$IP_INTERVAL" ]; then
        echo "# IP Limit Monitoring" >> /etc/cron.d/xray-iplimit
        echo "$IP_INTERVAL * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1" >> /etc/cron.d/xray-iplimit
        echo "" >> /etc/cron.d/xray-iplimit
    fi

    if [ ! -z "$QUOTA_INTERVAL" ]; then
        echo "# Quota Monitoring" >> /etc/cron.d/xray-iplimit
        echo "$QUOTA_INTERVAL * * * * root /usr/bin/xray-iplimit quota-monitor >> /var/log/xray/quota-cron.log 2>&1" >> /etc/cron.d/xray-iplimit
        echo "" >> /etc/cron.d/xray-iplimit
    fi

    chmod 644 /etc/cron.d/xray-iplimit
    systemctl restart cron 2>/dev/null || service cron restart 2>/dev/null
    echo ""
    echo -e "${GREEN}✓${NC} Cron jobs installed:"
    [ ! -z "$IP_INTERVAL" ] && echo -e "  ${CYAN}→${NC} IP Limit: Every $IP_INTERVAL minutes"
    [ ! -z "$QUOTA_INTERVAL" ] && echo -e "  ${CYAN}→${NC} Quota Monitor: Every $QUOTA_INTERVAL minutes"
fi

# Create initial config files
touch /var/lib/xray-iplimit/locked_users.txt
touch /var/lib/xray-iplimit/user_uuid_map.txt
touch /var/lib/xray-iplimit/ip_sessions.txt
touch /var/lib/xray-iplimit/user_limits.conf
touch /var/log/xray/iplimit.log
touch /var/log/xray/iplimit-cron.log
touch /var/log/xray/quota.log
touch /var/log/xray/quota-cron.log

echo -e "${GREEN}✓${NC} Configuration files created"

# Optional: Import existing config
echo ""
echo -e "${YELLOW}[IMPORT]${NC} Do you want to import existing user limits config?"
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

# Installation summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              INSTALLATION COMPLETED!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Auto-backup setup
echo -e "${YELLOW}[AUTO-BACKUP]${NC} Setup automatic backup to Telegram?"
echo "  [1] Yes, setup auto-backup"
echo "  [2] No, skip (can setup later)"
read -p "Select option [2]: " backup_option
backup_option=${backup_option:-2}

if [ "$backup_option" = "1" ]; then
    echo ""
    echo -e "${CYAN}Auto-backup interval:${NC}"
    echo "  [1] Every 10 minutes (recommended for important VPS)"
    echo "  [2] Every 30 minutes"
    echo "  [3] Every 60 minutes (1 hour)"
    echo "  [4] Every 6 hours"
    read -p "Select interval [1]: " backup_interval_opt
    backup_interval_opt=${backup_interval_opt:-1}
    
    case $backup_interval_opt in
        1) BACKUP_INTERVAL="*/10" ;;
        2) BACKUP_INTERVAL="*/30" ;;
        3) BACKUP_INTERVAL="0 *" ;;
        4) BACKUP_INTERVAL="0 */6" ;;
        *) BACKUP_INTERVAL="*/10" ;;
    esac
    
    # Create auto-backup cron
    if [ -f "/usr/bin/backup-telegram-auto" ]; then
        cat > /etc/cron.d/backup-telegram-auto << EOFBKP
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto backup to Telegram
$BACKUP_INTERVAL * * * root /usr/bin/backup-telegram-auto >> /var/log/xray/backup-telegram-cron.log 2>&1
EOFBKP
        chmod 644 /etc/cron.d/backup-telegram-auto
        systemctl restart cron 2>/dev/null || service cron restart 2>/dev/null
        echo ""
        echo -e "${GREEN}✓${NC} Auto-backup cron configured"
        echo -e "  ${CYAN}→${NC} Interval: $BACKUP_INTERVAL"
        echo -e "  ${YELLOW}Note:${NC} Setup Telegram bot first: /root/menu-bckp-telegram.sh"
    else
        echo -e "${RED}✗${NC} backup-telegram-auto not found, skipping cron setup"
    fi
else
    echo ""
    echo -e "${YELLOW}⚠${NC} Auto-backup skipped. You can setup later."
fi

echo ""
echo -e "${CYAN}Installed Components:${NC}"
echo ""
echo -e "${YELLOW}Core Scripts:${NC}"
echo "  • /usr/bin/xray-iplimit          (main script)"
echo "  • /usr/bin/menu-xray-iplimit     (IP limit menu)"
echo "  • /usr/bin/menu-quota            (quota management menu)"
echo ""

echo -e "${YELLOW}Menu Scripts:${NC}"
[ -f "/usr/bin/menu-vmess" ] && echo "  • /usr/bin/menu-vmess"
[ -f "/usr/bin/menu-vless" ] && echo "  • /usr/bin/menu-vless"
[ -f "/usr/bin/menu-trojan" ] && echo "  • /usr/bin/menu-trojan"
[ -f "/usr/bin/menu-ssh" ] && echo "  • /usr/bin/menu-ssh"
echo ""

echo -e "${YELLOW}Cron Jobs:${NC}"
if [ -f "/etc/cron.d/xray-iplimit" ]; then
    echo "  • /etc/cron.d/xray-iplimit"
    [ ! -z "$IP_INTERVAL" ] && echo "    - IP Limit: Every $IP_INTERVAL minutes"
    [ ! -z "$QUOTA_INTERVAL" ] && echo "    - Quota: Every $QUOTA_INTERVAL minutes"
fi
echo ""

echo -e "${CYAN}Data Directory:${NC}"
echo "  • /var/lib/xray-iplimit/"
echo "  • /var/log/xray/"
echo ""

echo -e "${CYAN}Available Commands:${NC}"
echo ""
echo -e "${YELLOW}IP Limit Commands:${NC}"
echo "  ${GREEN}xray-iplimit${NC} set USER MAX_IP LOCK_MIN   - Set user IP limit"
echo "  ${GREEN}xray-iplimit${NC} lock USER                  - Lock user"
echo "  ${GREEN}xray-iplimit${NC} unlock USER                - Unlock user"
echo "  ${GREEN}xray-iplimit${NC} status                     - Show IP limit status"
echo "  ${GREEN}xray-iplimit${NC} monitor                    - Run IP monitoring"
echo ""

echo -e "${YELLOW}Quota Commands:${NC}"
echo "  ${GREEN}xray-iplimit${NC} quota-set USER GB          - Set quota limit"
echo "  ${GREEN}xray-iplimit${NC} quota-check USER           - Check quota usage"
echo "  ${GREEN}xray-iplimit${NC} quota-status               - Show all quotas"
echo "  ${GREEN}xray-iplimit${NC} quota-monitor              - Run quota monitoring"
echo "  ${GREEN}xray-iplimit${NC} quota-reset USER           - Reset user quota"
echo ""

echo -e "${YELLOW}Menu Commands:${NC}"
echo "  ${GREEN}menu-xray-iplimit${NC}                        - IP Limit menu"
echo "  ${GREEN}menu-quota${NC}                               - Quota management menu"
echo ""

echo -e "${YELLOW}Backup & Restore Commands:${NC}"
if [ -f "/root/backup.sh" ]; then
    echo "  ${GREEN}/root/backup.sh${NC}                        - Create backup"
fi
if [ -f "/root/restore.sh" ]; then
    echo "  ${GREEN}/root/restore.sh${NC}                       - Restore from backup"
fi
if [ -f "/root/menu-bckp-telegram.sh" ]; then
    echo "  ${GREEN}/root/menu-bckp-telegram.sh${NC}            - Backup to Telegram (setup bot)"
fi
if [ -f "/usr/bin/backup-telegram-auto" ]; then
    echo "  ${GREEN}backup-telegram-auto${NC}                   - Manual trigger auto-backup"
fi
if [ -f "/etc/cron.d/backup-telegram-auto" ]; then
    echo "  ${CYAN}→${NC} Auto-backup: ENABLED"
fi
echo ""

echo -e "${CYAN}Example Usage:${NC}"
echo ""
echo -e "${YELLOW}# Set IP limit: max 2 IPs, lock 60 minutes${NC}"
echo "  xray-iplimit set john 2 60"
echo ""
echo -e "${YELLOW}# Set quota: 10 GB limit${NC}"
echo "  xray-iplimit quota-set john 10"
echo ""
echo -e "${YELLOW}# Check quota usage${NC}"
echo "  xray-iplimit quota-check john"
echo ""
echo -e "${YELLOW}# View all quota status${NC}"
echo "  xray-iplimit quota-status"
echo ""
echo -e "${YELLOW}# Access interactive menus${NC}"
echo "  menu-quota"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo "  1. Configure user limits and quotas"
echo "  2. Test functionality with: menu-quota"
echo "  3. Monitor logs: tail -f /var/log/xray/iplimit.log"
echo "  4. Check quota logs: tail -f /var/log/xray/quota-cron.log"
echo ""

echo -e "${GREEN}✓${NC} System ready to use!"
echo ""
