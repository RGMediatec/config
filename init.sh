#!/bin/bash
#
# Just a simple init script for new installations
#

cd ~

####################
#	install Tool-Set
####################

apt update && apt install curl htop bpytop bmon screen tmux nethogs nload iftop nano neofetch ncdu nnn nmon git unzip distro-info net-tools sysbench 
mc lshw smartmontools ethtool pv sysstat iotop termshark sipcalc

# configure tmux

mkdir -p ~/.tmux
# get tmux plugin manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

wget -O ~/.tmux.conf https://raw.githubusercontent.com/RGMediatec/config/main/tmux/.tmux.conf

# install sysadmin-utils

git clone https://github.com/skx/sysadmin-util.git

####################
# SSH CONFIG
####################

mkdir -p ~/.ssh && nano ~/.ssh/authorized_keys

sed -i '$assh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArKDvXiBMJ7QmccKV+p4CdCCsXlz2kXJ5P/XnKmEoa6 philipp@rgmediatec' ~/.ssh/authorized_keys

sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config

systemctl restart sshd.service

#
# Aliases
#

 wget -O ~/.bash_aliases https://raw.githubusercontent.com/RGMediatec/config/main/cfg/.bash_aliases
