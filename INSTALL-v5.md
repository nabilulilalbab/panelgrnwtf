# XRAY IP Limiter v5.0 - Installation Guide

## 🎉 What's New in v5.0

✅ **Cloudflare Tolerance (3x multiplier)** - Auto-handle load balancing
✅ **Accurate IP Detection** - Parse XRAY log format with email
✅ **Fixed menu-vmess** - Show real IPs in user login check
✅ **Simple Configuration** - Just set base limit, auto x3
✅ **Production Tested** - Verified working on live VPS

---

## 📦 Package Contents

```
xray-iplimit-v5-final.tar.gz (16KB)
├── xray-iplimit.sh              # Main script v5.0
├── menu-xray-iplimit.sh         # Management menu
├── menu-vmess.sh                # Fixed menu-vmess (IP detection)
├── install-xray-iplimit.sh      # Auto installer
├── sync-config.sh               # Multi-VPS sync
├── xray-iplimit.cron            # Cron job template
├── README-XRAY-IPLIMIT.md       # Full documentation
├── QUICK-START.md               # Quick start guide
├── CHANGELOG.md                 # Version history
├── example-sync-config.conf     # Sync config example
├── example-user-limits.conf     # User limits example
└── install-guide.txt            # Installation guide
```

---

## 🚀 Quick Installation

### **Method 1: Auto Installer (Recommended)**

```bash
# 1. Upload package to VPS
scp xray-iplimit-v5-final.tar.gz root@YOUR_VPS_IP:/root/

# 2. Extract and install
ssh root@YOUR_VPS_IP
cd /root
tar -xzf xray-iplimit-v5-final.tar.gz
chmod +x install-xray-iplimit.sh
./install-xray-iplimit.sh

# Follow prompts:
# - Cron interval: [2] Every 5 minutes (recommended)
# - Import config: [2] No, start fresh
# - Multi-VPS sync: [2] No (setup later if needed)
```

### **Method 2: Manual Installation**

```bash
# Extract package
tar -xzf xray-iplimit-v5-final.tar.gz

# Install scripts
cp xray-iplimit.sh /usr/bin/xray-iplimit
cp menu-xray-iplimit.sh /usr/bin/menu-xray-iplimit
cp menu-vmess.sh /usr/bin/menu-vmess
chmod +x /usr/bin/xray-iplimit
chmod +x /usr/bin/menu-xray-iplimit
chmod +x /usr/bin/menu-vmess

# Create directories
mkdir -p /var/lib/xray-iplimit/backups
mkdir -p /var/log/xray
touch /var/lib/xray-iplimit/locked_users.txt
touch /var/lib/xray-iplimit/user_limits.conf
touch /var/log/xray/iplimit.log

# Setup cron (every 5 minutes)
cp xray-iplimit.cron /etc/cron.d/xray-iplimit
service cron restart
```

---

## ⚙️ Configuration

### **Set User Limits**

```bash
# Format: xray-iplimit set <username> <base_limit> <lock_minutes>
# Base limit will be auto multiplied by 3 for Cloudflare tolerance

# Example 1: Regular user (1 device, max 3 IPs)
xray-iplimit set john 1 60

# Example 2: VIP user (2 devices, max 6 IPs)
xray-iplimit set vip 2 30

# Example 3: Trial user (1 device, strict 3 IPs, long lock)
xray-iplimit set trial 1 120
```

### **Understanding Limits**

```
Base Limit = Number of devices you allow
Actual Limit = Base × 3 (auto Cloudflare tolerance)

Examples:
  Base 1 → Max 3 IPs   (1 device + Cloudflare)
  Base 2 → Max 6 IPs   (2 devices + Cloudflare)
  Base 3 → Max 9 IPs   (3 devices + Cloudflare)
```

---

## 🧪 Testing

### **1. Check Status**

```bash
xray-iplimit status
```

Output:
```
╔════════════════════════════════════════╗
║    XRAY IP Limiter Status v5.0        ║
║  (Cloudflare Tolerance: 3x)           ║
╚════════════════════════════════════════╝

ℹ  Multiplier: 3x (auto Cloudflare tolerance)

📋 User Limits Configuration:
  ▸ john: 1 device → 3 IPs max, Lock 60min

🔒 Currently Locked Users:
  ✓ No users locked

👥 Current IP Tracking:
  ▸ john: 2 IPs
```

