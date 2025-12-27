# 🚀 XRAY IP Limiter - Quick Start Guide

## 📦 Step 1: Upload to VPS

```bash
# Upload all files
scp xray-iplimit.sh menu-xray-iplimit.sh install-xray-iplimit.sh root@YOUR_VPS_IP:/root/
```

## ⚙️ Step 2: Install

```bash
# SSH to VPS
ssh root@YOUR_VPS_IP

# Run installer
cd /root
chmod +x install-xray-iplimit.sh
./install-xray-iplimit.sh
```

Follow prompts:
- Select cron interval: **[2] Every 5 minutes** (recommended)
- Import config: **[2] No, start fresh**
- Enable sync: **[1] Yes** (if multi-VPS) or **[2] No** (single VPS)

## 🎯 Step 3: Set User Limits

```bash
# Example: john max 2 IPs, lock 60 minutes if violated
xray-iplimit set john 2 60

# Example: VIP user max 5 IPs, lock 15 minutes
xray-iplimit set vipuser 5 15

# Check status
xray-iplimit status
```

## ✅ Step 4: Test

```bash
# Manual lock test
xray-iplimit lock john

# Try to connect with john's account
# Should FAIL ✓

# Unlock
xray-iplimit unlock john

# Try to connect again
# Should SUCCESS ✓
```

## 🔄 Step 5: Multi-VPS Sync (Optional)

**On local machine:**

```bash
# Make sync script executable
chmod +x sync-config.sh

# First run - creates config file
./sync-config.sh

# Edit VPS list
nano ~/.xray-iplimit-sync.conf

# Add your VPS:
# vps1:202.10.38.129:22:password1
# vps2:192.168.1.100:22:password2

# Run sync manager
./sync-config.sh

# Menu:
# [1] Push Config to All VPS
# [7] Sync Status
```

## 📊 Daily Usage

```bash
# Interactive menu
menu-xray-iplimit

# Or commands:
xray-iplimit status          # Check status
xray-iplimit list            # List all users
xray-iplimit lock baduser    # Lock manually
tail -f /var/log/xray/iplimit.log  # Monitor logs
```

## 🆘 Troubleshooting

**Auto-unlock not working?**
```bash
# Check cron
cat /etc/cron.d/xray-iplimit
service cron status

# Manual run
xray-iplimit monitor
```

**User still can connect after lock?**
```bash
# Check if locked in config
grep 'username' /etc/xray/config.json | grep '#LOCKED'

# Re-lock
xray-iplimit unlock username
xray-iplimit lock username
```

## 📋 Common Commands

```bash
xray-iplimit set USER MAX_IP LOCK_MIN   # Set limit
xray-iplimit lock USER                  # Lock user
xray-iplimit unlock USER                # Unlock user
xray-iplimit status                     # Show status
xray-iplimit list                       # List users
xray-iplimit monitor                    # Run monitor
menu-xray-iplimit                       # Interactive menu
```

## ✨ That's it!

Your XRAY IP Limiter is now running and will:
- ✅ Monitor user connections every 5 minutes
- ✅ Auto-lock users who exceed IP limits
- ✅ Auto-unlock after timeout expires
- ✅ Keep detailed logs
- ✅ Auto-backup configs
- ✅ Sync across multiple VPS (if configured)

---

**Need help?** Check `README-XRAY-IPLIMIT.md` for detailed documentation.
