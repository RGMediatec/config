#
# ~/.bash_aliases
#
# Personal aliases and helper functions
#

####################
# Privileges
####################

alias root='sudo -i'

# Repeat the previous command with sudo.
please() {
    local previous_command

    previous_command="$(fc -ln -1)"

    if [[ -z "$previous_command" ]]; then
        echo "Kein vorheriger Befehl gefunden."
        return 1
    fi

    sudo bash -c "$previous_command"
}

alias ims='please'


####################
# Terminal
####################

alias c='clear'
alias h='history'

# Search shell history.
#
# Example:
#   hg docker
#   hg "apt install"
hg() {
    if [[ $# -eq 0 ]]; then
        echo "Verwendung: hg SUCHBEGRIFF"
        return 1
    fi

    history | grep --color=auto -i -- "$*"
}

# Show all currently active aliases.
alias al='printf "%s\n" "------------ Aktive Aliases ------------"; alias'


####################
# Navigation
####################

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias 1d='cd ..'
alias 2d='cd ../..'
alias 3d='cd ../../..'
alias 4d='cd ../../../..'
alias 5d='cd ../../../../..'


####################
# File listings
####################

alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias lf='ls -alF'
alias lt='ls -lht'
alias lsize='ls -lhS'
alias ld='ls -d -- */'
alias list='ls -lah'

# Show directory sizes sorted from small to large.
alias lu='du -sh -- * 2>/dev/null | sort -h'

# Count files recursively below the current directory.
alias lc='find . -type f | wc -l'


####################
# Files and search
####################

# Basic find shortcut.
#
# Example:
#   fh "*.conf"
fh() {
    if [[ $# -eq 0 ]]; then
        echo "Verwendung: fh DATEINAME_ODER_MUSTER"
        return 1
    fi

    find . -name "$1"
}

# Recursive plain-text search.
#
# Examples:
#   rgrep "mail1.rgmediatec.cloud"
#   rgrep "PasswordAuthentication" /etc
rgrep() {
    if [[ $# -lt 1 ]]; then
        echo "Verwendung: rgrep SUCHTEXT [VERZEICHNIS]"
        return 1
    fi

    local search="$1"
    local directory="${2:-.}"

    grep -Rni \
        --color=auto \
        --exclude-dir=.git \
        -- "$search" "$directory"
}

# Recursive extended-regex search.
#
# Examples:
#   rgrepe "error|warning|fatal" /var/log
#   rgrepe "ssid|wifi|repeater" .
rgrepe() {
    if [[ $# -lt 1 ]]; then
        echo "Verwendung: rgrepe REGEX [VERZEICHNIS]"
        return 1
    fi

    local search="$1"
    local directory="${2:-.}"

    grep -RniE \
        --color=auto \
        --exclude-dir=.git \
        -- "$search" "$directory"
}


####################
# Archives
####################

# Create a gzip-compressed tar archive.
#
# Example:
#   mktar backup.tar.gz /etc/stalwart /root/scripts
mktar() {
    if [[ $# -lt 2 ]]; then
        echo "Verwendung: mktar ARCHIV.tar.gz DATEI_ODER_VERZEICHNIS [...]"
        return 1
    fi

    local archive="$1"
    shift

    tar -czvf "$archive" "$@"
}

# Extract most archive formats supported by tar.
#
# Example:
#   untar backup.tar.gz
untar() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: untar ARCHIV"
        return 1
    fi

    if [[ ! -f "$1" ]]; then
        echo "Datei nicht gefunden: $1"
        return 1
    fi

    tar -xvf "$1"
}


####################
# Disk and resources
####################

alias df='df -Tha --total'
alias duh='du -h --max-depth=1 2>/dev/null | sort -h'
alias mem='free -h'
alias cpu='lscpu'
alias disks='lsblk -o NAME,SIZE,FSTYPE,FSAVAIL,FSUSE%,MOUNTPOINTS,MODEL'
alias mounts='findmnt'
alias block='lsblk -f'

# Interactive disk usage.
alias diskusage='ncdu'

# Show the largest files and directories below the current directory.
alias biggest='du -ah . 2>/dev/null | sort -rh | head -n 30'


####################
# Package management
####################

alias au='sudo apt update'
alias aug='sudo apt update && sudo apt upgrade'
alias auf='sudo apt update && sudo apt full-upgrade'
alias aar='sudo apt autoremove'
alias aac='sudo apt autoclean'
alias aup='apt list --upgradable'
alias ai='sudo apt install'
alias ar='sudo apt remove'
alias ap='sudo apt purge'
alias ase='apt search'
alias ash='apt show'

# Update package lists and show pending upgrades.
alias updatecheck='sudo apt update && apt list --upgradable'


####################
# systemd
####################

alias sc='systemctl'
alias scs='systemctl status'
alias scr='sudo systemctl restart'
alias scl='sudo systemctl reload'
alias scstart='sudo systemctl start'
alias scstop='sudo systemctl stop'
alias scenable='sudo systemctl enable'
alias scdisable='sudo systemctl disable'
alias scf='systemctl --failed'
alias services='systemctl list-units --type=service --state=running'

# Show a service and its latest log entries.
#
# Example:
#   svc postfix
svc() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: svc DIENST"
        return 1
    fi

    systemctl status "$1" --no-pager
    echo
    journalctl -u "$1" -n 30 --no-pager
}


####################
# Journal and logs
####################

alias j='journalctl'
alias jf='journalctl -f'
alias jxe='journalctl -xe'
alias jwarn='journalctl -p warning'
alias jerr='journalctl -p err'
alias jcrit='journalctl -p crit'
alias jtoday='journalctl --since today'
alias jboot='journalctl -b'
alias jboots='journalctl --list-boots'

# Show logs for a systemd service.
#
# Examples:
#   ju postfix
#   ju postfix --since today
ju() {
    if [[ $# -lt 1 ]]; then
        echo "Verwendung: ju DIENST [JOURNALCTL-OPTIONEN]"
        return 1
    fi

    local service="$1"
    shift

    journalctl -u "$service" "$@"
}

# Follow logs for a service.
#
# Example:
#   juf fail2ban
juf() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: juf DIENST"
        return 1
    fi

    journalctl -u "$1" -f
}

# Show the last log lines for a service.
#
# Example:
#   jul postfix 100
jul() {
    if [[ $# -lt 1 ]]; then
        echo "Verwendung: jul DIENST [ANZAHL]"
        return 1
    fi

    local service="$1"
    local lines="${2:-50}"

    journalctl -u "$service" -n "$lines" --no-pager
}


####################
# Network information
####################

alias ipa='ip addr'
alias ip4='ip -4 addr'
alias ip6='ip -6 addr'
alias links='ip -br link'
alias ips='ip -br addr'
alias routes='ip route'
alias routes4='ip -4 route'
alias routes6='ip -6 route'
alias neigh='ip neigh'
alias neigh6='ip -6 neigh'

alias ports='sudo ss -tulpn'
alias tcpports='sudo ss -ltnp'
alias udpports='sudo ss -lunp'
alias connections='ss -tunap'
alias listening='sudo lsof -nP -iTCP -sTCP:LISTEN'

alias dns='resolvectl status'
alias get='wget -c'

alias myip4='curl -4 -fsS https://api.ipify.org; echo'
alias myip6='curl -6 -fsS https://api64.ipify.org; echo'

# Test whether a TCP port is reachable.
#
# Example:
#   portcheck mail1.example.com 993
portcheck() {
    if [[ $# -ne 2 ]]; then
        echo "Verwendung: portcheck HOST PORT"
        return 1
    fi

    nc -vz "$1" "$2"
}

# Show the HTTP status code.
#
# Example:
#   httpcode https://example.com
httpcode() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: httpcode URL"
        return 1
    fi

    curl -sS \
        -o /dev/null \
        -w '%{http_code}\n' \
        "$1"
}

# Show HTTP headers.
#
# Example:
#   headers https://example.com
headers() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: headers URL"
        return 1
    fi

    curl -sSIL "$1"
}

# Run an MTR report.
#
# Example:
#   mtrr example.com
mtrr() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: mtrr HOST"
        return 1
    fi

    mtr \
        --report \
        --report-cycles 10 \
        --show-ips \
        "$1"
}

# Capture traffic on a specific port.
#
# Example:
#   tcpport 443
tcpport() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: tcpport PORT"
        return 1
    fi

    sudo tcpdump -nn -i any port "$1"
}

# Capture traffic to or from a host.
#
# Example:
#   tcphost 192.168.8.10
tcphost() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: tcphost HOST_ODER_IP"
        return 1
    fi

    sudo tcpdump -nn -i any host "$1"
}


####################
# DNS queries
####################

diga() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: diga DOMAIN"
        return 1
    fi

    dig +short A "$1"
}

digaaaa() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: digaaaa DOMAIN"
        return 1
    fi

    dig +short AAAA "$1"
}

digmx() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: digmx DOMAIN"
        return 1
    fi

    dig +short MX "$1"
}

digtxt() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: digtxt DOMAIN"
        return 1
    fi

    dig +short TXT "$1"
}

digptr() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: digptr IP"
        return 1
    fi

    dig +short -x "$1"
}

digall() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: digall DOMAIN"
        return 1
    fi

    echo "A:"
    dig +short A "$1"

    echo
    echo "AAAA:"
    dig +short AAAA "$1"

    echo
    echo "MX:"
    dig +short MX "$1"

    echo
    echo "TXT:"
    dig +short TXT "$1"
}


####################
# TLS certificates
####################

# Show basic certificate information.
#
# Examples:
#   certcheck example.com
#   certcheck mail1.example.com 993
certcheck() {
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        echo "Verwendung: certcheck HOST [PORT]"
        return 1
    fi

    local host="$1"
    local port="${2:-443}"

    echo |
        openssl s_client \
            -connect "${host}:${port}" \
            -servername "$host" \
            2>/dev/null |
        openssl x509 \
            -noout \
            -subject \
            -issuer \
            -serial \
            -dates \
            -ext subjectAltName
}

# SMTP STARTTLS certificate test.
#
# Example:
#   smtpcert mail1.example.com 587
smtpcert() {
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        echo "Verwendung: smtpcert HOST [PORT]"
        return 1
    fi

    local host="$1"
    local port="${2:-587}"

    openssl s_client \
        -connect "${host}:${port}" \
        -starttls smtp \
        -servername "$host"
}


####################
# JSON
####################

alias json='jq .'

# Pretty-print a JSON file.
#
# Example:
#   jsonfile config.json
jsonfile() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: jsonfile DATEI.json"
        return 1
    fi

    jq . "$1"
}


####################
# File transfer
####################

alias rsyncp='rsync -ah --info=progress2'

# Copy a file or directory using rsync with progress.
#
# Example:
#   rscp /source/ user@server:/target/
rscp() {
    if [[ $# -ne 2 ]]; then
        echo "Verwendung: rscp QUELLE ZIEL"
        return 1
    fi

    rsync \
        -aHAX \
        --info=progress2 \
        "$1" "$2"
}


####################
# Docker
####################

alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dn='docker network ls'
alias dv='docker volume ls'
alias dstats='docker stats'
alias ddf='docker system df'

alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcp='docker compose ps'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
alias dcc='docker compose config'
alias dcpull='docker compose pull'
alias dcupdate='docker compose pull && docker compose up -d'

# Follow the last 100 log lines of a container.
#
# Example:
#   dlog stalwart
dlog() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: dlog CONTAINER"
        return 1
    fi

    docker logs \
        --tail 100 \
        -f \
        "$1"
}

# Open /bin/sh in a container.
#
# Example:
#   dsh stalwart
dsh() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: dsh CONTAINER"
        return 1
    fi

    docker exec -it "$1" /bin/sh
}

# Open /bin/bash in a container.
#
# Example:
#   dbash stalwart
dbash() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: dbash CONTAINER"
        return 1
    fi

    docker exec -it "$1" /bin/bash
}

