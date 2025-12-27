# XRAY IP Limiter - Quota Management Implementation Guide

## 📊 Overview

This guide documents the **Quota Management** feature implementation for XRAY IP Limiter v5.1. This feature adds traffic quota monitoring and enforcement capabilities alongside the existing IP limit functionality.

---

## ✨ Features Implemented

### Core Functions (8 Functions)

1. **`query_user_traffic()`** - Query user traffic from XRAY API
2. **`set_quota()`** - Set traffic quota for user (in GB)
3. **`check_quota()`** - Check quota usage for specific user
4. **`disable_user_quota()`** - Disable user when quota exceeded
5. **`enable_user_quota()`** - Re-enable user (remove quota flag)
6. **`monitor_quota()`** - Monitor all users with quota
7. **`show_quota_status()`** - Show quota status for all users
8. **`reset_quota()`** - Reset quota for user

### Commands Added (5 Commands)

```bash
xray-iplimit quota-set <username> <quota_gb>    # Set quota
xray-iplimit quota-check <username>             # Check usage
xray-iplimit quota-status                       # View all quotas
xray-iplimit quota-monitor                      # Run monitoring
xray-iplimit quota-reset <username>             # Reset quota
```

### Menu Integration

Updated `menu-xray-iplimit.sh` with new **QUOTA MANAGEMENT** section:
- **[6]** Set User Quota
- **[7]** Check User Quota
- **[8]** View All Quotas Status
- **[9]** Reset User Quota

---

## 🚀 Quick Start

### 1. Set Quota for User

```bash
# Set 10 GB quota for user "john"
xray-iplimit quota-set john 10
```

**Output:**
```
✓ Quota set for user: john
  Quota: 10 GB
  Initial traffic: 0 bytes
```

### 2. Check User Quota

```bash
# Check quota usage for "john"
xray-iplimit quota-check john
```

**Output:**
```
john
  Quota: 10 GB
  Used: 2.45 GB (24%)
  Status: ✓ OK
```

### 3. View All Quotas

```bash
# View all users quota status
xray-iplimit quota-status
```

**Output:**
```
╔════════════════════════════════════════╗
║      XRAY Quota Status                 ║
╚════════════════════════════════════════╝

  ▸ john
    Quota: 10 GB
    Used:  2.45 GB (24%)
    Status: ✓ OK

  ▸ alice
    Quota: 5 GB
    Used:  4.87 GB (97%)
    Status: ! WARNING
```

### 4. Monitor Quotas

```bash
# Run quota monitoring
xray-iplimit quota-monitor
```

This will:
- Check all users with quota
- Disable users who exceeded quota
- Send Telegram notification
- Log actions

### 5. Reset User Quota

```bash
# Reset quota for user
xray-iplimit quota-reset john
```

This will:
- Re-enable user if disabled
- Reset quota counter (start from current traffic)
- Keep same quota limit

---

## 🔧 Configuration

### Config Files

```bash
# Quota configuration file
/var/lib/xray-iplimit/user_quota.conf

# Format: username:quota_gb:initial_traffic:start_time
john:10:1234567890:1703634000
alice:5:9876543210:1703634000
```

### Log Files

```bash
# Quota monitoring logs
/var/log/xray/quota.log

# Example entries:
[2024-12-26 21:30:15] [QUOTA] Set quota for 'john': 10 GB
[2024-12-26 21:35:20] [QUOTA CHECK] john: 2.45/10 GB
[2024-12-26 21:40:25] [QUOTA EXCEEDED] alice: 5.12/5 GB
```

---

## 🔄 Auto-Monitoring Setup

### Setup Cron Job

```bash
# Option 1: Use menu (recommended)
menu-xray-iplimit.sh
# Select [11] Setup Auto-Monitor
# Choose interval (5/10/15 minutes)

# Option 2: Manual setup
echo "*/10 * * * * root /usr/bin/xray-iplimit quota-monitor >> /var/log/xray/quota-cron.log 2>&1" > /etc/cron.d/xray-quota-monitor
```

### Combined Monitoring

Monitor both IP limits and quotas:

```bash
# Create combined cron job
cat > /etc/cron.d/xray-iplimit-full << 'EOF'
# XRAY IP Limiter + Quota Monitor
*/5 * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1
*/10 * * * * root /usr/bin/xray-iplimit quota-monitor >> /var/log/xray/quota-cron.log 2>&1
EOF
```

---

## 📱 Telegram Integration

### Quota Exceeded Notification

When user exceeds quota, automatic Telegram notification is sent:

```
⚠️ User Quota Exceeded

User: `john`
Quota: 10 GB
Used: 10.23 GB

Action: ❌ User disabled in XRAY
Date: `2024-12-26 21:45:00`
```

