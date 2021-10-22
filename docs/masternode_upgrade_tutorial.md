# How to upgrade Altecoin daemon on VPS

# Prerequisite

1. This script is meant to upgrade Altecoin node on VPS Linux Ubuntu 16.04 and 18.04
2. Assume that you made installation of Altecoin masternode using official installation script https://github.com/altecoin-altc/masternode-setup/blob/main/masternodeinstall.sh
3. Don't run this script if you did the installation manually or other scripts.

# Using the upgrade script

Connect to your linux vps, copy and paste the following line into your VPS. Double click to highlight the entire line, copy it, and right click into Putty or Shift + Insert to paste or other button combinations depends on the shell application or your system operation.
```
bash <( curl -sL https://raw.githubusercontent.com/altecoin-altc/masternode-setup/main/upgrade.sh)
```

# Checking Masternode Status

1. Enter ```cd``` to get back to your root directory
2. Enter ```altecoin-cli getmasternodestatus```
3. This will tell you the status of your masternode. If the masternode is missing, please start it again from your wallet. Protocol version upgrade always requires masternode restart.
4. Any questions, Join discord for help: https://discord.gg/ZHFKwhtGch

# Recommended Tools

- Putty - Easy to use and customizable SSH client.
- SuperPutty - This allows you to have multiple Putty tabs open in one window, allowing you to easily organize and switch between masternode servers.