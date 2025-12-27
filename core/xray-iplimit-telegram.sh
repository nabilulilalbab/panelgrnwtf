#!/bin/bash

# XRAY IP Limiter v5.1 - With Telegram Notification
# Cloudflare Tolerance (3x multiplier) + Telegram Alert

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

XRAY_CONFIG="/etc/xray/config.json"
XRAY_LOG="/var/log/xray/access.log"
LOCK_DIR="/var/lib/xray-iplimit"
LOCK_FILE="${LOCK_DIR}/locked_users.txt"
BACKUP_DIR="${LOCK_DIR}/backups"
LIMIT_CONFIG="${LOCK_DIR}/user_limits.conf"
LOG_FILE="/var/log/xray/iplimit.log"
TELEGRAM_CONFIG="${LOCK_DIR}/telegram.conf"

DEFAULT_LOCK_MINUTES=60
DEFAULT_BASE_LIMIT=1
CLOUDFLARE_MULTIPLIER=3

mkdir -p "$LOCK_DIR" "$BACKUP_DIR"
touch "$LOCK_FILE" "$LIMIT_CONFIG" "$LOG_FILE" "$TELEGRAM_CONFIG"

log_msg() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Telegram notification function
send_telegram() {
    local message="$1"
    
    if [ ! -f "$TELEGRAM_CONFIG" ]; then
        return 0
    fi
    
    local BOT_TOKEN=$(grep "^BOT_TOKEN=" "$TELEGRAM_CONFIG" | cut -d= -f2)
    local CHAT_ID=$(grep "^CHAT_ID=" "$TELEGRAM_CONFIG" | cut -d= -f2)
    
    if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
        return 0
    fi
    
    local SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    local HOSTNAME=$(hostname)
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    local full_message="🚨 *XRAY IP Limiter Alert*
    
${message}

📍 *Server Info:*
• Host: \`${HOSTNAME}\`
• IP: \`${SERVER_IP}\`
• Time: \`${TIMESTAMP}\`

_Powered by XRAY IP Limiter v5.1_"
    
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=${full_message}" \
        -d "parse_mode=Markdown" > /dev/null 2>&1
}

setup_telegram() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   Telegram Notification Setup         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}\n"
    
    echo -e "${YELLOW}How to get Bot Token & Chat ID:${NC}"
    echo "1. Open Telegram, search: @BotFather"
    echo "2. Send: /newbot"
    echo "3. Follow instructions, get Bot Token"
    echo "4. Search your bot, send /start"
    echo "5. Open: https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates"
    echo "6. Find 'chat':{'id': YOUR_CHAT_ID}"
    echo ""
    
    read -p "Enter Bot Token: " bot_token
    read -p "Enter Chat ID: " chat_id
    
    if [ -z "$bot_token" ] || [ -z "$chat_id" ]; then
        echo -e "${RED}✗${NC} Bot Token or Chat ID empty!"
        return 1
    fi
    
    # Save config
    echo "BOT_TOKEN=$bot_token" > "$TELEGRAM_CONFIG"
    echo "CHAT_ID=$chat_id" >> "$TELEGRAM_CONFIG"
    
    # Test notification
    echo -e "\n${YELLOW}Sending test notification...${NC}"
    send_telegram "✅ Telegram notification configured successfully!

This is a test message from XRAY IP Limiter."
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Telegram notification configured!"
        echo -e "${GREEN}✓${NC} Check your Telegram for test message"
        log_msg "[TELEGRAM] Notification configured: Chat ID ${chat_id}"
    else
        echo -e "${RED}✗${NC} Failed to send test message"
        echo -e "${YELLOW}Please check your Bot Token and Chat ID${NC}"
        return 1
    fi
}

get_user_base_limit() {
    local user="$1"
    local limit=$(grep "^${user}:" "$LIMIT_CONFIG" | cut -d: -f2)
    [ -z "$limit" ] && echo "$DEFAULT_BASE_LIMIT" || echo "$limit"
}

get_user_actual_limit() {
    local user="$1"
    local base=$(get_user_base_limit "$user")
    echo $((base * CLOUDFLARE_MULTIPLIER))
}

get_lock_duration() {
    local user="$1"
    local duration=$(grep "^${user}:" "$LIMIT_CONFIG" | cut -d: -f3)
    [ -z "$duration" ] && echo "$DEFAULT_LOCK_MINUTES" || echo "$duration"
}

is_user_locked() {
    local user="$1"
    local current_time=$(date +%s)
    
    if grep -q "^${user}:" "$LOCK_FILE"; then
        local lock_until=$(grep "^${user}:" "$LOCK_FILE" | cut -d: -f2)
        if [ "$current_time" -lt "$lock_until" ]; then
            return 0
        else
            sed -i "/^${user}:/d" "$LOCK_FILE"
        fi
    fi
    return 1
}

lock_user() {
    local user="$1"
    local lock_minutes=$(get_lock_duration "$user")
    local lock_until=$(($(date +%s) + (lock_minutes * 60)))
    
    sed -i "/^${user}:/d" "$LOCK_FILE"
    echo "${user}:${lock_until}" >> "$LOCK_FILE"
    
    log_msg "${RED}[LOCKED]${NC} User '${user}' locked for ${lock_minutes} minutes (until $(date -d @$lock_until '+%H:%M:%S'))"
}

block_user_in_xray() {
    local user="$1"
    
    if grep -q "#LOCKED_.*${user}" "$XRAY_CONFIG"; then
        return 0
    fi
    
    local backup_file="${BACKUP_DIR}/config_$(date +%Y%m%d_%H%M%S).json"
    cp "$XRAY_CONFIG" "$backup_file"
    
    local uuid=$(grep "email.*${user}" "$XRAY_CONFIG" | grep -oP '(?<="id": ")[^"]+' | head -1)
    if [ -z "$uuid" ]; then
        uuid=$(grep -B 2 "email.*${user}" "$XRAY_CONFIG" | grep "password" | grep -oP '(?<="password": ")[^"]+' | head -1)
    fi
    
    if [ -z "$uuid" ]; then
        log_msg "${RED}[ERROR]${NC} Cannot find UUID for user '${user}'"
        return 1
    fi
    
    log_msg "${YELLOW}[BLOCKING]${NC} User: ${user}"
    
    local temp_file="/tmp/xray_config_$$.json"
    cp "$XRAY_CONFIG" "$temp_file"
    
    sed -i "/.*${user}.*/s/^[^#]/#LOCKED_&/" "$temp_file"
    sed -i "/.*${uuid}.*/s/^[^#]/#LOCKED_&/" "$temp_file"
    
    mv "$temp_file" "$XRAY_CONFIG"
    systemctl restart xray > /dev/null 2>&1
    sleep 2
    
    if systemctl is-active --quiet xray; then
        log_msg "${GREEN}[SUCCESS]${NC} User '${user}' blocked"
        return 0
    else
        log_msg "${RED}[CRITICAL]${NC} XRAY failed! Restoring backup..."
        cp "$backup_file" "$XRAY_CONFIG"
        systemctl restart xray
        return 1
    fi
}

unblock_user_in_xray() {
    local user="$1"
    
    local backup_file="${BACKUP_DIR}/config_$(date +%Y%m%d_%H%M%S).json"
    cp "$XRAY_CONFIG" "$backup_file"
    
    sed -i "s/^#LOCKED_\+\(.*${user}.*\)/\1/g" "$XRAY_CONFIG"
    
    local uuid=$(grep "email.*${user}" "$XRAY_CONFIG" | grep -oP '(?<="id": ")[^"]+' | head -1)
    if [ -z "$uuid" ]; then
        uuid=$(grep -B 2 "email.*${user}" "$XRAY_CONFIG" | grep "password" | grep -oP '(?<="password": ")[^"]+' | head -1)
    fi
    
    if [ ! -z "$uuid" ]; then
        sed -i "s/^#LOCKED_\+\(.*${uuid}.*\)/\1/g" "$XRAY_CONFIG"
    fi
    
    systemctl restart xray > /dev/null 2>&1
    sleep 2
    
    if systemctl is-active --quiet xray; then
        log_msg "${GREEN}[UNBLOCKED]${NC} User '${user}' unblocked"
        return 0
    else
        log_msg "${RED}[CRITICAL]${NC} XRAY failed! Restoring..."
        cp "$backup_file" "$XRAY_CONFIG"
        systemctl restart xray
        return 1
    fi
}

track_user_ips() {
    tail -1000 "$XRAY_LOG" 2>/dev/null | grep "email:" | while read line; do
        local ip=$(echo "$line" | grep -oP 'from \K[0-9.]+')
        local email=$(echo "$line" | grep -oP 'email: \K\S+')
        
        if [ ! -z "$ip" ] && [ ! -z "$email" ]; then
            echo "${email}:${ip}"
        fi
    done | sort -u
}

monitor_and_enforce() {
    log_msg "${GREEN}[START]${NC} XRAY IP Limit Monitor v5.1 (with Telegram)"
    
    # Check expired locks
    local current_time=$(date +%s)
    if [ -s "$LOCK_FILE" ]; then
        while IFS=: read -r user lock_until; do
            if [ "$current_time" -ge "$lock_until" ]; then
                unblock_user_in_xray "$user"
                sed -i "/^${user}:/d" "$LOCK_FILE"
                log_msg "${GREEN}[AUTO-UNLOCK]${NC} User '${user}' automatically unlocked"
                
                # Send Telegram notification
                send_telegram "✅ *User Unlocked*

User: \`${user}\`
Status: Auto-unlocked after timeout
Action: User can connect again"
            fi
        done < "$LOCK_FILE"
    fi
    
    # Track and enforce
    local temp_track="/tmp/xray_iplimit_track_$$.txt"
    track_user_ips > "$temp_track"
    
    cat "$temp_track" | cut -d: -f1 | sort -u | while read email; do
        is_user_locked "$email" && continue
        
        local ip_count=$(grep "^${email}:" "$temp_track" | cut -d: -f2 | sort -u | wc -l)
        local ip_list=$(grep "^${email}:" "$temp_track" | cut -d: -f2 | sort -u | tr '\n' ' ')
        
        local base_limit=$(get_user_base_limit "$email")
        local actual_limit=$(get_user_actual_limit "$email")
        
        log_msg "${BLUE}[CHECK]${NC} User '$email': ${ip_count} IPs detected (base: ${base_limit}, limit: ${actual_limit})"
        
        if [ "$ip_count" -gt "$actual_limit" ]; then
            log_msg "${RED}[VIOLATION]${NC} User '$email' exceeded limit! (${ip_count} > ${actual_limit})"
            log_msg "${YELLOW}[IPs]${NC} ${ip_list}"
            
            lock_user "$email"
            block_user_in_xray "$email"
            
            # Send Telegram notification
            local lock_mins=$(get_lock_duration "$email")
            send_telegram "⚠️ *User Locked - IP Limit Exceeded*

User: \`${email}\`
Detected IPs: *${ip_count}* IPs
Limit: *${actual_limit}* IPs (base: ${base_limit})
Lock Duration: *${lock_mins}* minutes

IP List:
\`${ip_list}\`

Status: ❌ User blocked in XRAY config"
        fi
    done
    
    rm -f "$temp_track"
    log_msg "${BLUE}[INFO]${NC} Monitoring cycle completed"
}

set_user_limit() {
    local user="$1"
    local base_limit="$2"
    local lock_minutes="$3"
    
    sed -i "/^${user}:/d" "$LIMIT_CONFIG"
    echo "${user}:${base_limit}:${lock_minutes}" >> "$LIMIT_CONFIG"
    
    local actual_limit=$((base_limit * CLOUDFLARE_MULTIPLIER))
    
    echo -e "${GREEN}✓${NC} Limit set for user '${user}':"
    echo -e "  Base limit: ${CYAN}${base_limit}${NC} device(s)"
    echo -e "  Actual limit: ${CYAN}${actual_limit}${NC} IPs (${base_limit} x ${CLOUDFLARE_MULTIPLIER})"
    echo -e "  Lock duration: ${RED}${lock_minutes}${NC} minutes"
    
    log_msg "[CONFIG] Set limit for '${user}': base=${base_limit}, actual=${actual_limit}, lock=${lock_minutes}min"
}

show_status() {
    echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    XRAY IP Limiter Status v5.1        ║${NC}"
    echo -e "${GREEN}║  (Cloudflare + Telegram Alerts)       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    
    # Check Telegram config
    if [ -f "$TELEGRAM_CONFIG" ] && [ -s "$TELEGRAM_CONFIG" ]; then
        echo -e "${GREEN}📱 Telegram: Enabled ✓${NC}\n"
    else
        echo -e "${YELLOW}📱 Telegram: Not configured (use: telegram-setup)${NC}\n"
    fi
    
    echo -e "${CYAN}ℹ  Multiplier: ${CLOUDFLARE_MULTIPLIER}x (auto Cloudflare tolerance)${NC}\n"
    
    echo -e "${YELLOW}📋 User Limits Configuration:${NC}"
    if [ -s "$LIMIT_CONFIG" ]; then
        cat "$LIMIT_CONFIG" | while IFS=: read -r user base lock_min; do
            local actual=$((base * CLOUDFLARE_MULTIPLIER))
            echo -e "  ${BLUE}▸${NC} ${user}: ${GREEN}${base}${NC} device → ${CYAN}${actual}${NC} IPs max, Lock ${RED}${lock_min}${NC}min"
        done
    else
        echo -e "  ${YELLOW}No custom limits set${NC}"
    fi
    
    echo -e "\n${YELLOW}🔒 Currently Locked Users:${NC}"
    if [ -s "$LOCK_FILE" ]; then
        cat "$LOCK_FILE" | while IFS=: read -r user lock_until; do
            local remaining=$((lock_until - $(date +%s)))
            if [ $remaining -gt 0 ]; then
                local mins=$((remaining / 60))
                local secs=$((remaining % 60))
                echo -e "  ${RED}▸${NC} ${user}: Unlocks in ${RED}${mins}m ${secs}s${NC}"
            fi
        done
    else
        echo -e "  ${GREEN}✓ No users locked${NC}"
    fi
    
    echo -e "\n${YELLOW}👥 Current IP Tracking:${NC}"
    track_user_ips | awk -F: '{arr[$1]=arr[$1]" "$2} END {for(u in arr){split(arr[u],ips," "); printf "  ▸ %s: %d IPs\n", u, length(ips)}}' | head -10
    
    echo ""
}

track_command() {
    echo -e "${CYAN}Real-time IP Tracking:${NC}\n"
    track_user_ips | awk -F: '{arr[$1]=arr[$1]" "$2} END {for(u in arr) print u ":" arr[u]}' | while IFS=: read user ips; do
        local ip_array=($ips)
        local count=${#ip_array[@]}
        local base=$(get_user_base_limit "$user")
        local actual=$((base * CLOUDFLARE_MULTIPLIER))
        
        echo -e "${BLUE}$user${NC} (${count}/${actual} IPs):"
        for ip in $ips; do
            echo "  - $ip"
        done
        echo ""
    done
}

case "$1" in
    monitor) monitor_and_enforce ;;
    set)
        [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] && echo "Usage: $0 set <username> <base_limit> <lock_minutes>" && exit 1
        set_user_limit "$2" "$3" "$4"
        ;;
    unlock)
        [ -z "$2" ] && echo "Usage: $0 unlock <username>" && exit 1
        unblock_user_in_xray "$2"
        sed -i "/^${2}:/d" "$LOCK_FILE"
        echo -e "${GREEN}✓${NC} User '${2}' unlocked"
        ;;
    lock)
        [ -z "$2" ] && echo "Usage: $0 lock <username>" && exit 1
        lock_user "$2"
        block_user_in_xray "$2"
        echo -e "${RED}✓${NC} User '${2}' locked"
        ;;
    status) show_status ;;
    track) track_command ;;
    telegram-setup) setup_telegram ;;
    telegram-test)
        send_telegram "🔔 Test notification from XRAY IP Limiter

This is a manual test message."
        echo -e "${GREEN}✓${NC} Test notification sent!"
        ;;
    *)
        echo -e "${GREEN}XRAY IP Limiter v5.1${NC} - Cloudflare Tolerance + Telegram"
        echo ""
        echo "Usage: $0 {monitor|set|lock|unlock|status|track|telegram-setup|telegram-test}"
        echo ""
        echo "Commands:"
        echo "  ${BLUE}monitor${NC}                - Run monitoring and enforcement"
        echo "  ${BLUE}set${NC} USER BASE MINS     - Set base limit (auto x3 for tolerance)"
        echo "  ${BLUE}lock${NC} USER              - Manually lock user"
        echo "  ${BLUE}unlock${NC} USER            - Manually unlock user"
        echo "  ${BLUE}status${NC}                 - Show current status"
        echo "  ${BLUE}track${NC}                  - Show real-time IP tracking"
        echo "  ${BLUE}telegram-setup${NC}         - Configure Telegram notifications"
        echo "  ${BLUE}telegram-test${NC}          - Send test notification"
        echo ""
        echo "Examples:"
        echo "  $0 set john 1 60       # John: 1 device (max 3 IPs), lock 60 min"
        echo "  $0 telegram-setup      # Setup Telegram bot"
        exit 1
        ;;
esac

exit 0
