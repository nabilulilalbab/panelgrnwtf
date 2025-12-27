#!/bin/bash

# =========================================
# SSH Trial Account Creator
# =========================================

# Load helper functions
source /usr/local/bin/trial-helpers.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ${GREEN}CREATE SSH TRIAL ACCOUNT${CYAN}                      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Select duration
duration=$(select_duration)

# Debug: Check if duration was captured
if [ "$duration" == "0" ] || [ -z "$duration" ]; then
    echo -e "${RED}Invalid duration! Got: [$duration]${NC}" > /dev/tty
    read -p "Press Enter to continue..." < /dev/tty
    exit 1
fi

# Clean duration value (remove any whitespace/newlines)
duration=$(echo "$duration" | tr -d '\n\r ' | grep -o '[0-9]*' | head -1)

echo "" > /dev/tty
echo -e "${YELLOW}Creating SSH trial account (${duration}h)...${NC}" > /dev/tty
echo "" > /dev/tty

# Generate credentials
username=$(generate_unique_trial_username)
if [ -z "$username" ]; then
    echo -e "${RED}Failed to generate unique username!${NC}"
    echo -e "${YELLOW}Please try again later.${NC}"
    read -p "Press Enter to continue..."
    exit 1
fi

password=$(generate_trial_password)
expires=$(calculate_expiry $duration)
expires_full=$(calculate_expiry_datetime $duration)

# Create SSH user
useradd -e $(date -d "$expires" "+%Y-%m-%d") -s /bin/false -M "$username" > /dev/null 2>&1
echo "$username:$password" | chpasswd > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create SSH user!${NC}"
    read -p "Press Enter to continue..."
    exit 1
fi

# Save trial info
save_trial_info "ssh" "$username" "$password" "" "$expires_full" "$duration"

# Log creation
log_trial_creation "ssh" "$username" "$duration"

# Get server info
domain=$(get_domain)
server_ip=$(get_server_ip)

# Display account info
clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ${GREEN}SSH TRIAL ACCOUNT CREATED${CYAN}                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Trial account created successfully!${NC}"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Account Details:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "  Server IP   : ${GREEN}$server_ip${NC}"
echo -e "  Domain      : ${GREEN}$domain${NC}"
echo -e "  Username    : ${GREEN}$username${NC}"
echo -e "  Password    : ${GREEN}$password${NC}"
echo -e "  Created     : ${YELLOW}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "  Expires     : ${RED}${expires_full}${NC}"
echo -e "  Duration    : ${YELLOW}${duration} hour(s)${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}SSH Ports Available:${NC}"
echo -e "  • Port 22    (OpenSSH)"
echo -e "  • Port 109   (Dropbear)"
echo -e "  • Port 143   (Dropbear)"
echo -e "  • Port 443   (Stunnel/SSL)"
echo ""
echo -e "${GREEN}SSH Command:${NC}"
echo -e "  ${CYAN}ssh $username@$domain${NC}"
echo -e "  ${CYAN}ssh $username@$server_ip${NC}"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${RED}⚠️  IMPORTANT:${NC}"
echo -e "  • This is a TRIAL account"
echo -e "  • Valid for ${YELLOW}${duration}${NC} hour(s) only"
echo -e "  • Account will be ${RED}automatically deleted${NC} after expiry"
echo -e "  • No refund or extension"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""
read -p "Press Enter to continue..."
