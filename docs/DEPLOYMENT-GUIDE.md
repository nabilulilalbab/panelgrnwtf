# Deployment Guide - XRAY IP Limiter + Quota System

## Quick Deploy to VPS

### Method 1: Auto Deploy (Recommended)

Deploy dengan 1 command:

```bash
./deploy-to-vps.sh <VPS_IP> <PASSWORD>
```

**Example:**
```bash
./deploy-to-vps.sh 202.10.38.129 'Gqzz$#q31COwf1'
```

**Script akan otomatis:**
- ✓ Upload semua file & installer
- ✓ Install xray-iplimit + menu-quota
- ✓ Setup cron (IP Limit 5 min + Quota 10 min)
- ✓ Verifikasi instalasi
- ✓ Test semua command
- ✓ Cleanup temporary files

---

### Method 2: Manual Install

1. **Upload files ke VPS:**
```bash
scp install-xray-iplimit-complete.sh xray-iplimit.sh menu-*.sh root@VPS_IP:/root/
```

2. **SSH ke VPS:**
```bash
ssh root@VPS_IP
```

3. **Jalankan installer:**
```bash
chmod +x install-xray-iplimit-complete.sh
./install-xray-iplimit-complete.sh
```

4. **Pilih konfigurasi:**
   - IP Limit interval: `[2]` = 5 menit (recommended)
   - Quota interval: `[2]` = 10 menit (recommended)
   - Import config: `[2]` = start fresh

---

## Setelah Deploy

**Test sistem:**
```bash
# Test quota menu
menu-quota

# Test quota status
xray-iplimit quota-status

# Set quota user
xray-iplimit quota-set testuser 10

# Check quota usage
xray-iplimit quota-check testuser

# View logs
tail -f /var/log/xray/quota-cron.log
```

**Check cron:**
```bash
cat /etc/cron.d/xray-iplimit
```

---

## Files Installed

**Scripts:**
- `/usr/bin/xray-iplimit` - Main engine
- `/usr/bin/menu-quota` - Quota management menu
- `/usr/bin/menu-xray-iplimit` - IP limit menu
- `/usr/bin/menu-vmess` - Vmess menu
- `/usr/bin/menu-vless` - Vless menu
- `/usr/bin/menu-trojan` - Trojan menu
- `/usr/bin/menu-ssh` - SSH menu

**Config & Data:**
- `/var/lib/xray-iplimit/` - User configs & data
- `/var/log/xray/` - Log files
- `/etc/cron.d/xray-iplimit` - Auto-monitor cron

---

## Cron Configuration

Auto-monitor yang diinstall:

```bash
# IP Limit Monitoring (every 5 minutes)
*/5 * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1

# Quota Monitoring (every 10 minutes)  
*/10 * * * * root /usr/bin/xray-iplimit quota-monitor >> /var/log/xray/quota-cron.log 2>&1
```

**Keuntungan:**
- User yang exceed IP limit otomatis di-lock
- User yang exceed quota otomatis di-disable
- Log lengkap untuk monitoring
- No manual intervention needed

---

## Troubleshooting

**Check jika deployment gagal:**

1. **Test koneksi:**
```bash
ssh root@VPS_IP
```

2. **Check file terinstall:**
```bash
ls -la /usr/bin/xray-iplimit /usr/bin/menu-quota
```

3. **Check cron:**
```bash
cat /etc/cron.d/xray-iplimit
```

4. **Check logs:**
```bash
tail -50 /var/log/xray/iplimit.log
tail -50 /var/log/xray/quota-cron.log
```

5. **Re-run installer:**
```bash
cd /root
./install-xray-iplimit-complete.sh
```

---

## Verification Checksums

Untuk verify file sinkron:

```
menu-quota.sh:        eda95c0b5b665201b8c62f33faebe193
xray-iplimit.sh:      d8179a2171c704245e893859213861c4
menu-xray-iplimit.sh: 01942df75efb51f950313d31778fbbe2
```

Check:
```bash
md5sum menu-quota.sh
ssh root@VPS "md5sum /usr/bin/menu-quota"
```

---

## Support

- VPS tested: 202.10.38.129 ✅
- All quota menu (10 options): Working ✅
- Auto-monitor cron: Active ✅
- Ready for production deployment ✅
