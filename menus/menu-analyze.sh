BIBlack='\033[1;90m'      # Black
     [57] XRAY QUOTA LIMITER 
BIRed='\033[1;91m'        # Red
     [57] XRAY QUOTA LIMITER 
BIGreen='\033[1;92m'      # Green
     [57] XRAY QUOTA LIMITER 
BIYellow='\033[1;93m'     # Yellow
     [57] XRAY QUOTA LIMITER 
BIBlue='\033[1;94m'       # Blue
     [57] XRAY QUOTA LIMITER 
BIPurple='\033[1;95m'     # Purple
     [57] XRAY QUOTA LIMITER 
BICyan='\033[1;96m'       # Cyan
     [57] XRAY QUOTA LIMITER 
BIWhite='\033[1;97m'      # White
     [57] XRAY QUOTA LIMITER 
UWhite='\033[4;37m'       # White
     [57] XRAY QUOTA LIMITER 
On_IPurple='\033[0;105m'  #
     [57] XRAY QUOTA LIMITER 
On_IRed='\033[0;101m'
     [57] XRAY QUOTA LIMITER 
IBlack='\033[0;90m'       # Black
     [57] XRAY QUOTA LIMITER 
IRed='\033[0;91m'         # Red
     [57] XRAY QUOTA LIMITER 
IGreen='\033[0;92m'       # Green
     [57] XRAY QUOTA LIMITER 
IYellow='\033[0;93m'      # Yellow
     [57] XRAY QUOTA LIMITER 
IBlue='\033[0;94m'        # Blue
     [57] XRAY QUOTA LIMITER 
IPurple='\033[0;95m'      # Purple
     [57] XRAY QUOTA LIMITER 
ICyan='\033[0;96m'        # Cyan
     [57] XRAY QUOTA LIMITER 
IWhite='\033[0;97m'       # White
     [57] XRAY QUOTA LIMITER 
NC='\e[0m'
     [57] XRAY QUOTA LIMITER 
m="\033[0;1;36m"
     [57] XRAY QUOTA LIMITER 
y="\033[0;1;37m"
     [57] XRAY QUOTA LIMITER 
yy="\033[0;1;32m"
     [57] XRAY QUOTA LIMITER 
yl="\033[0;1;33m"
     [57] XRAY QUOTA LIMITER 
wh="\033[0m"
     [57] XRAY QUOTA LIMITER 
## Foreground
     [57] XRAY QUOTA LIMITER 
DEFBOLD='\e[39;1m'
     [57] XRAY QUOTA LIMITER 
RB='\e[31;1m'
     [57] XRAY QUOTA LIMITER 
GB='\e[32;1m'
     [57] XRAY QUOTA LIMITER 
YB='\e[33;1m'
     [57] XRAY QUOTA LIMITER 
BB='\e[34;1m'
     [57] XRAY QUOTA LIMITER 
MB='\e[35;1m'
     [57] XRAY QUOTA LIMITER 
CB='\e[35;1m'
     [57] XRAY QUOTA LIMITER 
WB='\e[37;1m'
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Export Color & Information
     [57] XRAY QUOTA LIMITER 
export RED='\033[0;31m'
     [57] XRAY QUOTA LIMITER 
export GREEN='\033[0;32m'
     [57] XRAY QUOTA LIMITER 
export YELLOW='\033[0;33m'
     [57] XRAY QUOTA LIMITER 
export BLUE='\033[0;34m'
     [57] XRAY QUOTA LIMITER 
export PURPLE='\033[0;35m'
     [57] XRAY QUOTA LIMITER 
export CYAN='\033[0;36m'
     [57] XRAY QUOTA LIMITER 
export LIGHT='\033[0;37m'
     [57] XRAY QUOTA LIMITER 
export NC='\033[0m'
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Export Banner Status Information
     [57] XRAY QUOTA LIMITER 
export EROR="[${RED} EROR ${NC}]"
     [57] XRAY QUOTA LIMITER 
export INFO="[${YELLOW} INFO ${NC}]"
     [57] XRAY QUOTA LIMITER 
export OKEY="[${GREEN} OKEY ${NC}]"
     [57] XRAY QUOTA LIMITER 
export PENDING="[${YELLOW} PENDING ${NC}]"
     [57] XRAY QUOTA LIMITER 
