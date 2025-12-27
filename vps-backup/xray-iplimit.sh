#!/bin/bash

# XRAY IP Limiter v5.0 - Simple Multiply with Cloudflare Tolerance
# Default multiplier: 3x (auto-tolerance for Cloudflare/Load Balancer)

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

DEFAULT_LOCK_MINUTES=60
DEFAULT_BASE_LIMIT=1
CLOUDFLARE_MULTIPLIER=3  # Fixed 3x multiplier for Cloudflare tolerance

mkdir -p "$LOCK_DIR" "$BACKUP_DIR"
touch "$LOCK_FILE" "$LIMIT_CONFIG" "$LOG_FILE"

log_msg() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
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
    log_msg "${GREEN}[START]${NC} XRAY IP Limit Monitor v5.0 (Cloudflare Tolerance: ${CLOUDFLARE_MULTIPLIER}x)"
    
    # Check expired locks
    local current_time=$(date +%s)
    if [ -s "$LOCK_FILE" ]; then
        while IFS=: read -r user lock_until; do
            if [ "$current_time" -ge "$lock_until" ]; then
                unblock_user_in_xray "$user"
                sed -i "/^${user}:/d" "$LOCK_FILE"
                log_msg "${GREEN}[AUTO-UNLOCK]${NC} User '${user}' automatically unlocked"
            fi
        done < "$LOCK_FILE"
    fi
    
    # Track and enforce - Fixed: avoid subshell issue
    local temp_track="/tmp/xray_iplimit_track_$$.txt"
    track_user_ips > "$temp_track"
    
    # Get unique users
    cat "$temp_track" | cut -d: -f1 | sort -u | while read email; do
        is_user_locked "$email" && continue
        
        # Count unique IPs for this user
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
    echo -e "${GREEN}║    XRAY IP Limiter Status v5.0        ║${NC}"
    echo -e "${GREEN}║  (Cloudflare Tolerance: 3x)           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}ℹ  Multiplier: ${CLOUDFLARE_MULTIPLIER}x (auto Cloudflare tolerance)${NC}\n"
    
    echo -e "${YELLOW}📋 User Limits Configuration:${NC}"
    if [ -s "$LIMIT_CONFIG" ]; then
        cat "$LIMIT_CONFIG" | while IFS=: read -r user base lock_min; do
            local actual=$((base * CLOUDFLARE_MULTIPLIER))
            echo -e "  ${BLUE}▸${NC} ${user}: ${GREEN}${base}${NC} device → ${CYAN}${actual}${NC} IPs max, Lock ${RED}${lock_min}${NC}min"
        done
    else
        echo -e "  ${YELLOW}No custom limits set${NC}"
        echo -e "  ${YELLOW}Default: ${DEFAULT_BASE_LIMIT} device → $((DEFAULT_BASE_LIMIT * CLOUDFLARE_MULTIPLIER)) IPs${NC}"
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
    *)
        echo -e "${GREEN}XRAY IP Limiter v5.0${NC} - Cloudflare Tolerance (3x multiplier)"
        echo ""
        echo "Usage: $0 {monitor|set|lock|unlock|status|track}"
        echo ""
        echo "Commands:"
        echo "  ${BLUE}monitor${NC}                - Run monitoring and enforcement"
        echo "  ${BLUE}set${NC} USER BASE MINS     - Set base limit (auto x3 for tolerance)"
        echo "  ${BLUE}lock${NC} USER              - Manually lock user"
        echo "  ${BLUE}unlock${NC} USER            - Manually unlock user"
        echo "  ${BLUE}status${NC}                 - Show current status"
        echo "  ${BLUE}track${NC}                  - Show real-time IP tracking"
        echo ""
        echo "Examples:"
        echo "  $0 set john 1 60       # John: 1 device (max 3 IPs), lock 60 min"
        echo "  $0 set vip 2 30        # VIP: 2 devices (max 6 IPs), lock 30 min"
        exit 1
        ;;
esac

exit 0
