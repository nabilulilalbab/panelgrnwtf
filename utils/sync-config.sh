#!/bin/bash

# XRAY IP Limiter - Multi-VPS Sync Manager
# Sync user limits configuration across multiple VPS

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SYNC_CONFIG="$HOME/.xray-iplimit-sync.conf"
LOCAL_CONFIG="/var/lib/xray-iplimit/user_limits.conf"

# Initialize sync config if not exists
if [ ! -f "$SYNC_CONFIG" ]; then
    cat > "$SYNC_CONFIG" << 'EOF'
# XRAY IP Limiter - Sync Configuration
# Format: VPS_NAME:IP:PORT:PASSWORD

# Example:
# vps1:202.10.38.129:22:yourpassword
# vps2:192.168.1.100:22:anotherpassword

EOF
    echo -e "${YELLOW}[SETUP]${NC} Config file created: $SYNC_CONFIG"
    echo -e "${YELLOW}[SETUP]${NC} Please add your VPS list to this file"
    exit 0
fi

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║      ${CYAN}XRAY IP LIMITER - SYNC MANAGER${GREEN}               ║${NC}"
    echo -e "${GREEN}║      ${YELLOW}Multi-VPS Configuration Sync${GREEN}                  ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Push Config to All VPS"
    echo -e "  ${CYAN}[2]${NC} Pull Config from VPS"
    echo -e "  ${CYAN}[3]${NC} View Current Config"
    echo -e "  ${CYAN}[4]${NC} View VPS List"
    echo -e "  ${CYAN}[5]${NC} Edit VPS List"
    echo -e "  ${CYAN}[6]${NC} Test Connection to All VPS"
    echo -e "  ${CYAN}[7]${NC} Sync Status (Check All VPS)"
    echo -e "  ${RED}[0]${NC} Exit"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    read -p "Select option: " option
}

