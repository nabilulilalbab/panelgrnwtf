#!/bin/bash

# =========================================
# Cron Jobs Manager - Auto Setup & Validation
# =========================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ${GREEN}CRON JOBS MANAGER & AUTO SETUP${CYAN}              ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if cron service is running
if ! systemctl is-active --quiet cron; then
    echo -e "${RED}✗ Cron service is not running!${NC}"
    echo -e "${YELLOW}  Starting cron service...${NC}"
    systemctl start cron
    systemctl enable cron
    echo -e "${GREEN}✓ Cron service started${NC}"
fi

echo -e "${GREEN}✓ Cron service is active${NC}"
echo ""

# Function to check if cron exists
check_cron() {
    local pattern="$1"
    crontab -l 2>/dev/null | grep -v "^#" | grep -q "$pattern"
}

# Function to add cron if not exists
add_cron() {
    local cron_entry="$1"
    local description="$2"
    
    if check_cron "$(echo "$cron_entry" | awk '{print $6}')" ; then
        echo -e "  ${GREEN}✓${NC} $description - Already active"
        return 0
    else
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        echo -e "  ${YELLOW}+${NC} $description - ${GREEN}ADDED${NC}"
        return 1
    fi
}

echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Scanning and configuring cron jobs...${NC}"
echo ""

added=0
existing=0

# 1. IP Limit Monitor
if add_cron "*/2 * * * * /usr/bin/xray-iplimit monitor >/dev/null 2>&1" "IP Limit Monitor (every 2 minutes)"; then
    ((existing++))
else
    ((added++))
fi

# 2. Quota Monitor
if add_cron "0 */6 * * * /usr/bin/xray-iplimit quota-monitor >/dev/null 2>&1" "Quota Monitor (every 6 hours)"; then
    ((existing++))
else
    ((added++))
fi

# 3. Delete Expired Accounts
if add_cron "0 0 * * * /usr/bin/xp >/dev/null 2>&1" "Delete Expired Accounts (daily at midnight)"; then
    ((existing++))
else
    ((added++))
fi

# 4. Clear Logs
if add_cron "0 2 * * 0 /usr/bin/clearlog >/dev/null 2>&1" "Clear Logs (weekly on Sunday)"; then
    ((existing++))
else
    ((added++))
fi

# 5. Auto Backup to Telegram
echo ""
echo -e "${YELLOW}Checking Auto Backup configuration...${NC}"

# Check if telegram is configured
telegram_configured=false
if [ -f "/var/lib/xray-iplimit/telegram.conf" ]; then
    source /var/lib/xray-iplimit/telegram.conf
    if [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        telegram_configured=true
    fi
elif [ -f "/root/botapi.conf" ]; then
    source /root/botapi.conf
    if [ -n "$toket" ] && [ -n "$chat_idc" ]; then
        telegram_configured=true
    fi
fi

if [ "$telegram_configured" = true ]; then
    if add_cron "*/10 * * * * /usr/bin/backup-telegram-auto >/dev/null 2>&1" "Auto Backup to Telegram (every 10 minutes)"; then
        ((existing++))
    else
        ((added++))
    fi
else
    echo -e "  ${YELLOW}⚠${NC}  Auto Backup - ${RED}Telegram not configured${NC}"
    echo -e "     ${CYAN}Run 'telegram-setup' or menu option [58] to configure${NC}"
fi

# 6. Check SSL renewal (usually set by acme.sh, don't modify)
if check_cron "acme.sh --cron"; then
    echo -e "  ${GREEN}✓${NC} SSL Certificate Renewal - Already active"
    ((existing++))
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Summary:${NC}"
echo -e "  ${GREEN}✓${NC} Already active: $existing cron jobs"
if [ $added -gt 0 ]; then
    echo -e "  ${YELLOW}+${NC} Newly added: $added cron jobs"
fi
echo ""

# Show current crontab
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Current Cron Jobs:${NC}"
echo ""
crontab -l | grep -v "^#" | grep -v "^$" | while read line; do
    echo -e "  ${CYAN}•${NC} $line"
done
echo ""

# Additional options
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Additional Options:${NC}"
echo ""
echo -e "  ${CYAN}[1]${NC} View cron logs (last 20 executions)"
echo -e "  ${CYAN}[2]${NC} Test IP Limiter manually"
echo -e "  ${CYAN}[3]${NC} Test Auto Backup manually"
echo -e "  ${CYAN}[4]${NC} Configure Telegram Bot"
echo -e "  ${CYAN}[5]${NC} Remove all cron jobs"
echo -e "  ${CYAN}[0]${NC} Exit"
echo ""
read -p "Select option [0-5]: " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Recent cron executions:${NC}"
        echo ""
        grep "CRON" /var/log/syslog 2>/dev/null | tail -20 || echo "No logs found"
        echo ""
        read -p "Press Enter to continue..."
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Running IP Limiter manually...${NC}"
        echo ""
        /usr/bin/xray-iplimit monitor
        echo ""
        read -p "Press Enter to continue..."
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Running Auto Backup manually...${NC}"
        echo ""
        if [ "$telegram_configured" = true ]; then
            /usr/bin/backup-telegram-auto
        else
            echo -e "${RED}Telegram not configured!${NC}"
            echo "Please run: telegram-setup"
        fi
        echo ""
        read -p "Press Enter to continue..."
        ;;
    4)
        telegram-setup
        ;;
    5)
        echo ""
        read -p "Are you sure you want to remove ALL cron jobs? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Backup current crontab
            crontab -l > /root/crontab.backup.$(date +%Y%m%d-%H%M%S)
            # Keep only SSL renewal crons (important!)
            crontab -l | grep "acme.sh\|ssl_renew" | crontab -
            echo -e "${GREEN}✓ All custom cron jobs removed${NC}"
            echo -e "${YELLOW}  SSL renewal crons preserved${NC}"
            echo -e "${CYAN}  Backup saved to: /root/crontab.backup.*${NC}"
        fi
        echo ""
        read -p "Press Enter to continue..."
        ;;
    0|*)
        echo ""
        echo -e "${GREEN}Done!${NC}"
        ;;
esac

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}All cron jobs are now properly configured!${NC}"
echo ""
echo -e "${YELLOW}Tip:${NC} Run this script anytime to validate cron jobs"
echo -e "      Command: ${CYAN}cron-manager${NC}"
echo ""
