# Backup & Restore System

Complete backup and restore system with Telegram integration.

## Files

### backup.sh (2.1K)
Manual backup script - creates backup with xray-iplimit data.

**Usage:**
```bash
/root/backup.sh
```

**Includes:**
- Xray configuration
- IP Limit data (user_limits.conf)
- Quota data (user_quota.conf)
- Locked users
- UUID mappings
- Cron jobs
- Web files

### restore.sh (2.7K)
Manual restore script - restores all data including IP limits and quotas.

**Usage:**
```bash
/root/restore.sh
```

### menu-bckp-telegram.sh (13K)
Interactive Telegram backup menu - setup bot and send backups.

**Features:**
- Setup Telegram bot (token & chat ID)
- Test backup send
- One-time manual backup

**Usage:**
```bash
/root/menu-bckp-telegram.sh
```

### backup-telegram-auto.sh (4.2K)
Auto-backup script for cron - sends backup to Telegram automatically.

**Features:**
- Auto backup creation
- Include xray-iplimit data
- Send to Telegram
- Detailed caption with stats
- Cleanup temp files

**Installation:**
```bash
cp backup-telegram-auto.sh /usr/bin/backup-telegram-auto
chmod +x /usr/bin/backup-telegram-auto
```

**Cron setup:**
```bash
cat > /etc/cron.d/backup-telegram-auto <<END
*/10 * * * * root /usr/bin/backup-telegram-auto >> /var/log/xray/backup-telegram-cron.log 2>&1
END
```

## Backup Contents

All backup files include:
- ✅ /etc/xray/ (Xray config)
- ✅ /var/lib/xray-iplimit/ (IP limit & quota data)
- ✅ /etc/cron.d/ (Cron jobs)
- ✅ /home/vps/public_html/ (Web files)
- ✅ System users (passwd, group, shadow)

## Restore Verification

After restore, verify:
```bash
xray-iplimit list           # Check IP limits restored
xray-iplimit quota-status   # Check quotas restored
cat /etc/cron.d/xray-iplimit # Check cron restored
```
