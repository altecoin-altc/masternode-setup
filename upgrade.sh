#!/bin/bash

if [[ $(lsb_release -d) = *16.04* ]]; then
  COINZIP='https://github.com/altecoin-altc/altecoin/releases/download/v1.1/altecoin_ubuntu16_v1.1.zip'
fi
if [[ $(lsb_release -d) = *18.04* ]]; then
  COINZIP='https://github.com/altecoin-altc/altecoin/releases/download/v1.1/altecoin_ubuntu18_v1.1.zip'
fi

echo "Stopping Altecoin service"
systemctl stop altecoin.service
echo "Altecoin service stopped"
sleep 1

echo "Remove old daemon and cli files"
rm /usr/local/bin/altecoind
rm /usr/local/bin/altecoin-cli
echo "Old files removed"
sleep 1

echo "Download new release"
cd /usr/local/bin/
wget $COINZIP
unzip *.zip
chmod +x altecoin*
rm altecoin-qt altecoin-tx *.zip
sleep 1

echo "Starting Altecoin service"
systemctl start altecoin.service
echo "Upgrade done"

echo "============================================================"
echo "Contact support in discord if this upgrade is not successful"
echo "https://discord.gg/ZHFKwhtGch"
echo "============================================================"
