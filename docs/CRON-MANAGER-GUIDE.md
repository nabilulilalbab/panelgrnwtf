# 🔧 CRON JOBS MANAGER - USER GUIDE

**Feature:** Auto-validation and setup for all cron jobs  
**Menu:** Option [59] - CRON JOBS MANAGER  
**Command:** `cron-manager`  
**Status:** ✅ Fully Automated

---

## 🎯 WHAT IT DOES

The Cron Jobs Manager automatically:

1. **Scans** all required cron jobs
2. **Validates** which ones are active
3. **Adds** missing cron jobs automatically
4. **Checks** Telegram configuration
5. **Reports** status of all jobs

**Zero manual work needed!**

---

## 📋 MANAGED CRON JOBS (7 Total)

| # | Job | Schedule | Auto-Enable |
|---|-----|----------|-------------|
| 1 | IP Limit Monitor | */2 minutes | ✅ Yes |
| 2 | Quota Monitor | Every 6 hours | ✅ Yes |
| 3 | Delete Expired | Daily 00:00 | ✅ Yes |
| 4 | Clear Logs | Weekly Sunday | ✅ Yes |
| 5 | Auto Backup | */10 minutes | ⚠️ If Telegram configured |
| 6 | SSL Renewal | Daily | ℹ️ Preserved (set by acme.sh) |
| 7 | SSL Backup | Every 3 days | ℹ️ Preserved |

---

## 🚀 HOW TO USE

### Method 1: From Main Menu
```bash
menu
# Select [59] CRON JOBS MANAGER
```

### Method 2: Direct Command
```bash
cron-manager
```

### First Run Output:
```
╔════════════════════════════════════════════════════════╗
║         CRON JOBS MANAGER & AUTO SETUP              ║
╚════════════════════════════════════════════════════════╝

✓ Cron service is active

════════════════════════════════════════════════════════
Scanning and configuring cron jobs...

  ✓ IP Limit Monitor (every 2 minutes) - Already active
  ✓ Quota Monitor (every 6 hours) - Already active
  ✓ Delete Expired Accounts (daily at midnight) - Already active
  ✓ Clear Logs (weekly on Sunday) - Already active

Checking Auto Backup configuration...
  ✓ Auto Backup to Telegram (every 10 minutes) - Already active
  ✓ SSL Certificate Renewal - Already active

════════════════════════════════════════════════════════
Summary:
  ✓ Already active: 7 cron jobs

════════════════════════════════════════════════════════
Current Cron Jobs:
  • 56 13 * * * "/root/.acme.sh"/acme.sh --cron
  • 15 03 */3 * * /usr/local/bin/ssl_renew.sh
  • */2 * * * * /usr/bin/xray-iplimit monitor
  • 0 */6 * * * /usr/bin/xray-iplimit quota-monitor
  • 0 0 * * * /usr/bin/xp
  • 0 2 * * 0 /usr/bin/clearlog
  • */10 * * * * /usr/bin/backup-telegram-auto
```

---

## 🔍 INTERACTIVE OPTIONS

After scanning, you get these options:

```
Additional Options:
  [1] View cron logs (last 20 executions)
  [2] Test IP Limiter manually
  [3] Test Auto Backup manually
  [4] Configure Telegram Bot
  [5] Remove all cron jobs
  [0] Exit
```

### Option 1: View Logs
Shows recent cron executions from `/var/log/syslog`

### Option 2: Test IP Limiter
Runs IP limit check manually to see live output

### Option 3: Test Auto Backup
Triggers backup immediately (needs Telegram configured)

### Option 4: Configure Telegram
Redirects to `telegram-setup` for bot configuration

### Option 5: Remove All
Removes custom cron jobs (keeps SSL renewal)
- Creates backup first
- Safe operation

---

## 💡 SMART FEATURES

### 1. **Duplicate Prevention**
Won't add cron if already exists
```
✓ IP Limit Monitor - Already active
```

### 2. **Auto-Detection**
Detects new cron entries
```
+ Quota Monitor - ADDED
```

