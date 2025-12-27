# Quick Deployment - XRAY Quota System

## 🚀 Deploy to VPS (1 Command)

```bash
./deploy-to-vps.sh <VPS_IP> <PASSWORD>
```

**Example:**
```bash
./deploy-to-vps.sh 202.10.38.129 'Gqzz$#q31COwf1'
```

---

## 📋 What Gets Installed

✅ XRAY IP Limiter + Quota Management  
✅ Menu Quota (10 interactive options)  
✅ Auto-Monitor Cron (IP 5min + Quota 10min)  
✅ All Protocol Menus (vmess, vless, trojan, ssh)  
✅ Complete logging system  

---

## ✅ Verified & Tested

- VPS: 202.10.38.129 ✅
- All files: 100% synced ✅
- 10 quota sub-menus: Working ✅
- Auto-monitor cron: Active ✅

---

## 📖 Full Guide

See [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) for:
- Manual installation steps
- Configuration options
- Troubleshooting
- Command reference

---

## 🎯 After Deploy

```bash
# Access quota menu
menu-quota

# Check quota status
xray-iplimit quota-status

# Set user quota (10 GB)
xray-iplimit quota-set username 10
```

---

**Ready for production deployment to multiple VPS! 🚀**
