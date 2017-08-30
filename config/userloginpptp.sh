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

last | grep ppp | grep still | awk '{print " ",$1," - " $3 }' > /tmp/login-db-pptp.txt;
echo "Script by overses.net"
echo "Terimakasih sudah berlangganan di overses.net"
echo""
echo "===============================================";
echo " "
echo " "
echo "Memeriksa User PPTP VPN Yang Login";
echo "(Username - IP)";
echo "-------------------------------------";
cat /tmp/login-db-pptp.txt
echo " "
echo " "
echo " "
echo "===============================================";