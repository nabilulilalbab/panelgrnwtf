# Account Creation with IP Limit & Quota Integration

## ✅ IMPLEMENTASI SELESAI

Modifikasi telah diterapkan pada 3 script pembuatan akun utama:

### Files Modified:
1. ✅ **add-ws.sh** (Vmess account creation)
2. ✅ **add-vless.sh** (Vless account creation)  
3. ✅ **add-tr.sh** (Trojan account creation)

---

## 🎯 FITUR BARU

### Saat Membuat Akun, Sekarang Input:

```
1. Username
2. Expired (days)
3. IP Limit (max IP, default=2)          ← NEW!
4. Quota (GB, default=10)                ← NEW!
5. Lock duration (minutes, default=60)   ← NEW!
```

### Auto-Setup setelah account dibuat:
- ✅ Set IP Limit otomatis
- ✅ Set Quota otomatis
- ✅ Display IP & Quota info di account summary
- ✅ **Expired date ditampilkan di paling bawah**

---

## 📋 CONTOH PENGGUNAAN

### Membuat Akun Vmess:

```bash
menu-vmess  # atau langsung: add-ws
```

**Flow interaktif:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Add Xray/Vmess Account
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

User: testuser
Expired (days): 30

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  IP Limit & Quota Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IP Limit (max IP, default=2, 0=unlimited): 3
Quota (GB, default=10, 0=unlimited): 50
Lock duration if exceed (minutes, default=60): 120

Creating account...
✓ Account created
✓ IP Limit set: Max 3 IP (Lock: 120 minutes)
✓ Quota set: 50 GB
```

### Output Account Info:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Xray/Vmess Account
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Remarks : testuser
Domain : yourdomain.com
Port TLS : 443
Port none TLS : 80
Port GRPC : 443
id : xxx-xxx-xxx-xxx
alterId : 0
Security : auto
Network : ws/grpc
Path : /vmess
ServiceName : vmess-grpc
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link TLS : vmess://xxx...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link none TLS : vmess://xxx...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link GRPC : vmess://xxx...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link Vmess Config : http://domain:81/vmess-testuser.txt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IP Limit : Max 3 IP (Lock: 120 minutes)    ← NEW!
Quota : 50 GB                               ← NEW!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Expired On : 2025-01-26                     ← DI BAWAH!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔧 OPSI KONFIGURASI

### 1. Default Values (Tekan Enter)
```
IP Limit: [Enter] → pakai default 2 IP
Quota: [Enter] → pakai default 10 GB
Lock: [Enter] → pakai default 60 menit
```

### 2. Custom Values
```
IP Limit: 5 → max 5 IP
Quota: 100 → 100 GB
Lock: 180 → lock 3 jam
```

### 3. Unlimited
```
IP Limit: 0 → unlimited IP
Quota: 0 → unlimited quota
```

---

## 📊 DETAIL MODIFIKASI

### Pada Setiap Script (add-ws.sh, add-vless.sh, add-tr.sh):

#### 1. Tambahan Input (setelah expired):
```bash
# IP Limit & Quota Configuration
echo -e ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "  IP Limit & Quota Configuration"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "IP Limit (max IP, default=2, 0=unlimited): " iplimit
iplimit=${iplimit:-2}

read -p "Quota (GB, default=10, 0=unlimited): " quota
quota=${quota:-10}

read -p "Lock duration if exceed (minutes, default=60): " locktime
locktime=${locktime:-60}
```

#### 2. Auto-Set Limits (sebelum restart xray):
```bash
# Set IP Limit & Quota
if [ "$iplimit" != "0" ]; then
    /usr/bin/xray-iplimit set "$user" "$iplimit" "$locktime" > /dev/null 2>&1
fi

if [ "$quota" != "0" ]; then
    /usr/bin/xray-iplimit quota-set "$user" "$quota" > /dev/null 2>&1
fi
```

#### 3. Display di Output (sebelum expired date):
```bash
if [ "$iplimit" != "0" ]; then
    echo -e "IP Limit : Max $iplimit IP (Lock: ${locktime} minutes)" | tee -a /etc/log-create-user.log
else
    echo -e "IP Limit : Unlimited" | tee -a /etc/log-create-user.log
fi
if [ "$quota" != "0" ]; then
    echo -e "Quota : ${quota} GB" | tee -a /etc/log-create-user.log
else
    echo -e "Quota : Unlimited" | tee -a /etc/log-create-user.log
fi
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-user.log
echo -e "Expired On : $exp" | tee -a /etc/log-create-user.log
```

---

## ✅ KEUNTUNGAN

1. **One-Stop Account Creation**
   - Semua konfigurasi di satu tempat
   - Tidak perlu masuk menu quota terpisah

2. **Default Values**
   - User bisa skip dengan Enter
   - Otomatis pakai nilai default yang reasonable

3. **Konsistensi**
   - Semua akun baru pasti punya limit
   - Tidak ada akun tanpa kontrol

4. **User Friendly**
   - Interface jelas dan intuitif
   - Informasi lengkap di output

5. **Flexible**
   - Bisa unlimited (input 0)
   - Bisa custom sesuai kebutuhan

6. **Auto-Logged**
   - Semua info tersimpan di `/etc/log-create-user.log`
   - Mudah untuk audit

---

## 🔍 VERIFIKASI

Cek apakah IP limit & quota berhasil di-set:

```bash
# Check IP limit
xray-iplimit list

# Check quota
xray-iplimit quota-status

# Check specific user
xray-iplimit status testuser
xray-iplimit quota-check testuser
```

---

## 📝 NOTES

- Expired date sekarang ditampilkan **paling bawah** setelah IP Limit & Quota info
- Semua input menggunakan default values yang bisa di-skip dengan Enter
- IP Limit dan Quota bisa di-set 0 untuk unlimited
- Log tersimpan di `/etc/log-create-user.log`
- Auto-monitor cron akan mengecek limits secara berkala

---

## 🚀 DEPLOYMENT

File yang sudah dimodifikasi:
- ✅ add-ws.sh (Vmess)
- ✅ add-vless.sh (Vless)
- ✅ add-tr.sh (Trojan)

**Untuk deploy ke VPS:**
```bash
# Upload file yang sudah dimodifikasi
scp add-ws.sh add-vless.sh add-tr.sh root@VPS:/usr/bin/

# Set permission
ssh root@VPS "chmod +x /usr/bin/add-ws /usr/bin/add-vless /usr/bin/add-tr"

# Test create account
ssh root@VPS "add-ws"
```

Atau gunakan deployment script:
```bash
./deploy-to-vps.sh <VPS_IP> <PASSWORD>
```

---

## ✨ READY TO USE!

Sistem sudah siap digunakan. Setiap pembuatan akun baru akan otomatis:
- Input IP Limit & Quota
- Set limits setelah account dibuat
- Display info lengkap termasuk expired date di bawah

**Happy Managing! 🎉**
