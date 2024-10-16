#!/bin/bash

PORT=7429
RPCPORT=7430
CONF_DIR=~/.altecoin
COINZIP='https://github.com/altecoin-altc/altecoin/releases/download/v1.3.1/altecoin-linux.zip'

cd ~
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

function configure_systemd {
  cat << EOF > /etc/systemd/system/altecoin.service
[Unit]
Description=ALtecoin Service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/altecoind
ExecStop=-/usr/local/bin/altecoin-cli stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  sleep 2
  systemctl enable altecoin.service
  systemctl start altecoin.service
}

echo ""
echo ""
DOSETUP="y"

if [ $DOSETUP = "y" ]  
then
  apt-get update
  apt install zip unzip git curl wget -y
  cd /usr/local/bin/
  wget $COINZIP
  unzip *.zip
  rm altecoin-qt altecoin-tx altecoin-linux.zip
  chmod +x altecoin*
  
  mkdir -p $CONF_DIR
  cd $CONF_DIR
  wget http://cdn.delion.xyz/altc.zip
  unzip altc.zip
  rm altc.zip

fi

 IP=$(curl -s4 api.ipify.org)
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"
 echo ""
 echo "Enter masternode private key"
 read PRIVKEY
 
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> altecoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> altecoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> altecoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> altecoin.conf_TEMP
  echo "listen=1" >> altecoin.conf_TEMP
  echo "server=1" >> altecoin.conf_TEMP
  echo "daemon=1" >> altecoin.conf_TEMP
  echo "maxconnections=250" >> altecoin.conf_TEMP
  echo "masternode=1" >> altecoin.conf_TEMP
  echo "" >> altecoin.conf_TEMP
  echo "port=$PORT" >> altecoin.conf_TEMP
  echo "externalip=$IP:$PORT" >> altecoin.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> altecoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> altecoin.conf_TEMP
  mv altecoin.conf_TEMP altecoin.conf
  cd
  echo ""
  echo -e "Your ip is ${GREEN}$IP:$PORT${NC}"

	## Config Systemctl
	configure_systemd
  
echo ""
echo "Commands:"
echo -e "Start Altecoin Service: ${GREEN}systemctl start altecoin${NC}"
echo -e "Check Altecoin Status Service: ${GREEN}systemctl status altecoin${NC}"
echo -e "Stop Altecoin Service: ${GREEN}systemctl stop altecoin${NC}"
echo -e "Check Masternode Status: ${GREEN}altecoin-cli getmasternodestatus${NC}"

echo ""
echo -e "${GREEN}Altecoin Masternode Installation Done${NC}"
exec bash
exit