### Setup Telegram

```bash
# Configure Telegram bot
xray-iplimit telegram-setup

# Test notification
xray-iplimit telegram-test
```

---

## 🎯 Use Cases

### Use Case 1: Monthly Quota

```bash
# Set 50 GB monthly quota for user
xray-iplimit quota-set user1 50

# At end of month, reset quota
xray-iplimit quota-reset user1
```

### Use Case 2: Trial User

```bash
# Give trial user 5 GB quota
xray-iplimit quota-set trial_user 5

# Monitor automatically
# User will be disabled when quota exceeded
```

### Use Case 3: Fair Usage

```bash
# Set different quotas for different users
xray-iplimit quota-set premium_user 100
xray-iplimit quota-set standard_user 50
xray-iplimit quota-set basic_user 20

# Check all quotas
xray-iplimit quota-status
```

---

## 🔍 How It Works

### 1. Traffic Tracking

- Uses XRAY API stats query to get user traffic
- Tracks uplink + downlink bytes
- Calculates usage from baseline (initial traffic at quota set time)

### 2. Quota Enforcement

When quota exceeded:
1. User entry is commented in XRAY config with `#QUOTA_EXCEEDED_` prefix
2. XRAY service is restarted
3. User cannot connect anymore
4. Telegram notification is sent
5. Action is logged

### 3. Quota Reset

When quota is reset:
1. Remove `#QUOTA_EXCEEDED_` prefix from config
2. Restart XRAY service
3. Update quota config with new baseline (current traffic)
4. User can connect again

---

## 🛠️ Troubleshooting

### Issue: Quota not tracking correctly

**Solution:**
```bash
# Check if XRAY API is accessible
xray api statsquery --server=127.0.0.1:10085 --pattern "user>>>*>>>traffic>>>uplink"

# Check if stats are enabled in XRAY config
grep -A 5 '"stats":' /etc/xray/config.json
```

### Issue: User not disabled when quota exceeded

**Solution:**
```bash
# Check quota config
cat /var/lib/xray-iplimit/user_quota.conf

# Check logs
tail -50 /var/log/xray/quota.log

# Run monitor manually
xray-iplimit quota-monitor
```

### Issue: Quota reset not working

**Solution:**
```bash
# Check if user exists in config
grep "username" /etc/xray/config.json

# Check XRAY service status
systemctl status xray

# Check backup files
ls -la /var/lib/xray-iplimit/backups/
```

---

## 📈 Monitoring & Logs

### Check Quota Usage

```bash
# View all quotas
xray-iplimit quota-status

# Check specific user
xray-iplimit quota-check username

# View logs
tail -f /var/log/xray/quota.log
```

### Log Rotation

```bash
# Setup logrotate for quota logs
cat > /etc/logrotate.d/xray-quota << 'EOF'
/var/log/xray/quota.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF
```

---

## 🔐 Security Considerations

1. **Backup Before Changes**: Always backup XRAY config before disabling users
2. **Test in Staging**: Test quota features in staging environment first
3. **Monitor Logs**: Regularly check logs for errors
4. **Telegram Security**: Keep Telegram bot token secure
5. **File Permissions**: Ensure proper permissions on config files

```bash
chmod 600 /var/lib/xray-iplimit/user_quota.conf
chmod 600 /var/lib/xray-iplimit/telegram.conf
```

---

## 📊 Statistics

### Implementation Stats

- **Functions Added**: 8 quota management functions
- **Commands Added**: 5 new commands
- **Menu Items Added**: 4 quota menu options
- **Files Modified**: 2 (xray-iplimit.sh, menu-xray-iplimit.sh)
- **Lines of Code**: ~260 lines of new code

---

## 🎉 Summary

### ✅ What's Working

- ✓ Set quota for users (in GB)
- ✓ Check quota usage (with percentage)
- ✓ Monitor and enforce quotas automatically
- ✓ Disable users when quota exceeded
- ✓ Reset quota for users
- ✓ Telegram notifications for quota events
- ✓ Menu integration
- ✓ Comprehensive logging

### 🚀 Ready for Production

The quota management feature is fully integrated and ready for production use. All functions have been tested and are working correctly with the existing IP limit functionality.

---

## 📚 Related Documentation

- [README-XRAY-IPLIMIT.md](README-XRAY-IPLIMIT.md) - Main documentation
- [QUICK-START.md](QUICK-START.md) - Quick start guide
- [INSTALL-v5.md](INSTALL-v5.md) - Installation guide

---

**Last Updated:** 2024-12-26  
**Version:** 5.1 + Quota Management  
**Status:** ✅ Production Ready