# Show all container IP addresses.
#
# Example:
#   dip stalwart
dip() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: dip CONTAINER"
        return 1
    fi

    docker inspect \
        -f '{{range $name, $network := .NetworkSettings.Networks}}{{$name}}: {{$network.IPAddress}}{{println}}{{end}}' \
        "$1"
}

# Show detailed container information as formatted JSON.
#
# Example:
#   dinspect stalwart
dinspect() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: dinspect CONTAINER"
        return 1
    fi

    docker inspect "$1" | jq .
}

# Show Docker container resource usage once.
alias dtop='docker stats --no-stream'

# Remove unused Docker build cache, networks and stopped containers.
# Volumes are deliberately not removed.
alias dclean='docker system prune'


####################
# WireGuard
####################

alias wgs='sudo wg show'
alias wgall='sudo wg show all'
alias wgstatus='systemctl status wg-quick@wg0'
alias wgrestart='sudo systemctl restart wg-quick@wg0'

# Show WireGuard handshake status in a compact form.
alias wghandshakes='sudo wg show all latest-handshakes'


####################
# Firewall
####################

alias ufws='sudo ufw status verbose'
alias ufwn='sudo ufw status numbered'

alias ipt='sudo iptables -L -n -v'
alias ipts='sudo iptables -S'
alias iptnat='sudo iptables -t nat -L -n -v'
alias iptmangle='sudo iptables -t mangle -L -n -v'

