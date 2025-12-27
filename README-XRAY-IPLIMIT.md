# XRAY IP Limiter - Multi-VPS Edition

Sistem limitasi IP per user untuk XRAY dengan fitur lock timeout dan sinkronisasi multi-VPS.

## 📦 File Package

```
xray-iplimit-package/
├── xray-iplimit.sh              # Main script (core functionality)
├── menu-xray-iplimit.sh         # Interactive management menu
├── install-xray-iplimit.sh      # Installer script
├── sync-config.sh               # Multi-VPS sync manager
├── xray-iplimit.cron            # Cron job template
└── README-XRAY-IPLIMIT.md       # This file
```

---

## 🚀 Installation

### **Method 1: Interactive Installer (Recommended)**

```bash
# Upload all files to VPS
scp xray-iplimit*.sh menu-xray-iplimit.sh install-xray-iplimit.sh root@YOUR_VPS_IP:/root/

# SSH to VPS
ssh root@YOUR_VPS_IP

# Run installer
cd /root
chmod +x install-xray-iplimit.sh
./install-xray-iplimit.sh
```

The installer will:
- Install main script to `/usr/bin/xray-iplimit`
- Install menu to `/usr/bin/menu-xray-iplimit`
- Setup cron job (choose interval: 2/5/10/15 minutes)
- Create data directories
- Optionally setup sync to master VPS

### **Method 2: Manual Installation**

```bash
# Copy files
cp xray-iplimit.sh /usr/bin/xray-iplimit
cp menu-xray-iplimit.sh /usr/bin/menu-xray-iplimit
chmod +x /usr/bin/xray-iplimit
chmod +x /usr/bin/menu-xray-iplimit

# Create directories
mkdir -p /var/lib/xray-iplimit/backups
mkdir -p /var/log/xray

# Create config files
touch /var/lib/xray-iplimit/locked_users.txt
touch /var/lib/xray-iplimit/user_limits.conf
touch /var/log/xray/iplimit.log

# Setup cron (every 5 minutes)
echo "*/5 * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1" > /etc/cron.d/xray-iplimit
service cron restart
```

---

## 💻 Usage

### **Basic Commands**

```bash
# Set user limit
xray-iplimit set <username> <max_ips> <lock_minutes>

# Examples:
xray-iplimit set john 2 60      # John: max 2 IPs, lock 60 minutes
xray-iplimit set alice 3 30     # Alice: max 3 IPs, lock 30 minutes
xray-iplimit set vip 5 15       # VIP: max 5 IPs, lock 15 minutes

# Manual lock/unlock
xray-iplimit lock username      # Lock user immediately
xray-iplimit unlock username    # Unlock user immediately

# Monitoring
xray-iplimit status             # Show current status
xray-iplimit list               # List all users with limits
xray-iplimit monitor            # Run monitoring cycle

# Interactive menu
menu-xray-iplimit               # Open management menu
```

### **Interactive Menu**

```bash
menu-xray-iplimit
```

Features:
- Set user IP limits
- Lock/unlock users
- View status and logs
- Setup auto-monitor cron
- View all users with limits

---

## 🔄 Multi-VPS Synchronization

### **Setup Sync Manager (On Local Machine)**

```bash
# Make sync script executable
chmod +x sync-config.sh

# Run sync manager
./sync-config.sh
```

First run will create config file: `~/.xray-iplimit-sync.conf`

### **Add VPS to Sync List**

Edit `~/.xray-iplimit-sync.conf`:

```ini
# Format: VPS_NAME:IP:PORT:PASSWORD
vps1:202.10.38.129:22:yourpassword
vps2:192.168.1.100:22:anotherpassword
vps3:103.50.20.30:22:thirdpassword
```

### **Sync Operations**

```bash
./sync-config.sh
```

Menu options:
1. **Push Config to All VPS** - Upload local config to all VPS
2. **Pull Config from VPS** - Download config from specific VPS
3. **View Current Config** - Show local configuration
4. **View VPS List** - List all configured VPS
5. **Edit VPS List** - Edit VPS configuration
6. **Test Connection** - Test SSH connection to all VPS
7. **Sync Status** - Check status on all VPS

### **Workflow Example**

