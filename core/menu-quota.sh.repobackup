#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║      ${CYAN}XRAY QUOTA MANAGEMENT - MENU UTAMA${GREEN}            ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${YELLOW}  MANAJEMEN QUOTA:${NC}"
echo -e "  ${CYAN}[1]${NC} Set Quota User (Atur Batas Quota)"
echo -e "  ${CYAN}[2]${NC} Cek Quota User (Lihat Pemakaian)"
echo -e "  ${CYAN}[3]${NC} Status Semua Quota (Overview)"
echo -e "  ${CYAN}[4]${NC} Reset Quota User (Aktifkan Ulang)"
echo -e "  ${CYAN}[5]${NC} Monitor Quota Manual (Check Sekali)"
echo -e ""
echo -e "${YELLOW}  MONITORING & LOGS:${NC}"
echo -e "  ${CYAN}[6]${NC} Lihat Log Quota"
echo -e "  ${CYAN}[7]${NC} Lihat Log Cron (Auto-Monitor)"
echo -e "  ${CYAN}[8]${NC} Status Auto-Monitor (Cron)"
echo -e ""
echo -e "${YELLOW}  KONFIGURASI:${NC}"
echo -e "  ${CYAN}[9]${NC} Setup Auto-Monitor (Aktifkan Cron)"
echo -e "  ${CYAN}[10]${NC} Stop Auto-Monitor (Matikan Cron)"
echo -e ""
echo -e "  ${RED}[0]${NC} Kembali ke Menu Utama"
echo -e ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
read -p "Pilih opsi: " option

case $option in
    1)
        clear
        echo -e "${CYAN}╔═══ SET QUOTA USER ═══╗${NC}"
        echo ""
        read -p "Username: " username
        read -p "Quota (GB): " quota_gb
        
        if [ -z "$username" ] || [ -z "$quota_gb" ]; then
            echo -e "${RED}✗ Username dan Quota harus diisi!${NC}"
        else
            echo ""
            xray-iplimit quota-set "$username" "$quota_gb"
            echo ""
            echo -e "${GREEN}✓ Quota berhasil diset!${NC}"
        fi
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    2)
        clear
        echo -e "${CYAN}╔═══ CEK QUOTA USER ═══╗${NC}"
        echo ""
        read -p "Username: " username
        
        if [ -z "$username" ]; then
            echo -e "${RED}✗ Username harus diisi!${NC}"
        else
            echo ""
            xray-iplimit quota-check "$username"
        fi
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    3)
        clear
        echo -e "${CYAN}╔═══ STATUS SEMUA QUOTA ═══╗${NC}"
        echo ""
        xray-iplimit quota-status
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    4)
        clear
        echo -e "${CYAN}╔═══ RESET QUOTA USER ═══╗${NC}"
        echo ""
        read -p "Username: " username
        
        if [ -z "$username" ]; then
            echo -e "${RED}✗ Username harus diisi!${NC}"
        else
            echo ""
            echo -e "${YELLOW}⚠ Ini akan reset quota dan aktifkan kembali user${NC}"
            read -p "Lanjutkan? (y/n): " confirm
            
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                xray-iplimit quota-reset "$username"
                echo ""
                echo -e "${GREEN}✓ Quota berhasil direset!${NC}"
            else
                echo "Dibatalkan"
            fi
        fi
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    5)
        clear
        echo -e "${CYAN}╔═══ MONITOR QUOTA MANUAL ═══╗${NC}"
        echo ""
        echo "Menjalankan monitoring quota..."
        echo ""
        xray-iplimit quota-monitor
        echo ""
        echo -e "${GREEN}✓ Monitoring selesai${NC}"
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    6)
        clear
        echo -e "${CYAN}╔═══ LOG QUOTA (30 baris terakhir) ═══╗${NC}"
        echo ""
        tail -30 /var/log/xray/iplimit.log | grep -i quota || echo "Belum ada log quota"
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    7)
        clear
        echo -e "${CYAN}╔═══ LOG CRON AUTO-MONITOR ═══╗${NC}"
        echo ""
        echo "IP Limit Cron Log:"
        tail -20 /var/log/xray/iplimit-cron.log 2>/dev/null || echo "Belum ada log"
        echo ""
        echo "Quota Cron Log:"
        tail -20 /var/log/xray/quota-cron.log 2>/dev/null || echo "Belum ada log"
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    8)
        clear
        echo -e "${CYAN}╔═══ STATUS AUTO-MONITOR ═══╗${NC}"
        echo ""
        if [ -f /etc/cron.d/xray-iplimit ]; then
            echo -e "${GREEN}✓ Auto-Monitor AKTIF${NC}"
            echo ""
            echo "Konfigurasi:"
            cat /etc/cron.d/xray-iplimit
            echo ""
            echo "Cron Service:"
            systemctl is-active cron && echo "  Status: Running ✓" || echo "  Status: Stopped ✗"
        else
            echo -e "${RED}✗ Auto-Monitor TIDAK AKTIF${NC}"
            echo "Gunakan opsi [9] untuk mengaktifkan"
        fi
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    9)
        clear
        echo -e "${CYAN}╔═══ SETUP AUTO-MONITOR ═══╗${NC}"
        echo ""
        echo "Pilih interval monitoring:"
        echo "  [1] Setiap 5 menit (IP Limit) + 10 menit (Quota)"
        echo "  [2] Setiap 10 menit (IP Limit) + 15 menit (Quota)"
        echo "  [3] Setiap 15 menit (IP Limit) + 30 menit (Quota)"
        read -p "Pilihan: " interval_choice
        
        case $interval_choice in
            1) 
                IP_INTERVAL="*/5"
                QUOTA_INTERVAL="*/10"
                ;;
            2) 
                IP_INTERVAL="*/10"
                QUOTA_INTERVAL="*/15"
                ;;
            3) 
                IP_INTERVAL="*/15"
                QUOTA_INTERVAL="*/30"
                ;;
            *) 
                echo -e "${RED}Pilihan tidak valid${NC}"
                read -p "Tekan Enter..."
                exec "$0"
                ;;
        esac
        
        # Create cron job
        cat > /etc/cron.d/xray-iplimit << EOFCRON
