#!/bin/bash

# =========================================
# Trial Accounts Manager - Main Menu
# =========================================

# Load helper functions
source /usr/local/bin/trial-helpers.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# List all active trials
list_trials() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         ${GREEN}ACTIVE TRIAL ACCOUNTS${CYAN}                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local total=0
    local current_time=$(date +%s)
    
    # SSH Trials
    if [ -d "/var/lib/trials/ssh" ] && [ "$(ls -A /var/lib/trials/ssh/*.conf 2>/dev/null)" ]; then
        echo -e "${YELLOW}SSH Trials:${NC}"
        echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
        printf "%-15s %-12s %-20s %-10s\n" "Username" "Duration" "Expires" "Status"
        echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
        
        for conf in /var/lib/trials/ssh/*.conf; do
            source "$conf"
            local expiry_time=$(date -d "$EXPIRES" +%s 2>/dev/null)
            local time_left=$(( (expiry_time - current_time) / 60 ))
            
            if [ $time_left -gt 0 ]; then
                local status="${GREEN}Active${NC}"
                local time_display="${time_left}m left"
            else
                local status="${RED}Expired${NC}"
                local time_display="Expired"
            fi
            
            printf "%-15s %-12s %-20s " "$USERNAME" "${DURATION}" "$(date -d "$EXPIRES" '+%Y-%m-%d %H:%M')"
            echo -e "$status"
            ((total++))
        done
        echo ""
    fi
    
    # VMess Trials (if exists)
    if [ -d "/var/lib/trials/vmess" ] && [ "$(ls -A /var/lib/trials/vmess/*.conf 2>/dev/null)" ]; then
        echo -e "${YELLOW}VMess Trials:${NC}"
        echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
        printf "%-15s %-12s %-20s %-10s\n" "Username" "Duration" "Expires" "Status"
        echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
        
        for conf in /var/lib/trials/vmess/*.conf; do
            source "$conf"
            local expiry_time=$(date -d "$EXPIRES" +%s 2>/dev/null)
            local time_left=$(( (expiry_time - current_time) / 60 ))
            
            if [ $time_left -gt 0 ]; then
                local status="${GREEN}Active${NC}"
            else
                local status="${RED}Expired${NC}"
            fi
            
            printf "%-15s %-12s %-20s " "$USERNAME" "${DURATION}" "$(date -d "$EXPIRES" '+%Y-%m-%d %H:%M')"
            echo -e "$status"
            ((total++))
        done
        echo ""
    fi
    
    # VLess Trials
    if [ -d "/var/lib/trials/vless" ] && [ "$(ls -A /var/lib/trials/vless/*.conf 2>/dev/null)" ]; then
        echo -e "${YELLOW}VLess Trials:${NC}"
        echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
        for conf in /var/lib/trials/vless/*.conf; do
            source "$conf"
            echo -e "  ${GREEN}•${NC} $USERNAME - Expires: $EXPIRES"
            ((total++))
        done
        echo ""
    fi
    
    # Trojan Trials
    if [ -d "/var/lib/trials/trojan" ] && [ "$(ls -A /var/lib/trials/trojan/*.conf 2>/dev/null)" ]; then
        echo -e "${YELLOW}Trojan Trials:${NC}"
        echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
        for conf in /var/lib/trials/trojan/*.conf; do
            source "$conf"
            echo -e "  ${GREEN}•${NC} $USERNAME - Expires: $EXPIRES"
            ((total++))
        done
        echo ""
    fi
    
    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}No active trials found.${NC}"
        echo ""
    else
        echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
        echo -e "Total Active Trials: ${GREEN}$total${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
        echo ""
    fi
    
    read -p "Press Enter to continue..."
}

# Delete trial manually
delete_trial() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         ${RED}DELETE TRIAL ACCOUNT${CYAN}                          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Enter trial username to delete: " username
    
    if [ -z "$username" ]; then
        echo -e "${RED}Username cannot be empty!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Check in SSH
    if [ -f "/var/lib/trials/ssh/${username}.conf" ]; then
        echo -e "${YELLOW}Deleting SSH trial: $username${NC}"
        userdel "$username" 2>/dev/null
        rm -f "/var/lib/trials/ssh/${username}.conf"
        log_trial_deletion "ssh" "$username" "Manual deletion"
        echo -e "${GREEN}✓ SSH trial deleted!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Check in VMess
    if [ -f "/var/lib/trials/vmess/${username}.conf" ]; then
        source "/var/lib/trials/vmess/${username}.conf"
        echo -e "${YELLOW}Deleting VMess trial: $username${NC}"
        sed -i "/^#vms $username/,/^},{/d" /etc/xray/config.json
        sed -i "/^#vmsg $username/,/^},{/d" /etc/xray/config.json
        rm -f /etc/xray/vmess-${username}-*.json
        rm -f "/var/lib/trials/vmess/${username}.conf"
        systemctl restart xray.service
        log_trial_deletion "vmess" "$username" "Manual deletion"
        echo -e "${GREEN}✓ VMess trial deleted!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${RED}Trial not found: $username${NC}"
    read -p "Press Enter to continue..."
}

# Main menu
while true; do
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         ${GREEN}TRIAL ACCOUNTS MANAGER${CYAN}                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Create Trial Account:${NC}"
    echo -e "  ${CYAN}[1]${NC} SSH Trial Account"
    echo -e "  ${CYAN}[2]${NC} VMess Trial ${PURPLE}(Coming Soon)${NC}"
    echo -e "  ${CYAN}[3]${NC} VLess Trial ${PURPLE}(Coming Soon)${NC}"
    echo -e "  ${CYAN}[4]${NC} Trojan Trial ${PURPLE}(Coming Soon)${NC}"
    echo ""
    echo -e "${YELLOW}Manage Trials:${NC}"
    echo -e "  ${CYAN}[5]${NC} List All Trials"
    echo -e "  ${CYAN}[6]${NC} Delete Trial Account"
    echo -e "  ${CYAN}[7]${NC} View Cleanup Logs"
    echo ""
    echo -e "  ${CYAN}[0]${NC} Back to Main Menu"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    read -p "Select [0-7]: " choice
    
    case $choice in
        1)
            trial-ssh
            ;;
        2)
            echo ""
            echo -e "${YELLOW}VMess trial creation coming soon!${NC}"
            echo -e "${CYAN}Currently only SSH trials are available.${NC}"
            read -p "Press Enter to continue..."
            ;;
        3)
            echo ""
            echo -e "${YELLOW}VLess trial creation coming soon!${NC}"
            echo -e "${CYAN}Currently only SSH trials are available.${NC}"
            read -p "Press Enter to continue..."
            ;;
        4)
            echo ""
            echo -e "${YELLOW}Trojan trial creation coming soon!${NC}"
            echo -e "${CYAN}Currently only SSH trials are available.${NC}"
            read -p "Press Enter to continue..."
            ;;
        5)
            list_trials
            ;;
        6)
            delete_trial
            ;;
        7)
            clear
            echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║         ${YELLOW}TRIAL CLEANUP LOGS${CYAN}                            ║${NC}"
            echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
            echo ""
            if [ -f "/var/log/trials/trial-cleanup.log" ]; then
                tail -n 50 /var/log/trials/trial-cleanup.log
            else
                echo -e "${YELLOW}No cleanup logs found yet.${NC}"
            fi
            echo ""
            read -p "Press Enter to continue..."
            ;;
        0)
            menu
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
