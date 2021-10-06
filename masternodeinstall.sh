#!/bin/bash

PORT=7429
RPCPORT=7430
CONF_DIR=~/.altecoin

cd ~
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
if [[ $(lsb_release -d) = *16.04* ]]; then
  COINZIP='https://github.com/altecoin-altc/altecoin/releases/download/v1.0/altecoin_ubuntu16_v1.0.zip'
fi
if [[ $(lsb_release -d) = *18.04* ]]; then
  COINZIP='https://github.com/altecoin-altc/altecoin/releases/download/v1.0/altecoin_ubuntu18_v1.0.zip'
fi
if [[ $(lsb_release -d) = *20.04* ]]; then
  COINZIP='https://github.com/altecoin-altc/altecoin/releases/download/v1.0/altecoin_ubuntu20_v1.0.zip'
fi
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
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get update && apt-get dist-upgrade -y && apt install nano htop -y && apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev -y && apt-get install libboost-all-dev git libminiupnpc-dev -y && apt-get install software-properties-common -y && apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl bsdmainutils libminiupnpc-dev libgmp3-dev pkg-config libevent-dev unzip && sudo add-apt-repository ppa:bitcoin/bitcoin -y && sudo apt-get update -y && sudo apt-get install libdb4.8-dev libdb4.8++-dev -y && sudo apt-get install make automake cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 -y && sudo apt-get install curl librsvg2-bin libtiff-tools bsdmainutils cmake imagemagick libcap-dev libz-dev libbz2-dev python-setuptools -y && apt-get install libzmq3-dev -y && apt-get install libdb5.3++-dev iotop -y && sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && sudo apt-get update -y && sudo apt-get upgrade libstdc++6 -y

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd
  
  cd /usr/local/bin/
  wget $COINZIP
  unzip *.zip
  chmod +x altecoin*
  rm altecoin-qt altecoin-tx *.zip
  
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
  echo "dbcache=20" >> altecoin.conf_TEMP
  echo "maxorphantx=5" >> altecoin.conf_TEMP
  echo "maxmempool=100" >> altecoin.conf_TEMP
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