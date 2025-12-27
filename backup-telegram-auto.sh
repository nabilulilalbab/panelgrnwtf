#!/bin/bash

# =========================================
# Auto Backup to Telegram - Every 10 Minutes
# Include: Xray Config + IP Limit + Quota Data
# =========================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get VPS Info
IP=$(curl -sS ipv4.icanhazip.com)
date=$(date +"%Y-%m-%d_%H-%M-%S")
domain=$(cat /etc/xray/domain 2>/dev/null || echo "no-domain")

# Load Telegram Config
if [ -f "/root/botapi.conf" ]; then
    source /root/botapi.conf
    token=$toket
    chat_id=$chat_idc
elif [ -f "/var/lib/xray-iplimit/telegram.conf" ]; then
    source /var/lib/xray-iplimit/telegram.conf
    token=$BOT_TOKEN
    chat_id=$CHAT_ID
else
    echo -e "${RED}[ERROR]${NC} Telegram config not found!"
    echo "Please run: menu-bckp-telegram and setup bot first"
    exit 1
fi

# Check token & chat_id
if [ -z "$token" ] || [ -z "$chat_id" ]; then
    echo -e "${RED}[ERROR]${NC} Bot token or chat_id not configured!"
    exit 1
fi

# Create backup directory
mkdir -p /root/backup-auto
cd /root

# Copy files to backup
echo -e "${GREEN}[INFO]${NC} Creating backup..."

# Essential files
cp -r /etc/xray /root/backup-auto/xray &> /dev/null
cp -r /home/vps/public_html /root/backup-auto/public_html &> /dev/null
cp -r /etc/cron.d /root/backup-auto/cron.d &> /dev/null
cp /etc/crontab /root/backup-auto/crontab &> /dev/null

# System users
cp /etc/passwd /root/backup-auto/passwd &> /dev/null
cp /etc/group /root/backup-auto/group &> /dev/null
cp /etc/shadow /root/backup-auto/shadow &> /dev/null
cp /etc/gshadow /root/backup-auto/gshadow &> /dev/null

# IP Limit & Quota Data (IMPORTANT!)
cp -r /var/lib/xray-iplimit /root/backup-auto/xray-iplimit &> /dev/null

# Create zip file
backup_file="$IP-$date-auto.zip"
zip -r /root/$backup_file backup-auto > /dev/null 2>&1

# Get file size
file_size=$(du -h /root/$backup_file | awk '{print $1}')

# Count users - Only count unique users (websocket section only to avoid duplicates)
# Each user appears 2x: once in websocket section (#vms, #vls, #tr) and once in grpc section (#vmsg, #vlsg, #trg)
# We only count websocket section to get unique user count
vmess_count=$(grep -c "#vms " /etc/xray/config.json 2>/dev/null)
vless_count=$(grep -c "#vls " /etc/xray/config.json 2>/dev/null)
trojan_count=$(grep -c "#tr " /etc/xray/config.json 2>/dev/null)

# Handle empty values
[ -z "$vmess_count" ] && vmess_count=0
[ -z "$vless_count" ] && vless_count=0
[ -z "$trojan_count" ] && trojan_count=0

total_users=$((vmess_count + vless_count + trojan_count))

# Count IP limits & quotas
iplimit_count=$(wc -l < /var/lib/xray-iplimit/user_limits.conf 2>/dev/null || echo "0")
quota_count=$(grep -c "^[^#]" /var/lib/xray-iplimit/user_quota.conf 2>/dev/null || echo "0")

# Send to Telegram
echo -e "${GREEN}[INFO]${NC} Sending to Telegram..."

caption="🔄 AUTO BACKUP - Every 10 Minutes

📡 VPS Info:
• IP: $IP
• Domain: $domain
• Date: $(date +"%Y-%m-%d %H:%M:%S")
• File: $backup_file
• Size: $file_size

👥 Total Users: $total_users
• Vmess: $vmess_count
• Vless: $vless_count
• Trojan: $trojan_count

🔒 IP Limit & Quota:
• IP Limits: $iplimit_count users
• Quotas: $quota_count users

✅ Backup includes:
✓ Xray config
✓ IP Limit data
✓ Quota data & usage
✓ Locked users
✓ Cron jobs
✓ Web files

📦 Auto-backup by xray-iplimit system"

curl -F chat_id="$chat_id" \
     -F document=@"/root/$backup_file" \
     -F caption="$caption" \
     https://api.telegram.org/bot$token/sendDocument &> /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} Backup sent to Telegram!"
    
    # Save to log
    echo "[$(date)] Backup successful: $backup_file ($file_size)" >> /var/log/xray/backup-telegram.log
else
    echo -e "${RED}[ERROR]${NC} Failed to send backup!"
    
    # Save error to log
    echo "[$(date)] Backup failed: $backup_file" >> /var/log/xray/backup-telegram.log
fi

# Cleanup
rm -rf /root/backup-auto
rm -f /root/$backup_file

# Keep only last 50 lines in log
tail -50 /var/log/xray/backup-telegram.log > /var/log/xray/backup-telegram.log.tmp 2>/dev/null
mv /var/log/xray/backup-telegram.log.tmp /var/log/xray/backup-telegram.log 2>/dev/null

exit 0
