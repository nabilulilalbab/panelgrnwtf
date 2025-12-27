#!/bin/bash

# =========================================
# Trial Account Cleanup - Auto Delete Expired
# Run via cron: 0 * * * * /usr/bin/trial-cleanup
# =========================================

# Load helper functions
source /usr/local/bin/trial-helpers.sh 2>/dev/null || {
    # Fallback definitions if helper not available
    log_trial_deletion() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] DELETED: $1 trial - $2 - Reason: $3" >> /var/log/trials/trial.log
    }
}

# Initialize log
mkdir -p /var/log/trials
LOG_FILE="/var/log/trials/trial-cleanup.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Trial Cleanup Started ===" >> "$LOG_FILE"

# Get current timestamp
current_time=$(date +%s)
deleted_count=0
error_count=0

# =========================================
# Delete expired SSH trials
# =========================================
delete_ssh_trial() {
    local username=$1
    local config_file="/var/lib/trials/ssh/${username}.conf"
    
    # Delete SSH user
    if getent passwd "$username" > /dev/null 2>&1; then
        userdel "$username" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleted SSH user: $username" >> "$LOG_FILE"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to delete SSH user: $username" >> "$LOG_FILE"
            ((error_count++))
            return 1
        fi
    fi
    
    # Delete config file
    rm -f "$config_file"
    
    # Log to main trial log
    log_trial_deletion "ssh" "$username" "Expired"
    
    ((deleted_count++))
    return 0
}

# =========================================
# Delete expired XRAY trials (VMess/VLess/Trojan)
# =========================================
delete_xray_trial() {
    local username=$1
    local type=$2  # vmess, vless, trojan
    local config_file="/var/lib/trials/${type}/${username}.conf"
    
    case $type in
        vmess)
            # Delete both WS and gRPC sections
            sed -i "/^#vms $username/,/^},{/d" /etc/xray/config.json 2>> "$LOG_FILE"
            sed -i "/^#vmsg $username/,/^},{/d" /etc/xray/config.json 2>> "$LOG_FILE"
            rm -f /etc/xray/vmess-${username}-*.json 2>> "$LOG_FILE"
            ;;
        vless)
            sed -i "/^#vls $username/,/^},{/d" /etc/xray/config.json 2>> "$LOG_FILE"
            sed -i "/^#vlsg $username/,/^},{/d" /etc/xray/config.json 2>> "$LOG_FILE"
            rm -f /etc/xray/vless-${username}-*.json 2>> "$LOG_FILE"
            ;;
        trojan)
            sed -i "/^#tr $username/,/^},{/d" /etc/xray/config.json 2>> "$LOG_FILE"
            sed -i "/^#trg $username/,/^},{/d" /etc/xray/config.json 2>> "$LOG_FILE"
            rm -f /etc/xray/trojan-${username}-*.json 2>> "$LOG_FILE"
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleted $type trial: $username" >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to delete $type trial: $username" >> "$LOG_FILE"
        ((error_count++))
        return 1
    fi
    
    # Delete config file
    rm -f "$config_file"
    
    # Log to main trial log
    log_trial_deletion "$type" "$username" "Expired"
    
    ((deleted_count++))
    
    # Mark that XRAY needs restart
    touch /tmp/xray_needs_restart
    
    return 0
}

# =========================================
# Main cleanup process
# =========================================

# Check SSH trials
if [ -d "/var/lib/trials/ssh" ]; then
    for conf in /var/lib/trials/ssh/*.conf; do
        [ -f "$conf" ] || continue
        
        # Source config file
        source "$conf"
        
        # Check if expired
        expiry_time=$(date -d "$EXPIRES" +%s 2>/dev/null)
        if [ -z "$expiry_time" ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Invalid expiry date in $conf" >> "$LOG_FILE"
            continue
        fi
        
        if [ $current_time -gt $expiry_time ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Expiry detected: SSH trial $USERNAME (expired: $EXPIRES)" >> "$LOG_FILE"
            delete_ssh_trial "$USERNAME"
        fi
    done
fi

# Check XRAY trials (VMess, VLess, Trojan)
for type in vmess vless trojan; do
    if [ -d "/var/lib/trials/${type}" ]; then
        for conf in /var/lib/trials/${type}/*.conf; do
            [ -f "$conf" ] || continue
            
            # Source config file
            source "$conf"
            
            # Check if expired
            expiry_time=$(date -d "$EXPIRES" +%s 2>/dev/null)
            if [ -z "$expiry_time" ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Invalid expiry date in $conf" >> "$LOG_FILE"
                continue
            fi
            
            if [ $current_time -gt $expiry_time ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Expiry detected: $type trial $USERNAME (expired: $EXPIRES)" >> "$LOG_FILE"
                delete_xray_trial "$USERNAME" "$type"
            fi
        done
    fi
done

# Restart XRAY if needed
if [ -f "/tmp/xray_needs_restart" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restarting XRAY service..." >> "$LOG_FILE"
    systemctl restart xray.service >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] XRAY service restarted successfully" >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to restart XRAY service" >> "$LOG_FILE"
    fi
    rm -f /tmp/xray_needs_restart
fi

# Summary
echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Trial Cleanup Completed ===" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleted: $deleted_count trial(s)" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Errors: $error_count" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Keep log file under control (keep last 1000 lines)
if [ -f "$LOG_FILE" ]; then
    tail -n 1000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

exit 0
