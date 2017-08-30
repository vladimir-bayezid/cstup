            #!/bin/bash
            # Created by http://www.overses.net
            # Dilarang Keras Mengambil/mencuplik/mengcopy sebagian atau seluruh script ini.
            # Hak Cipta OVERSES.NET (Dilindungi Undang-Undang nomor 19 Tahun 2002)
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

            IP=$(wget -qO- ipv4.icanhazip.com)
            read -p "Berapa jumlah account yang akan dibuat: " banyakuser
            read -p "Masukkan lama masa aktif account(Hari): " aktif
            today="$(date +"%Y-%m-%d")"
            expire=$(date -d "$aktif days" +"%Y-%m-%d")
            
            echo""
            echo "Script by overses.net"
            echo "Terimakasih sudah berlangganan di overses.net"
            echo " "
            echo "Detail Account"
            echo "----------------------------------"
            echo "Host/IP         : $IP"
            echo "Dropbear Port   : 80, 109, 110, 443"
            echo "OpenSSH Port    : 22 , 143"
            echo "Squid Proxy     : 8080, 8000, 3128"
            echo "OpenVPN Config  : http://$IP:81/client.ovpn"
            echo "Aktif Sampai    : $(date -d "$aktif days" +"%d-%m-%Y")"
            echo "----------------------------------"
            for (( i=1; i <= $banyakuser; i++ ))
            do
         	USER=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`
        	useradd -M -N -s /bin/false -e $expire $USER
        	PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
        	echo $USER:$USER | chpasswd
	        echo "$i. Username/Password: $USER"
            done

            echo "----------------------------------"