export SEND="[${YELLOW} SEND ${NC}]"
     [57] XRAY QUOTA LIMITER 
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Export Align
     [57] XRAY QUOTA LIMITER 
export BOLD="\e[1m"
     [57] XRAY QUOTA LIMITER 
export WARNING="${RED}\e[5m"
     [57] XRAY QUOTA LIMITER 
export UNDERLINE="\e[4m"
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Exporting URL Host
     [57] XRAY QUOTA LIMITER 
export Server_URL="raw.githubusercontent.com/nabilulilalbab/panelgrnwtf/main/test"
     [57] XRAY QUOTA LIMITER 
export Server1_URL="raw.githubusercontent.com/nabilulilalbab/panelgrnwtf/main/limit"
     [57] XRAY QUOTA LIMITER 
export Server_Port="443"
     [57] XRAY QUOTA LIMITER 
export Server_IP="underfined"
     [57] XRAY QUOTA LIMITER 
export Script_Mode="Stable"
     [57] XRAY QUOTA LIMITER 
export Auther=".geovpn"
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Root Checking
     [57] XRAY QUOTA LIMITER 
if [ "${EUID}" -ne 0 ]; then
     [57] XRAY QUOTA LIMITER 
		echo -e "${EROR} Please Run This Script As Root User !"
     [57] XRAY QUOTA LIMITER 
		exit 1
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Exporting IP Address
     [57] XRAY QUOTA LIMITER 
