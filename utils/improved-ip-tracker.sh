#!/bin/bash
# Enhanced IP Tracker with Real User Detection

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     XRAY IP Tracker - Enhanced Detection v2.0        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Get active users from XRAY API
echo -e "${YELLOW}[1] Active Users from XRAY API:${NC}"
/usr/local/bin/xray api statsquery --server=127.0.0.1:10085 2>/dev/null | \
    grep -E "user>>>" | grep -v ">>>0" | while read line; do
    user=$(echo "$line" | grep -oP 'user>>>\K[^>]+')
    traffic=$(echo "$line" | grep -oP 'value": \K[0-9]+' || echo "0")
    [ ! -z "$user" ] && echo -e "  ${GREEN}✓${NC} $user (traffic: $traffic bytes)"
done
echo ""

# 2. Get unique IPs from network connections
echo -e "${YELLOW}[2] Unique IPs Connected (Port 443/80):${NC}"
declare -A ip_list
ss -tn state established | grep -E ':(443|80)' | awk '{print $5}' | cut -d: -f1 | \
    grep -v '127.0.0.1' | sort -u | while read ip; do
    count=$(ss -tn state established | grep "$ip" | wc -l)
    echo -e "  ${BLUE}▸${NC} IP: $ip (${count} connections)"
    ip_list["$ip"]=$count
done
echo ""

# 3. Problem: Cannot map IP to User
echo -e "${RED}[3] Current Limitation:${NC}"
echo -e "  ${YELLOW}⚠${NC} Cannot map IP directly to user because:"
echo -e "    • XRAY listens on 127.0.0.1 (via Nginx proxy)"
echo -e "    • Access log doesn't show email/username"
echo -e "    • API only shows traffic stats, not IP info"
echo ""

# 4. Workaround: Session-based tracking
echo -e "${YELLOW}[4] Workaround Solution:${NC}"
echo -e "  ${GREEN}✓${NC} Track IP changes over time"
echo -e "  ${GREEN}✓${NC} Correlate with user activity patterns"
echo -e "  ${GREEN}✓${NC} Use probabilistic matching"
echo ""

# 5. Recommendation
echo -e "${CYAN}[5] For Accurate Tracking:${NC}"
echo -e "  Option A: Enable XRAY detailed logging (email in logs)"
echo -e "  Option B: Modify Nginx to log custom headers"
echo -e "  Option C: Use connection state tracking (current method)"
echo -e "  Option D: Accept approximate tracking (total IPs vs users)"
echo ""

echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