### 3. **Telegram Validation**
Checks if Telegram configured before enabling backup
```
⚠ Auto Backup - Telegram not configured
  Run 'telegram-setup' or menu option [58]
```

### 4. **Service Check**
Ensures cron daemon is running
```
✓ Cron service is active
```

### 5. **Safe Removal**
Backs up crontab before removing
```
Backup saved to: /root/crontab.backup.20251227-182030
```

---

## ⚙️ TECHNICAL DETAILS

### What Happens Behind the Scenes:

1. **Service Check:**
   ```bash
   systemctl is-active cron
   # If not: start and enable
   ```

2. **Scan Existing:**
   ```bash
   crontab -l | grep "pattern"
   ```

3. **Add If Missing:**
   ```bash
   (crontab -l; echo "new entry") | crontab -
   ```

4. **Validate Telegram:**
   ```bash
   # Check: /var/lib/xray-iplimit/telegram.conf
   # Or: /root/botapi.conf
   ```

5. **Report Status:**
   - Green ✓ = Already active
   - Yellow + = Newly added
   - Yellow ⚠ = Needs config

---

## 📊 USE CASES

### Use Case 1: Fresh Installation
**Scenario:** Just installed VPS
**Action:** Run `cron-manager`
**Result:** All 7 cron jobs auto-configured

### Use Case 2: Missing Cron
**Scenario:** Accidentally deleted cron entry
**Action:** Run `cron-manager`
**Result:** Missing entry restored automatically

### Use Case 3: After Telegram Setup
**Scenario:** Just configured Telegram bot
**Action:** Run `cron-manager`
**Result:** Auto backup enabled automatically

### Use Case 4: Validation Check
**Scenario:** Want to verify all crons active
**Action:** Run `cron-manager`
**Result:** Status report of all 7 jobs

---

## 🛠️ TROUBLESHOOTING

### Issue: "Telegram not configured"
**Solution:**
```bash
telegram-setup
# Then run cron-manager again
```

### Issue: "Cron service not running"
**Auto-Fix:** Script starts it automatically
```
Starting cron service...
✓ Cron service started
```

### Issue: Cron not executing
**Check:**
```bash
systemctl status cron
grep CRON /var/log/syslog | tail -20
```

### Issue: Want to start fresh
**Solution:**
```bash
cron-manager
# Select option [5] Remove all
# Then run again to re-add
```

---

## 📝 BEST PRACTICES

1. **Run After Installation**
   ```bash
   # After setup.sh completes
   cron-manager
   ```

2. **Run After Telegram Setup**
   ```bash
   telegram-setup
   cron-manager  # Enable auto backup
   ```

3. **Regular Validation** (optional)
   ```bash
   # Once a month
   cron-manager
   ```

4. **Before Troubleshooting**
   ```bash
   # If features not working
   cron-manager  # Fix missing crons
   ```

---

## ✅ BENEFITS

| Before | After |
|--------|-------|
| Manual crontab editing | One-click automation |
| Risk of typos | Validated entries |
| No status visibility | Full status report |
| Complex commands | Simple menu |
| Missing crons | Auto-detected & fixed |

---

## 🎯 MENU INTEGRATION

```
Main Menu Structure:
[55] XRAY-CORE MENU
[56] XRAY IP LIMITER
[57] QUOTA MANAGEMENT
[58] TELEGRAM BOT SETUP
[59] CRON JOBS MANAGER      ← NEW!
[66] INSTALL BBRPLUS
[77] SWAPRAM MENU
[88] BACKUP
[99] RESTORE
```

---

## 🎉 SUMMARY

**Cron Jobs Manager makes automation setup:**
- ✅ Automatic (no manual work)
- ✅ Safe (checks before adding)
- ✅ Smart (detects Telegram config)
- ✅ Complete (all 7 jobs managed)
- ✅ User-friendly (interactive menu)

**One command does it all!**

---

**Created:** December 27, 2025  
**Status:** ✅ Production Ready  
**Guide by:** Rovo Dev