```bash
# On local machine:
./sync-config.sh

# 1. Edit local config or pull from master VPS
# 2. Push to all VPS
# 3. Verify sync status

# All VPS now have same user limits configuration!
```

---

## 📊 How It Works

### **Lock Mechanism**

```
1. User violates IP limit (or manually locked)
   ↓
2. Script comments out user in /etc/xray/config.json
   - Adds #LOCKED_ prefix to all user entries
   ↓
3. XRAY restarts automatically
   - User UUID not loaded
   ↓
4. User CANNOT connect
   - Connection rejected/handshake fails
   ↓
5. Auto-unlock after timeout
   - Cron runs monitor
   - Removes #LOCKED_ prefix
   - XRAY restarts
   ↓
6. User can connect again
```

### **Auto-Unlock Process**

```
User locked → Timeout expires → Monitor runs (cron) → Auto-unlock → XRAY restart
```

**Important:** Auto-unlock only works when monitor runs!
- Cron interval: 5 minutes (default)
- Max unlock delay: 5 minutes after timeout

Example:
- Lock at 10:00 for 30 minutes
- Timeout expires at 10:30
- Next monitor at 10:35
- Auto-unlock at 10:35

---

## 📁 File Structure

### **Installed Files (On VPS)**

```
/usr/bin/
├── xray-iplimit                 # Main script
└── menu-xray-iplimit            # Management menu

/etc/cron.d/
└── xray-iplimit                 # Cron job

/var/lib/xray-iplimit/
├── user_limits.conf             # User configurations (user:max_ip:lock_mins)
├── locked_users.txt             # Currently locked (user:unlock_timestamp)
├── user_uuid_map.txt            # UUID to email mapping
├── ip_sessions.txt              # Active IP sessions
└── backups/                     # Config backups
    └── config_TIMESTAMP.json

/var/log/xray/
├── iplimit.log                  # Main log
└── iplimit-cron.log             # Cron execution log

/etc/xray/
└── config.json                  # XRAY config (modified with #LOCKED_)
```

### **Local Files (For Sync)**

```
~/.xray-iplimit-sync.conf        # VPS list configuration
```

---

## 🎯 Configuration Examples

### **Scenario 1: Different User Tiers**

```bash
# VIP users (5 IPs, 15 min lock)
xray-iplimit set vip1 5 15
xray-iplimit set vip2 5 15

# Premium users (3 IPs, 30 min lock)
xray-iplimit set premium1 3 30
xray-iplimit set premium2 3 30

# Regular users (2 IPs, 60 min lock)
xray-iplimit set user1 2 60
xray-iplimit set user2 2 60

# Trial users (1 IP, 120 min lock)
xray-iplimit set trial1 1 120
```

### **Scenario 2: Multi-VPS Setup**

**Master VPS (202.10.38.129):**
```bash
# Configure all user limits
xray-iplimit set john 2 60
xray-iplimit set alice 3 30
xray-iplimit set bob 2 90
```

**On Local Machine:**
```bash
# Pull from master
./sync-config.sh
# Choose: [2] Pull Config from VPS
# Select: VPS1 (master)

# Push to all slave VPS
./sync-config.sh
# Choose: [1] Push Config to All VPS

# Result: All VPS have same configuration!
```

---

## 📝 Logs & Monitoring

### **View Real-time Logs**

```bash
# Main log
tail -f /var/log/xray/iplimit.log

# Cron log
tail -f /var/log/xray/iplimit-cron.log
```

### **Log Format**

```
[2025-12-26 21:03:25] [LOCKED] User 'john' locked for 60 minutes (until 22:03:25)
[2025-12-26 21:03:25] [BACKUP] Config backed up to: /var/lib/xray-iplimit/backups/config_20251226_210325.json
[2025-12-26 21:03:25] [BLOCKING] UUID: a97419b4...4245a45d
[2025-12-26 21:03:27] [SUCCESS] User 'john' blocked, XRAY restarted successfully
[2025-12-26 22:03:30] [AUTO-UNLOCK] User 'john' automatically unlocked
[2025-12-26 22:03:30] [UNBLOCKED] User 'john' unblocked, XRAY restarted successfully
```

### **Check Status**

```bash
xray-iplimit status
```

