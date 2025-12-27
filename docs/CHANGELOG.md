# Changelog - XRAY IP Limiter

## [3.1.0] - 2025-12-26

### 🎉 New Features
- ✅ Multi-VPS synchronization support
- ✅ Interactive sync manager (sync-config.sh)
- ✅ Automated installer script
- ✅ Config backup before modifications
- ✅ Improved lock mechanism (proper comment-out)
- ✅ Auto-unlock after timeout via cron
- ✅ Real-time status with countdown
- ✅ Detailed logging with timestamps

### 🐛 Bug Fixes
- ✅ Fixed lock mechanism (now properly blocks users)
- ✅ Fixed duplicate #LOCKED_ prefix issue
- ✅ Fixed XRAY restart verification
- ✅ Fixed auto-unlock timing

### 🔧 Improvements
- ✅ Better error handling
- ✅ Rollback on XRAY failure
- ✅ Enhanced status display
- ✅ Better logging format
- ✅ Comprehensive documentation

### 📦 Package Contents
- xray-iplimit.sh (11KB) - Main script
- menu-xray-iplimit.sh (4.5KB) - Interactive menu
- install-xray-iplimit.sh (7.3KB) - Installer
- sync-config.sh (8.7KB) - Multi-VPS sync
- README-XRAY-IPLIMIT.md (11KB) - Documentation
- QUICK-START.md - Quick start guide
- Example config files

### 🧪 Testing
- ✅ Tested on Debian 11
- ✅ Tested with XRAY 25.12.8
- ✅ Lock/unlock verified working
- ✅ Auto-unlock verified working
- ✅ Multi-VPS sync tested

### 📝 Known Limitations
- IP tracking is approximate (connection-based, not UUID-based)
- Auto-unlock depends on cron interval (max 5 min delay)
- Sync requires sshpass or SSH keys
- Designed for XRAY only (not V2Ray)

---

## [3.0.0] - 2025-12-26

### 🎉 Initial Release
- ✅ Custom IP limit per user
- ✅ Lock timeout feature
- ✅ Manual lock/unlock
- ✅ Basic monitoring
- ✅ Cron job support

---

**Next Version Plans (3.2.0):**
- [ ] Telegram notification on lock
- [ ] Web dashboard
- [ ] Advanced IP tracking via Nginx logs
- [ ] API for remote management
- [ ] Docker support