export IP=$( curl -s https://ipinfo.io/ip/ )
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Exporting Network Interface
     [57] XRAY QUOTA LIMITER 
export NETWORK_IFACE="$(ip route show to default | awk '{print $5}')"
     [57] XRAY QUOTA LIMITER 

     [57] XRAY QUOTA LIMITER 
# // Clear
     [57] XRAY QUOTA LIMITER 
clear
     [57] XRAY QUOTA LIMITER 
clear && clear && clear
     [57] XRAY QUOTA LIMITER 
clear;clear;clear
     [57] XRAY QUOTA LIMITER 
cek=$(service ssh status | grep active | cut -d ' ' -f5)
     [57] XRAY QUOTA LIMITER 
if [ "$cek" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
stat=-f5
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
stat=-f7
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
ssh=$(service ssh status | grep active | cut -d ' ' $stat)
     [57] XRAY QUOTA LIMITER 
if [ "$ssh" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
ressh="${green}ON${NC}"
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
ressh="${red}OFF${NC}"
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
sshstunel=$(service stunnel5 status | grep active | cut -d ' ' $stat)
     [57] XRAY QUOTA LIMITER 
if [ "$sshstunel" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
resst="${green}ON${NC}"
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
resst="${red}OFF${NC}"
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
sshws=$(service ws-stunnel status | grep active | cut -d ' ' $stat)
     [57] XRAY QUOTA LIMITER 
if [ "$sshws" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
ressshws="${green}ON${NC}"
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
ressshws="${red}OFF${NC}"
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
ngx=$(service nginx status | grep active | cut -d ' ' $stat)
     [57] XRAY QUOTA LIMITER 
if [ "$ngx" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
resngx="${green}ON${NC}"
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
resngx="${red}OFF${NC}"
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
dbr=$(service dropbear status | grep active | cut -d ' ' $stat)
     [57] XRAY QUOTA LIMITER 
if [ "$dbr" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
resdbr="${green}ON${NC}"
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
resdbr="${red}OFF${NC}"
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
v2r=$(service xray status | grep active | cut -d ' ' $stat)
     [57] XRAY QUOTA LIMITER 
if [ "$v2r" = "active" ]; then
     [57] XRAY QUOTA LIMITER 
resv2r="${green}ON${NC}"
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
resv2r="${red}OFF${NC}"
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
function addhost(){
     [57] XRAY QUOTA LIMITER 
clear
     [57] XRAY QUOTA LIMITER 
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
     [57] XRAY QUOTA LIMITER 
echo ""
     [57] XRAY QUOTA LIMITER 
read -rp "Domain/Host: " -e host
     [57] XRAY QUOTA LIMITER 
echo ""
     [57] XRAY QUOTA LIMITER 
if [ -z $host ]; then
     [57] XRAY QUOTA LIMITER 
echo "????"
     [57] XRAY QUOTA LIMITER 
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
     [57] XRAY QUOTA LIMITER 
read -n 1 -s -r -p "Press any key to back on menu"
     [57] XRAY QUOTA LIMITER 
setting-menu
     [57] XRAY QUOTA LIMITER 
else
     [57] XRAY QUOTA LIMITER 
rm -fr /etc/xray/domain
     [57] XRAY QUOTA LIMITER 
echo "IP=$host" > /var/lib/scrz-prem/ipvps.conf
     [57] XRAY QUOTA LIMITER 
echo $host > /etc/xray/domain
     [57] XRAY QUOTA LIMITER 
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
     [57] XRAY QUOTA LIMITER 
echo "Dont forget to renew gen-ssl"
     [57] XRAY QUOTA LIMITER 
echo ""
     [57] XRAY QUOTA LIMITER 
read -n 1 -s -r -p "Press any key to back on menu"
     [57] XRAY QUOTA LIMITER 
menu
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
}
     [57] XRAY QUOTA LIMITER 
function genssl(){
     [57] XRAY QUOTA LIMITER 
clear
     [57] XRAY QUOTA LIMITER 
systemctl stop nginx
     [57] XRAY QUOTA LIMITER 
systemctl stop xray
     [57] XRAY QUOTA LIMITER 
domain=$(cat /var/lib/scrz-prem/ipvps.conf | cut -d'=' -f2)
     [57] XRAY QUOTA LIMITER 
Cek=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
     [57] XRAY QUOTA LIMITER 
if [[ ! -z "$Cek" ]]; then
     [57] XRAY QUOTA LIMITER 
sleep 1
     [57] XRAY QUOTA LIMITER 
echo -e "[ ${red}WARNING${NC} ] Detected port 80 used by $Cek " 
     [57] XRAY QUOTA LIMITER 
systemctl stop $Cek
     [57] XRAY QUOTA LIMITER 
sleep 2
     [57] XRAY QUOTA LIMITER 
echo -e "[ ${green}INFO${NC} ] Processing to stop $Cek " 
     [57] XRAY QUOTA LIMITER 
sleep 1
     [57] XRAY QUOTA LIMITER 
fi
     [57] XRAY QUOTA LIMITER 
echo -e "[ ${green}INFO${NC} ] Starting renew gen-ssl... " 
     [57] XRAY QUOTA LIMITER 
sleep 2
     [57] XRAY QUOTA LIMITER 
/root/.acme.sh/acme.sh --upgrade
     [57] XRAY QUOTA LIMITER 
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
     [57] XRAY QUOTA LIMITER 
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
     [57] XRAY QUOTA LIMITER 
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
     [57] XRAY QUOTA LIMITER 
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
     [57] XRAY QUOTA LIMITER 
echo -e "[ ${green}INFO${NC} ] Renew gen-ssl done... " 
     [57] XRAY QUOTA LIMITER 
sleep 2
     [57] XRAY QUOTA LIMITER 
echo -e "[ ${green}INFO${NC} ] Starting service $Cek " 
     [57] XRAY QUOTA LIMITER 
sleep 2
     [57] XRAY QUOTA LIMITER 
echo $domain > /etc/xray/domain
     [57] XRAY QUOTA LIMITER 
systemctl start nginx
     [57] XRAY QUOTA LIMITER 
systemctl start xray
     [57] XRAY QUOTA LIMITER 
echo -e "[ ${green}INFO${NC} ] All finished... " 
     [57] XRAY QUOTA LIMITER 
sleep 0.5
     [57] XRAY QUOTA LIMITER 
echo ""
     [57] XRAY QUOTA LIMITER 
read -n 1 -s -r -p "Press any key to back on menu"
     [57] XRAY QUOTA LIMITER 
menu
     [57] XRAY QUOTA LIMITER 
}
     [57] XRAY QUOTA LIMITER 
export sem=$( curl -s https://raw.githubusercontent.com/nabilulilalbab/panelgrnwtf/main/test/versions)
     [57] XRAY QUOTA LIMITER 
export pak=$( cat /home/.ver)
     [57] XRAY QUOTA LIMITER 
IPVPS=$(curl -s ipinfo.io/ip )
     [57] XRAY QUOTA LIMITER 
IPVPS=$(curl -sS ipv4.icanhazip.com)
     [57] XRAY QUOTA LIMITER 
IPVPS=$(curl -sS ifconfig.me )
     [57] XRAY QUOTA LIMITER 
ISPVPS=$( curl -s ipinfo.io/org )
     [57] XRAY QUOTA LIMITER 
daily_usage=$(vnstat -d --oneline | awk -F\; '{print $6}' | sed 's/ //')
     [57] XRAY QUOTA LIMITER 
monthly_usage=$(vnstat -m --oneline | awk -F\; '{print $11}' | sed 's/ //')
     [57] XRAY QUOTA LIMITER 
ram_used=$(free -m | grep Mem: | awk '{print $3}')
     [57] XRAY QUOTA LIMITER 
total_ram=$(free -m | grep Mem: | awk '{print $2}')
     [57] XRAY QUOTA LIMITER 
ram_usage=$(echo "scale=2; ($ram_used / $total_ram) * 100" | bc | cut -d. -f1)
     [57] XRAY QUOTA LIMITER 
# OS Uptime
     [57] XRAY QUOTA LIMITER 
uptime="$(uptime -p | cut -d " " -f 2-10)"
     [57] XRAY QUOTA LIMITER 
# TOTAL ACC XRAYS WS & XTLS
     [57] XRAY QUOTA LIMITER 
vmess=$(grep -c -E "^#vmsg $user" "/etc/xray/config.json")
     [57] XRAY QUOTA LIMITER 
vless=$(grep -c -E "^#vlsg $user" "/etc/xray/config.json")
     [57] XRAY QUOTA LIMITER 
tr=$(grep -c -E "^#trg $user" "/etc/xray/config.json")
     [57] XRAY QUOTA LIMITER 
ss=$(grep -c -E "^#ssg $user" "/etc/xray/config.json")
     [57] XRAY QUOTA LIMITER 
ssh="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
     [57] XRAY QUOTA LIMITER 
# Getting CPU Information
     [57] XRAY QUOTA LIMITER 
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
     [57] XRAY QUOTA LIMITER 
cpu_usage="$((${cpu_usage1/\.*/} / ${corediilik:-1}))"
     [57] XRAY QUOTA LIMITER 
cpu_usage+="%"
     [57] XRAY QUOTA LIMITER 
cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
     [57] XRAY QUOTA LIMITER 
cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
     [57] XRAY QUOTA LIMITER 
freq=$(awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo)
     [57] XRAY QUOTA LIMITER 
clear
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} ┌────────────────────────────────────────────────────────────┐${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │                  ${BIWhite}${UWhite}Server Informations${NC}"         
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │"                                                                      
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}OS Linux        :  "$(hostnamectl | grep "Operating System" | cut -d ' ' -f5-)  
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}Kernel          :  ${BICyan}$(uname -r)${NC}"  
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}CPU Name        : ${BIWhite}$cname${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}CPU Info        :  ${BIWhite}$cores Cores @ $freq MHz (${cpu_usage}) ${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}Total RAM       :  ${BIWhite}${ram_used}MB / ${total_ram}MB (${ram_usage}%) ${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}System Uptime   :  ${BIWhite}$uptime${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}Current Domain  :  ${BIWhite}$(cat /etc/xray/domain)${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}IP-VPS          :  ${BIWhite}$IPVPS${NC}"                  
     [57] XRAY QUOTA LIMITER 
#echo -e "${BICyan} │  ${BICyan}ISP-VPS         :  ${BIWhite}$ISPVPS${NC}"  
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}Daily Bandwidth :  ${BIWhite}$daily_usage ${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} │  ${BICyan}Total Bandwidth :  ${BIWhite}$monthly_usage ${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} └────────────────────────────────────────────────────────────┘${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan} SSH ${NC}: $ressh"" ${BICyan} NGINX ${NC}: $resngx"" ${BICyan}  XRAY ${NC}: $resv2r"" ${BICyan} TROJAN ${NC}: $resv2r"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan} DROPBEAR ${NC}: $resdbr" "${BICyan} SSH-WS ${NC}: $ressshws" Stunnel ${NC}: $sshstunel" "${BICyan}
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} ┌────────────────────────────────────────────────────────────┐${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] SSHWS       ${WB}[${GB}${ssh}${WB}] ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] VMESS       ${WB}[${GB}${vmess}${WB}] ${BICyan}${BIYellow}${BICyan}${NC}"    
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] VLESS       ${WB}[${GB}${vless}${WB}] ${BICyan}${BIYellow}${BICyan}${NC}"    
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] TROJAN      ${WB}[${GB}${tr}${WB}] ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] SHADOWSOCKS ${WB}[${GB}${ss}${WB}] ${BICyan}${BIYellow}${BICyan}${NC}"   
     [57] XRAY QUOTA LIMITER 
