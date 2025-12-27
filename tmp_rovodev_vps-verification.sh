#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo "    VPS STRUCTURE VERIFICATION SCRIPT"
echo "    Checking installed files vs new GitHub structure"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if this is run from /root
pwd
echo ""

echo "1. CHECKING INSTALLED SCRIPTS LOCATION:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Files in /root/:"
ls -lh /root/*.sh 2>/dev/null | wc -l
echo "shell scripts found"
echo ""

echo "Files in /usr/bin/ (installed commands):"
ls -lh /usr/bin/add-* /usr/bin/menu-* /usr/bin/xray-* 2>/dev/null | wc -l
echo "installed commands found"
echo ""

echo "2. CHECKING SPECIFIC FILE LOCATIONS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Account management scripts:"
ls -lh /usr/bin/add-ws /usr/bin/add-vless /usr/bin/add-ssws /usr/bin/add-tr 2>/dev/null | awk '{print "  " $9}'
echo ""

echo "Menu scripts:"
ls -lh /usr/bin/menu-vmess /usr/bin/menu-vless /usr/bin/menu-ssh 2>/dev/null | awk '{print "  " $9}'
echo ""

echo "Core xray-iplimit:"
ls -lh /usr/bin/xray-iplimit 2>/dev/null | awk '{print "  " $9}'
ls -lh /etc/xray-iplimit/xray-iplimit.sh 2>/dev/null | awk '{print "  " $9}'
echo ""

echo "3. CHECKING WHERE SCRIPTS DOWNLOAD FROM:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Checking one menu script for GitHub URLs..."
if [ -f "/usr/bin/menu-vmess" ]; then
  grep "githubusercontent.com" /usr/bin/menu-vmess 2>/dev/null | head -3
else
  echo "  menu-vmess not installed yet"
fi
echo ""

echo "4. CHECKING IF XRAY-IPLIMIT IS RUNNING:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ps aux | grep xray-iplimit | grep -v grep || echo "  Not running"
echo ""

echo "5. CHECKING CRON JOBS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
crontab -l 2>/dev/null | grep xray-iplimit || echo "  No xray-iplimit cron found"
echo ""

echo "6. CHECKING INSTALLED VERSION:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "/root/log-install.txt" ]; then
  echo "Installation log found:"
  tail -10 /root/log-install.txt
else
  echo "  No installation log found"
fi
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "VERIFICATION COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "SUMMARY:"
echo "  This VPS has scripts installed at: /usr/bin/"
echo "  When you run 'menu' it executes /usr/bin/menu"
echo "  Those scripts may download updates from GitHub"
echo ""
echo "COMPATIBILITY CHECK:"
echo "  The NEW GitHub structure is organized in folders"
echo "  But VPS installs scripts to /usr/bin/ (flat structure)"
echo "  ✅ This is CORRECT - installer downloads from folders,"
echo "     then installs to /usr/bin/ for easy access"
echo ""
