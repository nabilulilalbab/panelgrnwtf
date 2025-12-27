#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

TELEGRAM_CONFIG="/var/lib/xray-iplimit/telegram.conf"

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ${GREEN}TELEGRAM BOT SETUP${CYAN}                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if config already exists
if [ -f "$TELEGRAM_CONFIG" ]; then
    echo -e "${YELLOW}Current Configuration:${NC}"
    echo ""
    grep "^BOT_TOKEN=" "$TELEGRAM_CONFIG" | sed 's/BOT_TOKEN=/  Bot Token: /'
    grep "^CHAT_ID=" "$TELEGRAM_CONFIG" | sed 's/CHAT_ID=/  Chat ID  : /'
    echo ""
    read -p "Do you want to update configuration? (y/n): " update
    if [[ ! "$update" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Configuration unchanged.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}How to get Bot Token and Chat ID:${NC}"
echo ""
echo -e "${BLUE}1. Bot Token:${NC}"
echo "   - Open Telegram and search for @BotFather"
echo "   - Send: /newbot"
echo "   - Follow instructions to create your bot"
echo "   - Copy the token provided"
echo ""
echo -e "${BLUE}2. Chat ID:${NC}"
echo "   - Open Telegram and search for @userinfobot"
echo "   - Send: /start"
echo "   - Copy your ID number"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

# Get Bot Token
read -p "Enter Bot Token: " bot_token
if [ -z "$bot_token" ]; then
    echo -e "${RED}Bot Token cannot be empty!${NC}"
    exit 1
fi

# Get Chat ID
read -p "Enter Chat ID: " chat_id
if [ -z "$chat_id" ]; then
    echo -e "${RED}Chat ID cannot be empty!${NC}"
    exit 1
fi

# Create config directory if not exists
mkdir -p /var/lib/xray-iplimit

# Save configuration
cat > "$TELEGRAM_CONFIG" << EOF
# Telegram Bot Configuration
# Generated: $(date)
BOT_TOKEN=$bot_token
CHAT_ID=$chat_id
EOF

chmod 600 "$TELEGRAM_CONFIG"

echo ""
echo -e "${GREEN}✓ Configuration saved successfully!${NC}"
echo ""

# Test telegram connection
echo -e "${YELLOW}Testing Telegram connection...${NC}"
response=$(curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
    -d chat_id="${chat_id}" \
    -d text="✅ Telegram Bot Connected Successfully!

VPS: $(hostname)
IP: $(curl -s ipinfo.io/ip)
Time: $(date)

Bot is now ready to send notifications.")

if echo "$response" | grep -q '"ok":true'; then
    echo -e "${GREEN}✓ Test message sent successfully!${NC}"
    echo -e "${GREEN}  Check your Telegram for confirmation.${NC}"
else
    echo -e "${RED}✗ Failed to send test message.${NC}"
    echo -e "${YELLOW}  Please check your Bot Token and Chat ID.${NC}"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Telegram Bot Features:${NC}"
echo "  • IP limit violation alerts"
echo "  • Quota exceeded notifications"
echo "  • Account expiry warnings"
echo "  • System status updates"
echo "  • Backup notifications"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""
read -p "Press Enter to continue..."