### **2. Track Real-Time**

```bash
xray-iplimit track
```

Output:
```
john (2/3 IPs):
  - 140.213.167.128
  - 140.213.175.97
```

### **3. Manual Test Lock**

```bash
# Lock user
xray-iplimit lock testuser

# Try to connect with testuser
# Should FAIL ✓

# Unlock user
xray-iplimit unlock testuser

# Try to connect again
# Should SUCCESS ✓
```

---

## 🔄 Multi-VPS Deployment

### **Setup Sync Manager (On Local Machine)**

```bash
# Make sync manager executable
chmod +x sync-config.sh

# First run creates config
./sync-config.sh

# Edit VPS list
nano ~/.xray-iplimit-sync.conf

# Add your VPS:
vps1:202.10.38.129:22:password1
vps2:192.168.1.100:22:password2
vps3:103.50.20.30:22:password3
```

### **Sync Operations**

```bash
./sync-config.sh

Menu:
[1] Push Config to All VPS    # Deploy same limits to all
[2] Pull Config from VPS       # Get config from master
[6] Test Connection            # Verify SSH access
[7] Sync Status                # Check all VPS status
```

---

## 📊 Daily Operations

### **Common Commands**

```bash
# Check status
xray-iplimit status

# View tracking
xray-iplimit track

# Manual monitoring
xray-iplimit monitor

# Lock user
xray-iplimit lock baduser

# Unlock user
xray-iplimit unlock gooduser

# Interactive menu
menu-xray-iplimit

# Check user login (in menu-vmess)
menu-vmess → [4] Check User XRAY
```

### **View Logs**

```bash
# Main log
tail -f /var/log/xray/iplimit.log

# Cron log
tail -f /var/log/xray/iplimit-cron.log

# XRAY access log
tail -f /var/log/xray/access.log | grep "email:"
```

---

## 🔧 Troubleshooting

### **Auto-monitor not working**

```bash
# Check cron job
cat /etc/cron.d/xray-iplimit
service cron status

# Check cron log
tail -f /var/log/xray/iplimit-cron.log

# Manual run
xray-iplimit monitor
```

### **User can still connect after lock**

```bash
# Verify user is locked in config
grep 'username' /etc/xray/config.json | grep '#LOCKED'

# Check XRAY status
systemctl status xray

# Re-lock
xray-iplimit unlock username
xray-iplimit lock username
```

### **IP not showing in menu-vmess**

```bash
# Check XRAY log format
tail -20 /var/log/xray/access.log | grep "email:"

# Should see: from IP:port accepted ... email: username

# If not, check loglevel in config
grep loglevel /etc/xray/config.json
# Should be "info" or "debug"
```

---

## 🎯 Production Deployment Checklist

- [ ] Package uploaded to all VPS
- [ ] Installer run on all VPS
- [ ] User limits configured
- [ ] Cron job active (check: `crontab -l`)
- [ ] Test lock/unlock working
- [ ] Multi-VPS sync configured (if needed)
- [ ] Monitoring logs working
- [ ] Backup original scripts saved

---

## 📞 Support

For issues or questions:
1. Check logs: `tail -100 /var/log/xray/iplimit.log`
2. Test manually: `xray-iplimit monitor`
3. Review documentation: `README-XRAY-IPLIMIT.md`

---

## 📄 Version

- **Version:** 5.0 Final
- **Release Date:** 2025-12-26
- **Tested On:** Debian 11, Ubuntu 20.04, XRAY 25.12.8
- **Package:** xray-iplimit-v5-final.tar.gz (16KB)

---

## ✨ Key Features

✅ Cloudflare tolerance (3x auto)
✅ Accurate IP detection via XRAY log
✅ Per-user custom limits
✅ Auto-lock with timeout
✅ Auto-unlock after expiry
✅ Multi-VPS sync support
✅ Fixed menu-vmess IP display
✅ Real-time tracking
✅ Full logging
✅ Auto-backup before changes
✅ Production tested & verified

**Ready for production use!** 🚀
