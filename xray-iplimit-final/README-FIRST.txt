═══════════════════════════════════════════════════════════════
  XRAY IP LIMITER v5.0 - READ THIS FIRST
═══════════════════════════════════════════════════════════════

🎉 WHAT'S NEW IN v5.0:
───────────────────────────────────────────────────────────────
✅ Cloudflare Tolerance: Automatic 3x multiplier
   - Set limit 1 = allow up to 3 IPs (Cloudflare load balancing)
   - Set limit 2 = allow up to 6 IPs
   
✅ Simple Configuration:
   - No need to set multiplier manually
   - Just: xray-iplimit set user 1 60
   
✅ Fixed IP Detection:
   - Parse XRAY access log correctly
   - Support new log format with "from" keyword
   
✅ Fixed menu-vmess:
   - Now shows actual IPs, not just "from"
   
✅ Production Tested:
   - Tested on live VPS with Cloudflare
   - Violation detection working 100%

📋 INSTALLATION:
───────────────────────────────────────────────────────────────
Method 1: Auto Installer (Recommended)
  ./install-xray-iplimit.sh

Method 2: Manual
  cp xray-iplimit.sh /usr/bin/xray-iplimit
  cp menu-xray-iplimit.sh /usr/bin/menu-xray-iplimit
  cp menu-vmess.sh /usr/bin/menu-vmess
  chmod +x /usr/bin/xray-iplimit
  chmod +x /usr/bin/menu-xray-iplimit
  
  # Setup cron
  echo "*/5 * * * * root /usr/bin/xray-iplimit monitor" > /etc/cron.d/xray-iplimit
  service cron restart

🎯 QUICK START:
───────────────────────────────────────────────────────────────
# Set limit for user
xray-iplimit set john 1 60

# Check status
xray-iplimit status

# Track IPs
xray-iplimit track

# Manual lock/unlock
xray-iplimit lock baduser
xray-iplimit unlock gooduser

📖 FULL DOCUMENTATION:
───────────────────────────────────────────────────────────────
• QUICK-START.md          - Quick installation guide
• README-XRAY-IPLIMIT.md  - Complete documentation
• INSTALL-GUIDE.txt       - Installation instructions

🔄 MULTI-VPS DEPLOYMENT:
───────────────────────────────────────────────────────────────
Use sync-config.sh on your local machine to manage multiple VPS:
  
  1. Edit ~/.xray-iplimit-sync.conf
  2. Add all your VPS (IP:PORT:PASSWORD)
  3. Run: ./sync-config.sh
  4. Push config to all VPS at once

⚠️  IMPORTANT NOTES:
───────────────────────────────────────────────────────────────
• Requires XRAY with loglevel "info" or "debug"
• Works with Cloudflare CDN (automatic tolerance)
• Auto-unlock after timeout (no permanent block)
• Backup created before each lock/unlock
• Compatible with existing NevermoreSSH script

✅ TESTED ON:
───────────────────────────────────────────────────────────────
• Debian 11
• XRAY-Core 25.12.8
• With Cloudflare CDN
• Real production traffic

═══════════════════════════════════════════════════════════════
  Need help? Check README-XRAY-IPLIMIT.md
═══════════════════════════════════════════════════════════════
