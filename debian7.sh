#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;

flag=0

if [[ $USER != "root" ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi

#iplist="ip.txt"

wget --quiet -O iplist.txt https://raw.githubusercontent.com/elhad/cstup/master/ip.txt

#if [ -f iplist ]
#then

iplist="iplist.txt"

lines=`cat $iplist`
#echo $lines

for line in $lines; do
#        echo "$line"
        if [ "$line" = "$myip" ]
        then
                flag=1
        fi

done


if [ $flag -eq 0 ]
then
   echo  "Maaf, hanya IP yang terdaftar yang bisa menggunakan script ini!
		  Hubungi: Yujin Barboza (fb.com/jordhia atau 087775474442)"
   exit 1
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0'`;
MYIP2="s/xxxxxxxxx/$MYIP/g";

# go to root
cd

echo "==========================================="
echo "            Installasi Dimulai             "
echo "==========================================="

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update
apt-get -y install wget curl
sudo apt-get install ca-certificates

# Change to Time GMT+7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -q -O /etc/apt/sources.list https://raw.githubusercontent.com/elhad/cstup/master/sources.list.debian7
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update 
apt-get -y upgrade

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
apt-get -y install nmap nano iptables sysv-rc-conf openvpn vnstat apt-file
apt-get -y install libexpat1-dev libxml-parser-perl
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# Setting Vnstat
vnstat -u -i eth0
chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

# install screenfetch
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch-dev
chmod +x /usr/bin/screenfetch-dev
echo "clear" >> .profile
echo "screenfetch-dev" >> .profile

# Install Web Server
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/elhad/cstup/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Ibnu Fachrizal</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/elhad/cstup/master/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/elhad/cstup/master/openvpn.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/elhad/cstup/master/1194-debian.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.up.rules "https://raw.githubusercontent.com/elhad/cstup/master/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i 's/port 1194/port 1194/g' /etc/openvpn/1194.conf
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart

#konfigurasi openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/elhad/cstup/master/1194-client.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false admin_ibnu
echo "admin_ibnu:$PASS" | chpasswd
cp client.ovpn /home/vps/public_html/

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/elhad/cstup/master/badvpn-udpgw"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

#install PPTP
apt-get -y install pptpd
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
nodefaultroute
lock
nobsdcomp
END

cat > /etc/pptpd.conf <<END
option /etc/ppp/pptpd-options
logwtmp
localip 10.1.0.1
remoteip 10.1.0.5-100
END

cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END
mkdir /var/lib/premium-script
/etc/init.d/pptpd restart

# install mrtg
apt-get -y install snmpd;
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/elhad/cstup/master/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/elhad/cstup/master/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/elhad/cstup/master/mrtg.conf" >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110 -p 443 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="bannerssh"/g' /etc/default/dropbear
service ssh restart
service dropbear restart

# upgrade dropbear 2017
apt-get install zlib1g-dev
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2017.75.tar.bz2
bzip2 -cd dropbear-2017.75.tar.bz2  | tar xvf -
cd dropbear-2017.75
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget https://raw.githubusercontent.com/elhad/cstup/master/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
sed -i "s/\$locale = 'en_US.UTF-8';/\$locale = 'en_US.UTF+8';/g" config.php
cd

# block all port except
sed -i '$ i\iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -d 127.0.0.1 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 21 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 81 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 109 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 110 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 143 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 1194 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 3128 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 8000 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 8080 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 10000 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p udp -m udp --dport 2500 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p udp -m udp -j DROP' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp -j DROP' /etc/rc.local


# install fail2ban
apt-get -y install fail2ban;
service fail2ban restart

# install squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/elhad/cstup/master/squid.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.840_all.deb"
dpkg --install webmin_1.840_all.deb;
apt-get -y -f install;
rm /root/webmin_1.840_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart
service vnstat restart

# install figlet
apt-get -y install figlet

# User Status
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/user-list.sh
mv ./user-list.sh /usr/local/bin/user-list.sh
chmod +x /usr/local/bin/user-list.sh

# Install Dos Deflate
apt-get -y install dnsutils dsniff
wget https://raw.githubusercontent.com/elhad/cstup/master/ddos-deflate-master.zip
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh
cd

# instal UPDATE SCRIPT
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/update.sh
mv ./update.sh /usr/bin/update.sh
chmod +x /usr/bin/update.sh

# instal Buat Akun SSH/OpenVPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/buatakun.sh
mv ./buatakun.sh /usr/bin/buatakun.sh
chmod +x /usr/bin/buatakun.sh

# instal Generate Akun SSH/OpenVPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/generate.sh
mv ./generate.sh /usr/bin/generate.sh
chmod +x /usr/bin/generate.sh

# instal Generate Akun Trial
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/trial.sh
mv ./trial.sh /usr/bin/trial.sh
chmod +x /usr/bin/trial.sh

# instal  Ganti Password Akun SSH/VPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userpass.sh
mv ./userpass.sh /usr/bin/userpass.sh
chmod +x /usr/bin/userpass.sh

# instal Generate Akun SSH/OpenVPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userrenew.sh
mv ./userrenew.sh /usr/bin/userrenew.sh
chmod +x /usr/bin/userrenew.sh

# instal Hapus Akun SSH/OpenVPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userdelete.sh
mv ./userdelete.sh /usr/bin/userdelete.sh
chmod +x /usr/bin/userdelete.sh

# instal Cek Login Dropbear, OpenSSH & OpenVPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userlogin.sh
mv ./userlogin.sh /usr/bin/userlogin.sh
chmod +x /usr/bin/userlogin.sh

# instal Auto Limit Multi Login
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/autolimit.sh
mv ./autolimit.sh /usr/bin/autolimit.sh
chmod +x /usr/bin/autolimit.sh

# instal Auto Limit Script Multi Login
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/auto-limit-script.sh
mv ./auto-limit-script.sh /usr/local/bin/auto-limit-script.sh
chmod +x /usr/local/bin/auto-limit-script.sh

# instal Melihat detail user SSH & OpenVPN 
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userdetail.sh
mv ./userdetail.sh /usr/bin/userdetail.sh
chmod +x /usr/bin/userdetail.sh

# instal Delete Akun Expire
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/deleteuserexpire.sh
mv ./deleteuserexpire.sh /usr/bin/deleteuserexpire.sh
chmod +x /usr/bin/deleteuserexpire.sh

# instal  Kill Multi Login
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/autokilluser.sh
mv ./autokilluser.sh /usr/bin/autokilluser.sh
chmod +x /usr/bin/autokilluser.sh

# instal  Kill Multi Login2
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/autokill.sh
mv ./autokill.sh /usr/bin/autokill.sh
chmod +x /usr/bin/autokill.sh

# instal Auto Banned Akun
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userban.sh
mv ./userban.sh /usr/bin/userban.sh
chmod +x /usr/bin/userban.sh

# instal Unbanned Akun
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userunban.sh
mv ./userunban.sh /usr/bin/userunban.sh
chmod +x /usr/bin/userunban.sh

# instal Mengunci Akun SSH & OpenVPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userlock.sh
mv ./userlock.sh /usr/bin/userlock.sh
chmod +x /usr/bin/userlock.sh

# instal Membuka user SSH & OpenVPN yang terkunci
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userunlock.sh
mv ./userunlock.sh /usr/bin/userunlock.sh
chmod +x /usr/bin/userunlock.sh

# instal Melihat daftar user yang terkick oleh perintah user-limit
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/loglimit.sh
mv ./loglimit.sh /usr/bin/loglimit.sh
chmod +x /usr/bin/loglimit.sh

# instal Melihat daftar user yang terbanned oleh perintah user-ban
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/logban.sh
mv ./logban.sh /usr/bin/logban.sh
chmod +x /usr/bin/logban.sh

# instal Buat Akun PPTP VPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/useraddpptp.sh
mv ./useraddpptp.sh /usr/bin/useraddpptp.sh
chmod +x /usr/bin/useraddpptp.sh

# instal Hapus Akun PPTP VPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userdeletepptp.sh
mv ./userdeletepptp.sh /usr/bin/userdeletepptp.sh
chmod +x /usr/bin/userdeletepptp.sh

# instal Lihat Detail Akun PPTP VPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/detailpptp.sh
mv ./detailpptp.sh /usr/bin/detailpptp.sh
chmod +x /usr/bin/detailpptp.sh

# instal Cek login PPTP VPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userloginpptp.sh
mv ./userloginpptp.sh /usr/bin/userloginpptp.sh
chmod +x /usr/bin/userloginpptp.sh

# instal Lihat Daftar User PPTP VPN
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/alluserpptp.sh
mv ./alluserpptp.sh /usr/bin/alluserpptp.sh
chmod +x /usr/bin/alluserpptp.sh

# instal Set Auto Reboot
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/autoreboot.sh
mv ./autoreboot.sh /usr/bin/autoreboot.sh
chmod +x /usr/bin/autoreboot.sh

# Install SPEED tES
cd
apt-get install python
wget https://raw.githubusercontent.com/elhad/cstup/master/config/speedtest.py.sh
mv ./speedtest.py.sh /usr/bin/speedtest.py.sh
chmod +x /usr/bin/speedtest.py.sh

# instal autolimitscript
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/auto-limit-script.sh
mv ./auto-limit-script.sh /usr/bin/auto-limit-script.sh
chmod +x /usr/bin/auto-limit-script.sh

# instal userdelete
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/userdelete.sh
mv ./userdelete.sh /usr/bin/userdelete.sh
chmod +x /usr/bin/userdelete.sh

# instal diagnosa
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/diagnosa.sh
mv ./diagnosa.sh /usr/bin/diagnosa.sh
chmod +x /usr/bin/diagnosa.sh

# instal ram
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/ram.sh
mv ./ram.sh /usr/bin/ram.sh
chmod +x /usr/bin/ram.sh

# log install
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/log-install.sh
mv ./log-install.sh /usr/bin/log-install.sh
chmod +x /usr/bin/log-install.sh

# edit ubah-port
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/ubahport.sh
mv ./ubahport.sh /usr/bin/ubahport.sh
chmod +x /usr/bin/ubahport.sh

# edit-port-dropbear
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/edit-port-dropbear.sh
mv ./edit-port-dropbear.sh /usr/bin/edit-port-dropbear.sh
chmod +x /usr/bin/edit-port-dropbear.sh

# edit-port-openssh
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/edit-port-openssh.sh
mv ./edit-port-openssh.sh /usr/bin/edit-port-openssh.sh
chmod +x /usr/bin/edit-port-openssh.sh

# edit-port-openvpn
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/edit-port-openvpn.sh
mv ./edit-port-openvpn.sh /usr/bin/edit-port-openvpn.sh
chmod +x /usr/bin/edit-port-openvpn.sh

# edit-port-openvpn
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/edit-port-squid.sh
mv ./edit-port-squid.sh /usr/bin/edit-port-squid.sh
chmod +x /usr/bin/edit-port-squid.sh

# restart
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/restart.sh
mv ./restart.sh /usr/bin/restart.sh
chmod +x /usr/bin/restart.sh

# restart-dropbear
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/restart-dropbear.sh
mv ./restart-dropbear.sh /usr/bin/restart-dropbear.sh
chmod +x /usr/bin/restart-dropbear.sh

# restart-squid
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/restart-squid.sh
mv ./restart-squid.sh /usr/bin/restart-squid.sh
chmod +x /usr/bin/restart-squid.sh

# restart-openvpn
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/restart-openvpn.sh
mv ./restart-openvpn.sh /usr/bin/restart-openvpn.sh
chmod +x /usr/bin/restart-openvpn.sh

# restart-webmin
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/restart-webmin.sh
mv ./restart-webmin.sh /usr/bin/restart-webmin.sh
chmod +x /usr/bin/restart-webmin.sh

# disable-user-expire
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/config/disable-user-expire.sh
mv ./disable-user-expire.sh /usr/bin/disable-user-expire.sh
chmod +x /usr/bin/disable-user-expire.sh

# bannerssh
wget https://raw.githubusercontent.com/elhad/cstup/master/config/bannerssh
mv ./bannerssh /bannerssh
chmod 0644 /bannerssh
service dropbear restart
service ssh restart

# Install Menu
cd
wget https://raw.githubusercontent.com/elhad/cstup/master/menu
mv ./menu /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# download script
cd
wget -q -O /usr/bin/welcomeadmin https://raw.githubusercontent.com/elhad/cstup/master/welcome.sh
echo "00 23 * * * root /usr/bin/disable-user-expire.sh" > /etc/cron.d/disable-user-expire.sh
wget -O /etc/bannerssh "https://raw.githubusercontent.com/elhad/cstup/master/config/bannerssh"
echo "0 0 * * * root /root/deleteuserexpire.sh" > /etc/cron.d/deleteuserexpire
echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "* * * * * service dropbear restart" > /etc/cron.d/dropbear

# Admin Welcome
chmod +x /usr/bin/welcomeadmin
echo "welcomeadmin" >> .profile

# swap ram
dd if=/dev/zero of=/swapfile bs=2048 count=2048k
# buat swap
mkswap /swapfile
# jalan swapfile
swapon /swapfile
#auto start saat reboot
wget https://raw.githubusercontent.com/elhad/cstup/master/fstab
mv ./fstab /etc/fstab
chmod 644 /etc/fstab
sysctl vm.swappiness=10
#permission swapfile
chown root:root /swapfile 
chmod 0600 /swapfile
cd

# Restart Service
chown -R www-data:www-data /home/vps/public_html
service cron restart
service nginx start
service vnstat restart
service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
service pptpd restart

cd
rm -f /root/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Setup by Yujin Barboza"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "OpenSSH  : 22, 143"  | tee -a log-install.txt
echo "Dropbear : 80, 109, 110, 443"  | tee -a log-install.txt
echo "Squid3   : 8080, 8000, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "axel"    | tee -a log-install.txt
echo "bmon"    | tee -a log-install.txt
echo "htop"    | tee -a log-install.txt
echo "iftop"    | tee -a log-install.txt
echo "mtr"    | tee -a log-install.txt
echo "rkhunter"    | tee -a log-install.txt
echo "nethogs: nethogs venet0"    | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP:81/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "VPS REBOOT TIAP JAM 00.00 !"  | tee -a log-install.txt
echo""  | tee -a log-install.txt
echo "Please Reboot your VPS !"  | tee -a log-install.txt
echo "================================================"  | tee -a log-install.txt
echo "Script Created By Yujin Barboza"  | tee -a log-install.txt
echo "Terimakasih telah berlangganan di www.overses.net"  | tee -a log-install.txt
cd ~/
rm -f /root/debian7.sh
rm -f /root/pptp.sh
rm -f /root/speedtest.py.sh
rm -rf /root/mrtg-mem.sh
rm -rf /root/dropbear-2017.75.tar.bz2
rm -rf /root/ddos-deflate-master.zip
rm -f /root/iplist.txt