push_config_to_all() {
    echo -e "\n${CYAN}[PUSH]${NC} Pushing config to all VPS...\n"
    
    if [ ! -f "$LOCAL_CONFIG" ]; then
        echo -e "${RED}✗${NC} Local config not found: $LOCAL_CONFIG"
        return
    fi
    
    local count=0
    local success=0
    
    while IFS=: read -r name ip port password; do
        # Skip comments and empty lines
        [[ "$name" =~ ^#.*$ ]] && continue
        [ -z "$name" ] && continue
        
        count=$((count + 1))
        echo -e "${YELLOW}[$count]${NC} Pushing to $name ($ip)..."
        
        sshpass -p "$password" scp -P "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
            "$LOCAL_CONFIG" "root@$ip:/var/lib/xray-iplimit/user_limits.conf" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "     ${GREEN}✓${NC} Success"
            success=$((success + 1))
        else
            echo -e "     ${RED}✗${NC} Failed"
        fi
    done < "$SYNC_CONFIG"
    
    echo -e "\n${GREEN}[SUMMARY]${NC} Pushed to ${success}/${count} VPS"
    read -p "Press Enter to continue..."
}

pull_config_from_vps() {
    echo -e "\n${CYAN}[PULL]${NC} Available VPS:\n"
    
    local index=0
    declare -a vps_list
    
    while IFS=: read -r name ip port password; do
        [[ "$name" =~ ^#.*$ ]] && continue
        [ -z "$name" ] && continue
        
        index=$((index + 1))
        vps_list[$index]="$name:$ip:$port:$password"
        echo -e "  ${CYAN}[$index]${NC} $name ($ip)"
    done < "$SYNC_CONFIG"
    
    echo ""
    read -p "Select VPS number to pull from: " selected
    
    if [ -z "${vps_list[$selected]}" ]; then
        echo -e "${RED}✗${NC} Invalid selection"
        read -p "Press Enter to continue..."
        return
    fi
    
    IFS=: read -r name ip port password <<< "${vps_list[$selected]}"
    
    echo -e "\n${YELLOW}[PULLING]${NC} From $name ($ip)..."
    
    # Backup local config first
    if [ -f "$LOCAL_CONFIG" ]; then
        cp "$LOCAL_CONFIG" "${LOCAL_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${BLUE}[BACKUP]${NC} Local config backed up"
    fi
    
    sshpass -p "$password" scp -P "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
        "root@$ip:/var/lib/xray-iplimit/user_limits.conf" "$LOCAL_CONFIG" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Config pulled successfully"
        echo -e "\n${CYAN}[CONTENT]${NC}"
        cat "$LOCAL_CONFIG"
    else
        echo -e "${RED}✗${NC} Failed to pull config"
    fi
    
    read -p "Press Enter to continue..."
}

view_current_config() {
    echo -e "\n${CYAN}[CONFIG]${NC} Current user limits configuration:\n"
    
    if [ -f "$LOCAL_CONFIG" ]; then
        if [ -s "$LOCAL_CONFIG" ]; then
            cat "$LOCAL_CONFIG" | while IFS=: read -r user max_ip lock_min; do
                echo -e "  ${BLUE}▸${NC} ${user}: Max ${GREEN}${max_ip}${NC} IPs, Lock ${RED}${lock_min}${NC} minutes"
            done
        else
            echo -e "${YELLOW}⚠${NC} No user limits configured yet"
        fi
    else
        echo -e "${RED}✗${NC} Config file not found"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

view_vps_list() {
    echo -e "\n${CYAN}[VPS LIST]${NC} Configured VPS servers:\n"
    
    local count=0
    while IFS=: read -r name ip port password; do
        [[ "$name" =~ ^#.*$ ]] && continue
        [ -z "$name" ] && continue
        
        count=$((count + 1))
        local masked_pass=$(echo "$password" | sed 's/./*/g')
        echo -e "  ${CYAN}[$count]${NC} ${GREEN}$name${NC}"
        echo -e "      IP:       $ip"
        echo -e "      Port:     $port"
        echo -e "      Password: $masked_pass"
        echo ""
    done < "$SYNC_CONFIG"
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}⚠${NC} No VPS configured yet"
        echo -e "${YELLOW}⚠${NC} Edit $SYNC_CONFIG to add VPS"
    fi
    
    read -p "Press Enter to continue..."
}

edit_vps_list() {
    echo -e "\n${CYAN}[EDIT]${NC} Opening VPS list in editor...\n"
    
    if command -v nano &> /dev/null; then
        nano "$SYNC_CONFIG"
    elif command -v vi &> /dev/null; then
        vi "$SYNC_CONFIG"
    else
        echo -e "${RED}✗${NC} No text editor found"
        echo -e "${YELLOW}⚠${NC} Edit manually: $SYNC_CONFIG"
        read -p "Press Enter to continue..."
        return
    fi
}

test_connections() {
    echo -e "\n${CYAN}[TEST]${NC} Testing connections to all VPS...\n"
    
    local count=0
    local success=0
    
    while IFS=: read -r name ip port password; do
        [[ "$name" =~ ^#.*$ ]] && continue
        [ -z "$name" ] && continue
        
        count=$((count + 1))
        echo -e "${YELLOW}[$count]${NC} Testing $name ($ip:$port)..."
        
        sshpass -p "$password" ssh -p "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
            "root@$ip" "echo 'OK'" 2>/dev/null | grep -q "OK"
        
        if [ $? -eq 0 ]; then
            echo -e "     ${GREEN}✓${NC} Connected successfully"
            success=$((success + 1))
        else
            echo -e "     ${RED}✗${NC} Connection failed"
        fi
    done < "$SYNC_CONFIG"
    
    echo -e "\n${GREEN}[SUMMARY]${NC} ${success}/${count} VPS accessible"
    read -p "Press Enter to continue..."
}

sync_status() {
    echo -e "\n${CYAN}[STATUS]${NC} Checking sync status on all VPS...\n"
    
    local count=0
    
    while IFS=: read -r name ip port password; do
        [[ "$name" =~ ^#.*$ ]] && continue
        [ -z "$name" ] && continue
        
        count=$((count + 1))
        echo -e "${YELLOW}[$count]${NC} ${GREEN}$name${NC} ($ip)"
        
        local result=$(sshpass -p "$password" ssh -p "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
            "root@$ip" "xray-iplimit status 2>/dev/null | grep -E 'Total users|Locked users|Active connections'" 2>/dev/null)
        
        if [ ! -z "$result" ]; then
            echo "$result" | sed 's/^/     /'
        else
            echo -e "     ${RED}✗${NC} Cannot retrieve status"
        fi
        echo ""
    done < "$SYNC_CONFIG"
    
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    
    case $option in
        1) push_config_to_all ;;
        2) pull_config_from_vps ;;
        3) view_current_config ;;
        4) view_vps_list ;;
        5) edit_vps_list ;;
        6) test_connections ;;
        7) sync_status ;;
        0) exit 0 ;;
        *) 
            echo -e "\n${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