# XRAY IP Limiter + Quota Monitor

# IP Limit Monitoring
$IP_INTERVAL * * * * root /usr/bin/xray-iplimit monitor >> /var/log/xray/iplimit-cron.log 2>&1

# Quota Monitoring
$QUOTA_INTERVAL * * * * root /usr/bin/xray-iplimit quota-monitor >> /var/log/xray/quota-cron.log 2>&1

EOFCRON
        
        chmod 644 /etc/cron.d/xray-iplimit
        systemctl restart cron
        
        echo ""
        echo -e "${GREEN}✓ Auto-Monitor berhasil diaktifkan!${NC}"
        echo "  IP Limit: Setiap $IP_INTERVAL menit"
        echo "  Quota: Setiap $QUOTA_INTERVAL menit"
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    10)
        clear
        echo -e "${CYAN}╔═══ STOP AUTO-MONITOR ═══╗${NC}"
        echo ""
        read -p "Yakin ingin matikan auto-monitor? (y/n): " confirm
        
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            rm -f /etc/cron.d/xray-iplimit
            systemctl restart cron
            echo ""
            echo -e "${GREEN}✓ Auto-Monitor berhasil dimatikan${NC}"
        else
            echo "Dibatalkan"
        fi
        echo ""
        read -p "Tekan Enter untuk lanjut..."
        ;;
    0)
        exit 0
        ;;
    *)
        echo -e "${RED}Pilihan tidak valid!${NC}"
        read -p "Tekan Enter untuk lanjut..."
        ;;
esac

# Loop back to menu
exec "$0"
