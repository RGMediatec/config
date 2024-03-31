#!/bin/bash
#
# Just a simple init script for new installations
#

cd ~

####################
# install Tool-Set
####################

apt update && apt install curl htop bpytop bmon screen tmux nethogs nload iftop nano neofetch ncdu nmon git unzip distro-info net-tools sysbench lshw smartmontools ethtool pv sysstat iotop sipcalc # mc termshark

# configure tmux

mkdir -p ~/.tmux
# get tmux plugin manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
wget -O ~/.tmux.conf https://raw.githubusercontent.com/RGMediatec/config/main/tmux/.tmux.conf
# install plugins automatically
~/.tmux/plugins/tpm/bin/install_plugins
curl https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux > ~/.bash_completion
source ~/.bash_completion

####################
# SSH CONFIG
####################

mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArKDvXiBMJ7QmccKV+p4CdCCsXlz2kXJ5P/XnKmEoa6 philipp@rgmediatec' >>  ~/.ssh/authorized_keys
sed -i 's/#\?\(PubkeyAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 prohibit-password/' /etc/ssh/sshd_config

systemctl restart sshd.service

####################
# Aliases
####################

wget -O ~/.bash_aliases https://raw.githubusercontent.com/RGMediatec/config/main/cfg/.bash_aliases
source ~/.bash_aliases




echo "initial config done. please reboot for safety :)"
