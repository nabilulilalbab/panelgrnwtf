# Deployment Tools

Tools for deploying the system to VPS servers.

## deploy-to-vps.sh

Automated deployment script for single VPS.

**Features:**
- One-command deployment
- Auto-upload all files
- Run installer automatically
- Verify with MD5 checksum
- Test commands after install
- Cleanup temporary files

**Usage:**
```bash
./deploy-to-vps.sh <VPS_IP> <PASSWORD>
```

**Example:**
```bash
./deploy-to-vps.sh 202.10.38.129 'YourPassword'
```

**What it does:**
1. ✅ Upload all required files
2. ✅ Upload installer
3. ✅ Run installation automatically
4. ✅ Setup cron jobs (IP + Quota + Backup)
5. ✅ Verify installation
6. ✅ Test commands
7. ✅ Cleanup temp files
8. ✅ Show summary

**Requirements:**
- sshpass installed
- SSH access to VPS
- Root password

**Install sshpass:**
```bash
# Debian/Ubuntu
apt-get install sshpass

# CentOS/RHEL
yum install sshpass
```

## Deployment Result

After successful deployment:
- ✅ Full panel installed
- ✅ IP Limit system active
- ✅ Quota system active
- ✅ Auto-monitoring running
- ✅ Backup system ready
- ✅ All menus accessible

Access via SSH and run: `menu`
