# 🔄 AUTO BACKUP CONFIGURATION

**VPS:** 202.10.38.129  
**Feature:** Telegram Auto Backup (Every 10 Minutes)  
**Status:** ⚠️ NEEDS TELEGRAM BOT SETUP

---

## 📊 CURRENT STATUS

### Backup Script:
```
✅ Installed: /usr/bin/backup-telegram-auto (4.2KB)
✅ Executable: Yes
✅ Location: Correct
```

### Cron Job:
```
✅ Added: */10 * * * * /usr/bin/backup-telegram-auto
✅ Frequency: Every 10 minutes
✅ Service: Cron active
```

### Telegram Config:
```
❌ NOT CONFIGURED YET
⚠️  Required: Bot Token & Chat ID
```

---

## 🚨 WHAT NEEDS TO BE DONE

The backup script is installed and cron is configured, BUT it requires Telegram bot credentials to work.

### Required Information:
1. **Bot Token** - From @BotFather
2. **Chat ID** - From @userinfobot

### Where to Configure:
Two options available:

**Option 1: New Method (Recommended)**
```bash
telegram-setup
# Or from menu: [58] TELEGRAM BOT SETUP
```
This creates: `/var/lib/xray-iplimit/telegram.conf`

**Option 2: Old Method**
```bash
menu-bckp-telegram
```
This creates: `/root/botapi.conf`

---

## 📦 WHAT GETS BACKED UP

Every 10 minutes, the following data is backed up to Telegram:

### XRAY Configuration:
- `/etc/xray/config.json` - Main XRAY config
- `/etc/xray/domain` - Domain settings
- `/etc/xray/*.crt` - SSL certificates
- `/etc/xray/*.key` - SSL keys

### User Accounts:
- `/etc/vmess/` - VMess accounts
- `/etc/vless/` - VLess accounts
- `/etc/trojan/` - Trojan accounts
- `/etc/ssh/` - SSH accounts

### IP Limit & Quota:
- `/var/lib/xray-iplimit/user_limits.conf`
- `/var/lib/xray-iplimit/user_quota.conf`
- `/var/lib/xray-iplimit/locked_users.txt`
- `/var/lib/xray-iplimit/ip_sessions.txt`

### System Config:
- Crontab entries
- Network settings
- Installation log

---

## 🛠️ SETUP INSTRUCTIONS

### Step 1: Get Bot Token
1. Open Telegram
2. Search for [@BotFather](https://t.me/botfather)
3. Send: `/newbot`
4. Follow instructions
5. Copy the **token** provided

### Step 2: Get Chat ID
1. Open Telegram
2. Search for [@userinfobot](https://t.me/userinfobot)
3. Send: `/start`
4. Copy your **ID number**

### Step 3: Configure on VPS
```bash
# Access VPS
ssh root@202.10.38.129

# Run setup (choose one method)
telegram-setup          # New method
# OR
menu-bckp-telegram      # Old method

# Enter your Bot Token
# Enter your Chat ID
```

### Step 4: Test
After configuration, test manually:
```bash
/usr/bin/backup-telegram-auto
```

You should receive a backup file in your Telegram chat!

---

## 📋 BACKUP SCHEDULE

```
Frequency: Every 10 minutes
Format: backup-{domain}_{date}_{time}.zip
Size: ~50KB - 500KB (depends on accounts)
Delivery: Telegram Bot Message + File
Retention: Unlimited (in Telegram)
```

### Example Schedule:
```
18:00 - Backup sent
18:10 - Backup sent
18:20 - Backup sent
18:30 - Backup sent
...every 10 minutes
```

---

## 🔍 VERIFICATION

### Check Cron is Running:
```bash
crontab -l | grep backup
```

### Check Last Backup:
```bash
ls -lht /root/backup/ | head -5
```

### Check Cron Logs:
```bash
grep backup-telegram-auto /var/log/syslog | tail -10
```

### Manual Test:
```bash
/usr/bin/backup-telegram-auto
```

---

## 📊 CRON JOBS SUMMARY (Updated)

| Time | Job | Status |
|------|-----|--------|
| */2 min | IP Limiter | ✅ Running |
| */10 min | **Auto Backup** | ⚠️ **Needs Telegram** |
| Every 6h | Quota Monitor | ✅ Running |
| Daily 00:00 | Delete Expired | ✅ Running |
| Weekly Sun | Clear Logs | ✅ Running |
| Daily | SSL Renewal | ✅ Running |

**Total Active:** 6 cron jobs  
**Fully Working:** 5  
**Needs Config:** 1 (Auto Backup - needs Telegram bot)

---

## ⚠️ IMPORTANT NOTES

1. **Backup will NOT work** until Telegram bot is configured
2. **Cron will run** every 10 minutes but fail silently without config
3. **No error messages** in console (redirected to /dev/null)
4. **Check logs** if backups not received: `/var/log/xray/backup-telegram-cron.log`

---

## ✅ NEXT STEPS

1. **Configure Telegram Bot** (Required!)
   ```bash
   telegram-setup
   # Or from menu: [58]
   ```

2. **Test Backup** manually
   ```bash
   /usr/bin/backup-telegram-auto
   ```

3. **Check Telegram** for backup file

4. **Wait 10 minutes** and verify auto-backup works

---

## 🎯 COMPLETION CHECKLIST

- [x] Backup script installed
- [x] Cron job configured (every 10 min)
- [ ] **Telegram bot configured** ← DO THIS!
- [ ] Manual test successful
- [ ] Auto backup verified

---

**Status:** ⚠️ 83% Complete (Needs Telegram Setup)  
**Report:** December 27, 2025  
**By:** Rovo Dev
