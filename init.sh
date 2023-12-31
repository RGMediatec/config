#!/bin/bash
#
# Just a simple init script for new installations
#


####################
#	install Tool-Set
####################

apt update && apt install curl htop bpytop bmon screen tmux nethogs nload iftop nano neofetch ncdu nnn nmon git unzip distro-info net-tools sysbench 
mc lshw smartmontools ethtool pv sysstat iotop termshark sipcalc

# configure tmux

mkdir -p ~/.tmux
# get tmux plugin manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
