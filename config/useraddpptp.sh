           #!/bin/bash
            # Created by http://www.overses.net
            # Dilarang Keras Mengambil/mencuplik/mengcopy sebagian atau seluruh script ini.
            # Hak Cipta overses.net (Dilindungi Undang-Undang nomor 19 Tahun 2002)
            red='\e[1;31m'
            green='\e[0;32m'
            NC='\e[0m'
            echo "Connecting to overses.net..."
            sleep 0.2
            echo "Checking Permision..."
            sleep 0.3
            echo -e "${green}Permission Accepted...${NC}"
            sleep 1
            if [ -e "/var/lib/premium-script" ]; then
		    echo "continue..."
      	    else
		    mkdir /var/lib/premium-script;
            fi
            echo""
            read -p "Masukkan Username : " username
            grep -E "^$username" /etc/ppp/chap-secrets >/dev/null
            if [ $? -eq 0 ]; then
            echo "Username sudah ada di VPS anda"
            exit 0
            else
            read -p "Masukkan Password : " password
            read -p "Masukkan Lama Masa Aktif Account(Hari): " masa_aktif

            today=`date +%s`
            masa_aktif_detik=$(( $masa_aktif * 86400 ))
            saat_expired=$(($today + $masa_aktif_detik))
            tanggal_expired=$(date -u --date="1970-01-01 $saat_expired sec GMT" +%Y/%m/%d)
            tanggal_expired_display=$(date -u --date="1970-01-01 $saat_expired sec GMT" '+%d %B %Y')
            echo "Connecting to overses.net..."
            sleep 0.5
            echo "Creating Account..."
            sleep 0.2
            echo "Generating Host..."
            sleep 0.2
            echo "Creating Your New Username: $username"
            sleep 0.2
            echo "Creating Password for $username"
            sleep 0.3
            MYIP=$(wget -qO- ipv4.icanhazip.com)
            echo "$username	*	$password	*" >> /etc/ppp/chap-secrets
            echo "$username *   $password   *  $saat_expired"  >> /var/lib/premium-script/data-user-pptp
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
            echo "Dropbear Port   : 109, 110, 443"
            echo "OpenSSH Port    : 22 , 143"
            echo "Squid Proxy     : 8080, 8000, 80, 3128"
            echo "OpenVPN Config  : http://$MYIP:81/client.ovpn"
            echo "--------------------------------------"
            fi