alias ip6t='sudo ip6tables -L -n -v'
alias ip6ts='sudo ip6tables -S'
alias ip6tnat='sudo ip6tables -t nat -L -n -v'


####################
# Fail2Ban
####################

# Show Fail2Ban status.
#
# Examples:
#   f2b
#   f2b sshd
f2b() {
    if [[ $# -eq 0 ]]; then
        sudo fail2ban-client status
    elif [[ $# -eq 1 ]]; then
        sudo fail2ban-client status "$1"
    else
        echo "Verwendung: f2b [JAIL]"
        return 1
    fi
}

# Manually ban an IP.
#
# Example:
#   f2bban sshd 192.0.2.10
f2bban() {
    if [[ $# -ne 2 ]]; then
        echo "Verwendung: f2bban JAIL IP"
        return 1
    fi

    sudo fail2ban-client set "$1" banip "$2"
}

# Manually unban an IP.
#
# Example:
#   f2bunban sshd 192.0.2.10
f2bunban() {
    if [[ $# -ne 2 ]]; then
        echo "Verwendung: f2bunban JAIL IP"
        return 1
    fi

    sudo fail2ban-client set "$1" unbanip "$2"
}

alias f2btest='sudo fail2ban-client -t'
alias f2blog='journalctl -u fail2ban -f'


####################
# Postfix
####################

alias pconf='postconf -n'
alias pcheck='sudo postfix check'
alias pqueue='postqueue -p'
alias pflush='sudo postqueue -f'
alias preloads='sudo systemctl reload postfix'
alias prestart='sudo systemctl restart postfix'
alias pstatus='systemctl status postfix'
alias plog='journalctl -u postfix -f'

# Plesk commonly logs mail activity here.
alias maillog='tail -f /var/log/maillog'

# Show a queued Postfix message.
#
# Example:
#   pcat ABC123DEF
pcat() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: pcat QUEUE-ID"
        return 1
    fi

    sudo postcat -q "$1"
}

# Delete a single queued Postfix message.
#
# Example:
#   pdelete ABC123DEF
pdelete() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: pdelete QUEUE-ID"
        return 1
    fi

    sudo postsuper -d "$1"
}


####################
# Dovecot
####################

alias dconf='doveconf -n'
alias dovelog='journalctl -u dovecot -f'
alias drestart='sudo systemctl restart dovecot'
alias dstatus='systemctl status dovecot'

# Test Dovecot authentication.
#
# Example:
#   dauth support@example.com
dauth() {
    if [[ $# -lt 1 ]]; then
        echo "Verwendung: dauth BENUTZER [PASSWORT]"
        return 1
    fi

    doveadm auth test "$@"
}

# List mailboxes for a user.
#
# Example:
#   dmailboxes support@example.com
dmailboxes() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: dmailboxes BENUTZER"
        return 1
    fi

    doveadm mailbox list -u "$1"
}


####################
# Plesk mail
####################

# Warning: this command may display mailbox passwords.
alias pleskmails='sudo /usr/local/psa/admin/sbin/mail_auth_view'


####################
# SSH
####################

alias sshconfigtest='sudo sshd -t'
alias sshlog='journalctl -u ssh -f'
alias sshkeys='cat ~/.ssh/authorized_keys'

# Show known SSH host keys for a host.
#
# Example:
#   sshfingerprint server.example.com
sshfingerprint() {
    if [[ $# -ne 1 ]]; then
        echo "Verwendung: sshfingerprint HOST"
        return 1
    fi

    ssh-keyscan "$1" 2>/dev/null | ssh-keygen -lf -
}


####################
# Hardware and system
####################

alias kernel='uname -a'
alias uptimeh='uptime -p'
alias osinfo='cat /etc/os-release'
alias hardware='sudo lshw -short'
alias networkhw='sudo lshw -class network -short'
alias sensors='sensors'
alias smart='sudo smartctl -a'
alias ethernet='sudo ethtool'

# Show system information using fastfetch or neofetch.
sysinfo() {
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    elif command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        uname -a
        echo
        cat /etc/os-release
    fi
}


####################
# Monitoring
####################

alias topcpu='ps aux --sort=-%cpu | head -n 20'
alias topmem='ps aux --sort=-%mem | head -n 20'
alias io='sudo iotop'
alias traffic='sudo nethogs'
alias bandwidth='bmon'
alias load='nload'
alias interfaces='iftop'


####################
# Configuration helpers
####################

alias aliases='nano ~/.bash_aliases'
alias bashrc='nano ~/.bashrc'

# Check and reload ~/.bash_aliases.
reloadaliases() {
    if ! bash -n "$HOME/.bash_aliases"; then
        echo "Syntaxfehler in ~/.bash_aliases"
        return 1
    fi

    # shellcheck disable=SC1090
    source "$HOME/.bash_aliases"

    echo "~/.bash_aliases wurde neu geladen."
}

alias ra='reloadaliases'


####################
# History
####################

# Clear current and persisted Bash history.
clearHistory() {
    local answer

    read -r -p "Bash-History wirklich vollständig löschen? [y/N] " answer

    case "$answer" in
        y|Y|yes|YES|ja|JA)
            history -c
            : > "$HOME/.bash_history"
            history -w
            echo "Bash-History wurde gelöscht."
            ;;
        *)
            echo "Abgebrochen."
            ;;
    esac
}
