#!/bin/bash

# ========================================================================
# SCRIPT DEPLOYMENT OTOMATIS - QUOTA SYSTEM KE VPS
# ========================================================================
# Usage: ./tmp_rovodev_deploy_quota_system.sh <VPS_IP> <PASSWORD>
# Example: ./tmp_rovodev_deploy_quota_system.sh 202.10.38.129 'Gqzz$#q31COwf1'
# ========================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <VPS_IP> <PASSWORD>"
    echo "Example: $0 202.10.38.129 'YourPassword'"
    exit 1
fi

VPS_IP="$1"
VPS_PASS="$2"
VPS_USER="root"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  QUOTA SYSTEM DEPLOYMENT${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Target VPS: ${GREEN}${VPS_IP}${NC}"
echo -e ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo -e "${YELLOW}Installing sshpass...${NC}"
    sudo apt-get update && sudo apt-get install -y sshpass || yum install -y sshpass
fi

# Function to execute command on VPS
exec_vps() {
    sshpass -p "${VPS_PASS}" ssh -o StrictHostKeyChecking=no ${VPS_USER}@${VPS_IP} "$1"
}

# Function to copy file to VPS
copy_to_vps() {
    local src="$1"
    local dst="$2"
    sshpass -p "${VPS_PASS}" scp -o StrictHostKeyChecking=no "$src" ${VPS_USER}@${VPS_IP}:"$dst"
}

echo -e "${BLUE}[1/8]${NC} Checking VPS connection..."
if exec_vps "echo 'Connected'" | grep -q "Connected"; then
    echo -e "${GREEN}✓ Connection successful${NC}"
else
    echo -e "${RED}✗ Failed to connect to VPS${NC}"
    exit 1
fi

echo -e ""
echo -e "${BLUE}[2/8]${NC} Creating necessary directories..."
exec_vps "mkdir -p /var/log/xray /etc/xray-iplimit"
echo -e "${GREEN}✓ Directories created${NC}"

echo -e ""
echo -e "${BLUE}[3/8]${NC} Uploading core files..."

# Array of files to upload
declare -A FILES=(
    ["xray-iplimit.sh"]="/tmp/xray-iplimit.sh"
    ["menu-quota.sh"]="/tmp/menu-quota.sh"
    ["menu-xray-iplimit.sh"]="/tmp/menu-xray-iplimit.sh"
    ["menu-vmess.sh"]="/tmp/menu-vmess.sh"
    ["menu-vless.sh"]="/tmp/menu-vless.sh"
    ["menu-trojan.sh"]="/tmp/menu-trojan.sh"
    ["menu-ssh.sh"]="/tmp/menu-ssh.sh"
    ["install-xray-iplimit-complete.sh"]="/tmp/install-xray-iplimit-complete.sh"
)

for src in "${!FILES[@]}"; do
    dst="${FILES[$src]}"
    if [ -f "$src" ]; then
        echo -e "  Uploading ${CYAN}$src${NC} → ${YELLOW}$dst${NC}"
        copy_to_vps "$src" "$dst"
    else
        echo -e "  ${RED}✗ File not found: $src${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All files uploaded${NC}"

echo -e ""
echo -e "${BLUE}[4/8]${NC} Running installer on VPS..."
exec_vps "cd /tmp && chmod +x install-xray-iplimit-complete.sh && echo '2\n2\n2' | bash install-xray-iplimit-complete.sh"
echo -e "${GREEN}✓ Installation completed${NC}"

echo -e ""
echo -e "${BLUE}[5/8]${NC} Cleaning up temporary files..."
exec_vps "rm -f /tmp/xray-iplimit.sh /tmp/menu-*.sh /tmp/install-xray-iplimit-complete.sh"
echo -e "${GREEN}✓ Cleanup done${NC}"

echo -e ""
echo -e "${BLUE}[6/8]${NC} Verifying installation..."
VERIFY=$(exec_vps "ls /usr/bin/xray-iplimit /usr/bin/menu-quota /usr/bin/menu-xray-iplimit 2>/dev/null | wc -l")
if [ "$VERIFY" -ge 3 ]; then
    echo -e "${GREEN}✓ All core files verified${NC}"
    echo -e "  ${CYAN}→${NC} xray-iplimit: $(exec_vps 'ls -lh /usr/bin/xray-iplimit | awk "{print \$5}"')"
    echo -e "  ${CYAN}→${NC} menu-quota: $(exec_vps 'ls -lh /usr/bin/menu-quota | awk "{print \$5}"')"
    echo -e "  ${CYAN}→${NC} menu-xray-iplimit: $(exec_vps 'ls -lh /usr/bin/menu-xray-iplimit | awk "{print \$5}"')"
else
    echo -e "${RED}✗ Verification failed (found: $VERIFY/3 files)${NC}"
    exit 1
fi

echo -e ""
echo -e "${BLUE}[7/8]${NC} Comparing checksums..."
LOCAL_MD5=$(md5sum menu-quota.sh | awk '{print $1}')
REMOTE_MD5=$(exec_vps "md5sum /usr/bin/menu-quota 2>/dev/null | awk '{print \$1}'")

if [ "$LOCAL_MD5" = "$REMOTE_MD5" ]; then
    echo -e "${GREEN}✓ menu-quota.sh: MD5 match ($LOCAL_MD5)${NC}"
else
    echo -e "${RED}✗ MD5 mismatch!${NC}"
    echo -e "  Local:  $LOCAL_MD5"
    echo -e "  Remote: $REMOTE_MD5"
fi

LOCAL_MD5=$(md5sum xray-iplimit.sh | awk '{print $1}')
REMOTE_MD5=$(exec_vps "md5sum /usr/bin/xray-iplimit 2>/dev/null | awk '{print \$1}'")

if [ "$LOCAL_MD5" = "$REMOTE_MD5" ]; then
    echo -e "${GREEN}✓ xray-iplimit.sh: MD5 match ($LOCAL_MD5)${NC}"
else
    echo -e "${RED}✗ MD5 mismatch!${NC}"
    echo -e "  Local:  $LOCAL_MD5"
    echo -e "  Remote: $REMOTE_MD5"
fi

echo -e ""
echo -e "${BLUE}[8/8]${NC} Testing commands..."
echo -e "  Testing xray-iplimit..."
if exec_vps "/usr/bin/xray-iplimit quota-status 2>&1" | grep -q "Quota\|User\|No users"; then
    echo -e "${GREEN}  ✓ quota-status command working${NC}"
else
    echo -e "${YELLOW}  ⚠ quota-status may need configuration${NC}"
fi

echo -e "  Testing menu-quota..."
if exec_vps "which menu-quota" | grep -q "/usr/bin/menu-quota"; then
    echo -e "${GREEN}  ✓ menu-quota accessible${NC}"
else
    echo -e "${RED}  ✗ menu-quota not found${NC}"
fi

echo -e "  Checking cron setup..."
if exec_vps "test -f /etc/cron.d/xray-iplimit && echo 'exists'" | grep -q "exists"; then
    echo -e "${GREEN}  ✓ Auto-monitor cron configured${NC}"
    exec_vps "cat /etc/cron.d/xray-iplimit | grep -v '^#' | grep -v '^$'" | while read line; do
        echo -e "    ${CYAN}→${NC} $line"
    done
else
    echo -e "${YELLOW}  ⚠ Cron not configured${NC}"
fi

echo -e ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✅ DEPLOYMENT COMPLETED!${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. SSH to VPS: ${CYAN}ssh root@${VPS_IP}${NC}"
echo -e "2. Run menu: ${CYAN}menu-quota${NC}"
echo -e "3. Setup auto-monitor: Choose option ${CYAN}[9]${NC}"
echo -e "4. Test quota system: ${CYAN}xray-iplimit quota-status${NC}"
echo -e ""
echo -e "${GREEN}VPS ${VPS_IP} is ready! 🚀${NC}"
echo -e ""
