# Installers

Main installation scripts for the panel.

## Available Installers

### setup-full.sh (RECOMMENDED) 🌟
**Full-featured installer with everything included**

**Includes:**
- ✅ Basic Xray panel (Vmess, Vless, Trojan, SSH)
- ✅ IP Limit system with auto-monitoring
- ✅ Quota management with auto-monitoring
- ✅ Backup & restore (include IP & quota data)
- ✅ Auto-backup to Telegram (optional)
- ✅ All menus and utilities

**Usage:**
```bash
wget -O setup-full.sh https://raw.../installer/setup-full.sh
chmod +x setup-full.sh
./setup-full.sh
```

**One-command install!**

### setup.sh
**Basic panel installer (without IP limit & quota)**

Use this if you only need basic Xray panel.

### install-xray-iplimit-complete.sh
**Standalone IP Limit + Quota installer**

Use this to add IP limit & quota features to existing panel.

## Installation Time

- setup-full.sh: ~10-15 minutes
- setup.sh: ~8-10 minutes
- install-xray-iplimit-complete.sh: ~2-3 minutes

## Requirements

- Debian 10/11 or Ubuntu 20.04/22.04
- Root access
- Minimum 1GB RAM
- Clean VPS (fresh install recommended)

## After Installation

All systems installed and ready:
```bash
menu              # Main menu
menu-quota        # Quota management
menu-xray-iplimit # IP limit management
```

Auto-monitoring active:
- IP Limit: Every 5 minutes
- Quota: Every 10 minutes
- Auto-backup: Every 10 minutes (if configured)