echo -e "" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}06${BICyan}] EXP FILES ${BICyan}${BIYellow}${BICyan}${NC}"    
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}07${BICyan}] AUTO REBOOT ${BICyan}${BIYellow}${BICyan}${NC}"    
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}08${BICyan}] REBOOT ${BICyan}${BIYellow}${BICyan}${NC}"    
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}09${BICyan}] RESTART ${BICyan}${BIYellow}${BICyan}${NC}"    
     [57] XRAY QUOTA LIMITER 
#echo -e "     ${BICyan}[${BIWhite}10${BICyan}] BACKUP/RESTORE ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e ""   
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}11${BICyan}] ADD HOST/DOMAIN ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}12${BICyan}] RENEW CERT ${BICyan}${BIYellow}${BICyan}${NC}"       
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}13${BICyan}] EDIT BANNER ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}14${BICyan}] RUNNING STATUS ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}15${BICyan}] USER BANDWIDTH ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}16${BICyan}] SPEEDTEST ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}17${BICyan}] CHECK BANDWIDTH ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}18${BICyan}] LIMIT SPEED ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}19${BICyan}] WEBMIN ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}20${BICyan}] INFO SCRIPT ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}21${BICyan}] CLEAR LOG ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}22${BICyan}] TASK MANAGER ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}23${BICyan}] DNS CHANGER ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}24${BICyan}] NETFLIX CHECKER ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}25${BICyan}] TENDANG ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
#echo -e "     ${BICyan}[${BIWhite}25${BICyan}] DELETE XRAYS USER [${BIWhite} $xrays users ${BICyan}] ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
#echo -e "     ${BICyan}[${BIWhite}30${BICyan}] VLESS CONFIG ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e " "
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}55${BICyan}] XRAY-CORE MENU ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}56${BICyan}] XRAY IP LIMITER ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
     ${BICyan}[${BIWhite}57${BICyan}] XRAY QUOTA LIMITER ${BICyan}${BIYellow}${BICyan}${NC}
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}66${BICyan}] INSTALL BBRPLUS ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}77${BICyan}] SWAPRAM MENU ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}88${BICyan}] BACKUP ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}99${BICyan}] RESTORE ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
#echo -e "     ${BICyan}[${BIWhite}88${BICyan}] INSTALL SLOWDNS ${BICyan}${BIYellow}${BICyan}${NC}"
     [57] XRAY QUOTA LIMITER 