Output:
```
╔════════════════════════════════════════╗
║    XRAY IP Limiter Status v3.1        ║
╚════════════════════════════════════════╝

📋 User Limits Configuration:
  ▸ john: Max 2 IPs, Lock 60 minutes
  ▸ alice: Max 3 IPs, Lock 30 minutes

🔒 Currently Locked Users:
  ▸ bob: Unlocks in 15m 30s

👥 Active Users:
  ▸ Total users: 3
  ▸ Locked users: 1
  ▸ Active connections: 5
```

---

## 🔧 Troubleshooting

### **1. Auto-unlock not working**

**Problem:** User still locked after timeout

**Solution:**
```bash
# Check if cron is running
service cron status

# Check cron job exists
cat /etc/cron.d/xray-iplimit

# Check cron logs
tail -f /var/log/xray/iplimit-cron.log

# Manual run monitor
xray-iplimit monitor
```

### **2. User can still connect after lock**

**Problem:** Lock not effective

**Solution:**
```bash
# Verify user is actually locked in config
grep 'username' /etc/xray/config.json | grep '#LOCKED'

# Check XRAY status
systemctl status xray

# Try manual lock again
xray-iplimit lock username
```

### **3. XRAY fails to start after lock/unlock**

**Problem:** Config syntax error

**Solution:**
```bash
# Check XRAY error
journalctl -u xray -n 50

# Restore from backup
ls /var/lib/xray-iplimit/backups/
cp /var/lib/xray-iplimit/backups/config_LATEST.json /etc/xray/config.json
systemctl restart xray
```

### **4. Sync not working**

**Problem:** Cannot push/pull config

**Solution:**
```bash
# Test SSH connection
ssh root@VPS_IP

# Check sshpass installed
which sshpass

# Install sshpass if missing
apt install sshpass -y

# Check VPS config file
cat ~/.xray-iplimit-sync.conf
```

---

## 🛡️ Security Notes

1. **Password in sync config** - Store `~/.xray-iplimit-sync.conf` securely
2. **Backup configs** - Automatic backups before each modification
3. **Rollback capability** - Restore from `/var/lib/xray-iplimit/backups/`
4. **SSH keys recommended** - Use SSH keys instead of passwords for sync

### **Setup SSH Keys for Sync**

```bash
# Generate key
ssh-keygen -t rsa

# Copy to all VPS
ssh-copy-id root@VPS_IP

# Update sync script to use keys instead of password
# Edit sync-config.sh, remove sshpass, use direct ssh/scp
```

---

## 🎓 Advanced Usage

### **Custom Cron Interval**

```bash
# Edit cron job
nano /etc/cron.d/xray-iplimit

# Change interval:
*/2 * * * * root ...    # Every 2 minutes (faster unlock)
*/10 * * * * root ...   # Every 10 minutes (less resource)
*/15 * * * * root ...   # Every 15 minutes
```

### **Batch Operations**

```bash
# Lock multiple users
for user in user1 user2 user3; do
    xray-iplimit lock $user
done

# Set same limit for multiple users
for user in vip1 vip2 vip3; do
    xray-iplimit set $user 5 15
done
```

### **Export/Import Config**

```bash
# Export config
cp /var/lib/xray-iplimit/user_limits.conf ~/user_limits_backup.conf

# Import config to another VPS
scp user_limits_backup.conf root@NEW_VPS:/var/lib/xray-iplimit/user_limits.conf
```

---

## 📞 Support & Contact

Created by: Rovo Dev AI Assistant
Version: 3.1
Date: 2025-12-26

For issues or questions, check logs first:
```bash
tail -100 /var/log/xray/iplimit.log
```

---

## 📄 License

Free to use and modify for personal and commercial purposes.

---

## 🎉 Changelog

### v3.1 (2025-12-26)
- ✅ Fixed lock mechanism (proper comment out)
- ✅ Added auto-unlock after timeout
- ✅ Added backup before modification
- ✅ Added multi-VPS sync capability
- ✅ Added interactive menu
- ✅ Added installer script
- ✅ Improved logging

### v3.0 (2025-12-26)
- ✅ Initial release
- ✅ Basic lock/unlock functionality
- ✅ Custom limits per user
- ✅ Lock timeout feature
