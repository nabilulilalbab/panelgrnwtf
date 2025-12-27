#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║      ${CYAN}XRAY IP LIMITER - MANAGEMENT MENU${GREEN}            ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${YELLOW}  IP LIMIT MANAGEMENT:${NC}"
echo -e "  ${CYAN}[1]${NC} Set User IP Limit"
echo -e "  ${CYAN}[2]${NC} Lock User Manually"
echo -e "  ${CYAN}[3]${NC} Unlock User Manually"
echo -e "  ${CYAN}[4]${NC} View Status & Locked Users"
echo -e "  ${CYAN}[5]${NC} List All Users with Limits"
echo -e ""
echo -e "${YELLOW}  QUOTA MANAGEMENT:${NC}"
echo -e "  ${GREEN}[6]${NC} Set User Quota"
echo -e "  ${GREEN}[7]${NC} Check User Quota"
echo -e "  ${GREEN}[8]${NC} View All Quotas Status"
echo -e "  ${GREEN}[9]${NC} Reset User Quota"
echo -e ""
echo -e "${YELLOW}  MONITORING:${NC}"
echo -e "  ${CYAN}[10]${NC} View Logs"
echo -e "  ${CYAN}[11]${NC} Setup Auto-Monitor (Cron)"
echo -e "  ${CYAN}[12]${NC} Run Monitor Once (Manual)"
echo -e "  ${CYAN}[13]${NC} Remove Auto-Monitor"
echo -e "  ${RED}[0]${NC} Exit"
echo -e ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
read -p "Select option: " option

case $option in
    1)
        echo -e "\n${CYAN}═══ Set User IP Limit ═══${NC}"
        read -p "Username: " username
        read -p "Max IPs allowed: " max_ip
        read -p "Lock duration (minutes): " lock_mins
        
        xray-iplimit set "$username" "$max_ip" "$lock_mins"
        
        echo -e "\n${GREEN}✓ Configuration saved!${NC}"
        read -p "Press Enter to continue..."
        ;;
    2)
        echo -e "\n${CYAN}═══ Lock User Manually ═══${NC}"
        read -p "Username to lock: " username
        
        xray-iplimit lock "$username"
        
        echo -e "\n${GREEN}✓ User locked!${NC}"
        read -p "Press Enter to continue..."
        ;;
    3)
        echo -e "\n${CYAN}═══ Unlock User Manually ═══${NC}"
        read -p "Username to unlock: " username
        
        xray-iplimit unlock "$username"
        
        echo -e "\n${GREEN}✓ User unlocked!${NC}"
        read -p "Press Enter to continue..."
        ;;
    4)
        echo -e "\n${CYAN}═══ System Status ═══${NC}"
        xray-iplimit status
        
        read -p "Press Enter to continue..."
        ;;
    5)
        echo -e "\n${CYAN}═══ All Users ═══${NC}"
        xray-iplimit list
        
        read -p "Press Enter to continue..."
        ;;
    6)
        echo -e "\n${CYAN}═══ Set User Quota ═══${NC}"
        read -p "Username: " username
        read -p "Quota (GB): " quota_gb
        
        xray-iplimit quota-set "$username" "$quota_gb"
        
        echo -e "\n${GREEN}✓ Quota set!${NC}"
        read -p "Press Enter to continue..."
        ;;
    7)
        echo -e "\n${CYAN}═══ Check User Quota ═══${NC}"
        read -p "Username: " username
        
        xray-iplimit quota-check "$username"
        
        read -p "Press Enter to continue..."
        ;;
    8)
        echo -e "\n${CYAN}═══ All Users Quota Status ═══${NC}"
        xray-iplimit quota-status
        
        read -p "Press Enter to continue..."
        ;;
    9)
        echo -e "\n${CYAN}═══ Reset User Quota ═══${NC}"
        read -p "Username: " username
        
        xray-iplimit quota-reset "$username"
        
        echo -e "\n${GREEN}✓ Quota reset!${NC}"
        read -p "Press Enter to continue..."
        ;;
    10)
        echo -e "\n${CYAN}═══ Recent Logs (last 30 lines) ═══${NC}"
        echo -e "${YELLOW}IP Limiter Logs:${NC}"
        tail -15 /var/log/xray/iplimit.log 2>/dev/null || echo "No logs yet"
        echo ""
        echo -e "${YELLOW}Quota Logs:${NC}"
        tail -15 /var/log/xray/quota.log 2>/dev/null || echo "No quota logs yet"
        
        read -p "Press Enter to continue..."
        ;;
    11)
        echo -e "\n${CYAN}═══ Setup Auto-Monitor ═══${NC}"
        echo "Select monitoring interval:"
        echo "  [1] Every 5 minutes"
        echo "  [2] Every 10 minutes"
        echo "  [3] Every 15 minutes"
        read -p "Choice: " interval_choice
        
        case $interval_choice in
            1) interval="*/5" ;;
            2) interval="*/10" ;;
            3) interval="*/15" ;;
            *) echo "Invalid choice"; read -p "Press Enter..."; exit 1 ;;
        esac
        
        # Create cron job
        echo "# XRAY IP Limiter Auto-Monitor" > /etc/cron.d/xray-iplimit
        echo "$interval * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1" >> /etc/cron.d/xray-iplimit
        
        echo -e "\n${GREEN}✓ Auto-monitor enabled!${NC}"
        echo -e "Monitoring every ${interval} minutes"
        read -p "Press Enter to continue..."
        ;;
    12)
        echo -e "\n${CYAN}═══ Running Monitor ═══${NC}"
        echo "Running IP limit monitor..."
        xray-iplimit monitor
        echo ""
        echo "Running quota monitor..."
        xray-iplimit quota-monitor
        
        echo -e "\n${GREEN}✓ Monitoring cycle completed${NC}"
        read -p "Press Enter to continue..."
        ;;
    13)
        rm -f /etc/cron.d/xray-iplimit
        echo -e "\n${GREEN}✓ Auto-monitor removed!${NC}"
        read -p "Press Enter to continue..."
        ;;
    0)
        exit 0
        ;;
    *)
        echo -e "\n${RED}Invalid option!${NC}"
        read -p "Press Enter to continue..."
        ;;
esac

# Loop back to menu
exec "$0"