#echo -e "     ${BICyan}[${BIWhite}99${BICyan}] INSTALL UDPCUSTOM ${BICyan}${BIYellow}${BICyan}${NC}" 
     [57] XRAY QUOTA LIMITER 
echo -e "     ${BICyan}[${BIWhite}x ${BICyan}] EXIT ${BICyan}${BIYellow}${BICyan}${NC}"  
     [57] XRAY QUOTA LIMITER 
echo -e "${BICyan} └────────────────────────────────────────────────────────────┘${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e " ${BICyan}┌─────────────────────────────────────┐${NC}"
     [57] XRAY QUOTA LIMITER 
echo -e " ${BICyan}│  Version      ${NC} : $sem Last Update"    
     [57] XRAY QUOTA LIMITER 
echo -e " ${BICyan}└─────────────────────────────────────┘${NC}"
     [57] XRAY QUOTA LIMITER 
echo
     [57] XRAY QUOTA LIMITER 
read -p " Select menu : " opt
     [57] XRAY QUOTA LIMITER 
echo -e ""
     [57] XRAY QUOTA LIMITER 
case $opt in
     [57] XRAY QUOTA LIMITER 
1) clear ; menu-ssh ;;
     [57] XRAY QUOTA LIMITER 
2) clear ; menu-vmess ;;
     [57] XRAY QUOTA LIMITER 
