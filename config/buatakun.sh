#!/bin/bash
# Created by http://www.overses.net
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
echo "Connecting to overses.net..."
sleep 0.2
echo "Checking Permision..."
sleep 0.3
echo -e "${green}Permission Accepted...${NC}"
sleep 1
echo""

read -p "Masukkan Username : " username
egrep "^$username" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
echo "Username sudah ada di VPS anda"
exit 0
else
read -p "Masukkan Password [$username]: " password
read -p "Masa Aktif Account [$username] (Hari): " masa_aktif
MYIP=$(wget -qO- ipv4.icanhazip.com)
today=`date +%s`
masa_aktif_detik=$(( $masa_aktif * 86400 ))
saat_expired=$(($today + $masa_aktif_detik))
tanggal_expired=$(date -u --date="1970-01-01 $saat_expired sec GMT" +%Y/%m/%d)
tanggal_expired_display=$(date -u --date="1970-01-01 $saat_expired sec GMT" '+%d %B %Y')

echo "Connecting to overses.net..."
sleep 0.4
echo "Creating Account..."
sleep 0.3
echo "Generating Host..."
sleep 0.2
echo "Creating Your New Username: $username"
sleep 0.2
echo "Creating Password for $username"
sleep 1


useradd $username
usermod -s /bin/false $username
usermod -e  $tanggal_expired $username
  egrep "^$username" /etc/passwd >/dev/null
  echo -e "$password\n$password" | passwd $username
  echo "Script by overses.net"
  echo "Terimakasih sudah berlangganan di overses.net"
  echo " "
  echo "Demikian Detail Account Yang Telah Dibuat"
  echo "---------------------------------------"
  echo "Host            : $MYIP"
  echo "Username        : $username"
  echo "Password        : $password"
  echo "Masa aktif      : $masa_aktif Hari"
  echo "Tanggal Expired : $tanggal_expired_display"
  echo "Dropbear Port   : 80, 109, 110, 443"
  echo "OpenSSH Por     : 22 , 143"
  echo "Squid Proxy     : 8080, 8000, 3128"
  echo "OpenVPN Config  : http://$MYIP:81/client.ovpn"
  echo "--------------------------------------"
fi