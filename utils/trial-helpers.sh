#!/bin/bash

# =========================================
# Trial Account Helper Functions
# Shared functions for all trial scripts
# =========================================

# Generate random username: trial_xxxxx
generate_trial_username() {
    local random_suffix=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
    echo "trial_${random_suffix}"
}

# Generate random password: 12 alphanumeric chars
generate_trial_password() {
    cat /dev/urandom | tr -dc 'A-Za-z0-9' | fold -w 12 | head -n 1
}

# Generate UUID for XRAY accounts
generate_uuid() {
    cat /proc/sys/kernel/random/uuid
}

# Calculate expiry date from hours
# Usage: calculate_expiry 6  (for 6 hours)
calculate_expiry() {
    local hours=$1
    date -d "+${hours} hours" "+%Y-%m-%d"
}

# Calculate expiry datetime (with time)
# Usage: calculate_expiry_datetime 6
calculate_expiry_datetime() {
    local hours=$1
    date -d "+${hours} hours" "+%Y-%m-%d %H:%M:%S"
}

# Check if username already exists (SSH)
check_ssh_user_exists() {
    local username=$1
    if getent passwd "$username" > /dev/null 2>&1; then
        return 0  # exists
    else
        return 1  # doesn't exist
    fi
}

# Check if username already exists (XRAY)
check_xray_user_exists() {
    local username=$1
    if grep -q "^#vms $username\|^#vls $username\|^#tr $username" /etc/xray/config.json 2>/dev/null; then
        return 0  # exists
    else
        return 1  # doesn't exist
    fi
}

# Generate unique trial username (check collision)
generate_unique_trial_username() {
    local username
    local max_attempts=10
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        username=$(generate_trial_username)
        
        # Check SSH
        if check_ssh_user_exists "$username"; then
            ((attempt++))
            continue
        fi
        
        # Check XRAY
        if check_xray_user_exists "$username"; then
            ((attempt++))
            continue
        fi
        
        # Username is unique
        echo "$username"
        return 0
    done
    
    # Failed to generate unique username
    echo ""
    return 1
}

# Create trial storage directory
init_trial_storage() {
    mkdir -p /var/lib/trials/{ssh,vmess,vless,trojan}
    mkdir -p /var/log/trials
}

# Save trial info to config file
save_trial_info() {
    local type=$1      # ssh, vmess, vless, trojan
    local username=$2
    local password=$3
    local uuid=$4      # optional, for XRAY
    local expires=$5
    local duration=$6
    
    local config_file="/var/lib/trials/${type}/${username}.conf"
    
    cat > "$config_file" << EOF
# Trial Account Configuration
USERNAME=$username
PASSWORD=$password
UUID=$uuid
CREATED=$(date "+%Y-%m-%d %H:%M:%S")
EXPIRES=$expires
DURATION=${duration}h
TYPE=$type
STATUS=active
EOF
    
    chmod 600 "$config_file"
}

# Log trial creation
log_trial_creation() {
    local type=$1
    local username=$2
    local duration=$3
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CREATED: $type trial - $username - ${duration}h" >> /var/log/trials/trial.log
}

# Log trial deletion
log_trial_deletion() {
    local type=$1
    local username=$2
    local reason=$3
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DELETED: $type trial - $username - Reason: $reason" >> /var/log/trials/trial.log
}

# Duration selection menu
select_duration() {
    # Check if we're in interactive mode
    if [ -t 0 ]; then
        # Interactive: use /dev/tty
        echo ""
        echo "Select Trial Duration:"
        echo "  [1] 1 Hour"
        echo "  [2] 3 Hours"
        echo "  [3] 6 Hours"
        echo "  [4] 12 Hours"
        echo "  [5] 24 Hours"
        echo "  [6] Custom (enter hours)"
        echo ""
        read -p "Select [1-6]: " duration_choice
    else
        # Non-interactive (piped): read from stdin
        read duration_choice
    fi
    
    case $duration_choice in
        1) echo "1" ;;
        2) echo "3" ;;
        3) echo "6" ;;
        4) echo "12" ;;
        5) echo "24" ;;
        6)
            if [ -t 0 ]; then
                read -p "Enter hours (1-72): " custom_hours
            else
                read custom_hours
            fi
            if [[ "$custom_hours" =~ ^[0-9]+$ ]] && [ "$custom_hours" -ge 1 ] && [ "$custom_hours" -le 72 ]; then
                echo "$custom_hours"
            else
                echo "0"  # Invalid
            fi
            ;;
        *) echo "0" ;;  # Invalid
    esac
}

# Get domain
get_domain() {
    if [ -f "/etc/xray/domain" ]; then
        cat /etc/xray/domain
    elif [ -f "/root/domain" ]; then
        cat /root/domain
    else
        echo "$(curl -s ipinfo.io/ip)"
    fi
}

# Get server IP
get_server_ip() {
    curl -s ipinfo.io/ip
}

# Initialize storage on first run
init_trial_storage