3) clear ; menu-vless ;;
     [57] XRAY QUOTA LIMITER 
4) clear ; menu-trojan ;;
     [57] XRAY QUOTA LIMITER 
5) clear ; menu-ss ;;
     [57] XRAY QUOTA LIMITER 
6) clear ; xp ;;
     [57] XRAY QUOTA LIMITER 
7) clear ; autoreboot ;;
     [57] XRAY QUOTA LIMITER 
8) clear ; reboot ;;
     [57] XRAY QUOTA LIMITER 
9) clear ; restart ;;
     [57] XRAY QUOTA LIMITER 
#10) clear ; menu-bckp ;;
     [57] XRAY QUOTA LIMITER 
11) clear ; addhost ;;
     [57] XRAY QUOTA LIMITER 
12) clear ; genssl ;;
     [57] XRAY QUOTA LIMITER 
13) clear ; nano /etc/issue.net ;;
     [57] XRAY QUOTA LIMITER 
14) clear ; running ;;
     [57] XRAY QUOTA LIMITER 
15) clear ; cek-trafik ;;
     [57] XRAY QUOTA LIMITER 
16) clear ; cek-speed ;;
     [57] XRAY QUOTA LIMITER 
17) clear ; cek-bandwidth ;;
     [57] XRAY QUOTA LIMITER 
18) clear ; limit-speed ;;
     [57] XRAY QUOTA LIMITER 
19) clear ; wbm ;;
     [57] XRAY QUOTA LIMITER 
20) clear ; cat /root/log-install.txt ;;
     [57] XRAY QUOTA LIMITER 
21) clear ; clearlog ;;
     [57] XRAY QUOTA LIMITER 
22) clear ; gotop ;;
     [57] XRAY QUOTA LIMITER 
23) clear ; dns ;;
     [57] XRAY QUOTA LIMITER 
24) clear ; netf ;;
     [57] XRAY QUOTA LIMITER 
25) clear ; tendang ;;
     [57] XRAY QUOTA LIMITER 
56) clear ; menu-xray-iplimit ;;
     [57] XRAY QUOTA LIMITER 
55) clear ; wget -q -O /usr/bin/xraychanger "https://raw.githubusercontent.com/NevermoreSSH/Xcore-custompath/main/xraychanger.sh" && chmod +x /usr/bin/xraychanger && xraychanger ;;
     [57] XRAY QUOTA LIMITER 
66) clear ; bbr ;;
     [57] XRAY QUOTA LIMITER 
77) clear ; wget -q -O /usr/bin/swapram "https://raw.githubusercontent.com/NevermoreSSH/swapram/main/swapram.sh" && chmod +x /usr/bin/swapram && swapram ;;
     [57] XRAY QUOTA LIMITER 
88) clear ; backup ;;
     [57] XRAY QUOTA LIMITER 
99) clear ; restore ;;
     [57] XRAY QUOTA LIMITER 
#88) clear ; wget https://raw.githubusercontent.com/NevermoreSSH/Vergil/main2/addons/dns2.sh && chmod +x dns2.sh && ./dns2.sh ;;
     [57] XRAY QUOTA LIMITER 
#99) clear ; wget https://raw.githubusercontent.com/NevermoreSSH/Vergil/main/Tunnel/udp.sh && bash udp.sh ;;
     [57] XRAY QUOTA LIMITER 
#22) clear ; wget https://raw.githubusercontent.com/nabilulilalbab/panelgrnwtf/main/cf.sh && chmod +x cf.sh && ./cf.sh ;;
     [57] XRAY QUOTA LIMITER 
#25) clear ; del-xrays ;;
     [57] XRAY QUOTA LIMITER 
#30) clear ; user-xrays ;;
     [57] XRAY QUOTA LIMITER 
0) clear ; menu ;;
     [57] XRAY QUOTA LIMITER 
x) exit ;;
     [57] XRAY QUOTA LIMITER 
*) echo -e "" ; echo "Press any key to back exit" ; sleep 1 ; exit ;;
     [57] XRAY QUOTA LIMITER 
esac
     [57] XRAY QUOTA LIMITER 
