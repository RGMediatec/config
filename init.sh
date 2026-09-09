#!/usr/bin/env bash
#
# Initial configuration for new Debian/Ubuntu installations
#

set -Eeuo pipefail

####################
# Basic checks
####################

if [[ ${EUID} -ne 0 ]]; then
    echo "Dieses Skript muss als root ausgeführt werden."
    echo "Beispiel: sudo bash $0"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

TARGET_HOME="${HOME:-/root}"

cd "$TARGET_HOME"

echo "Starting initial server configuration ..."

####################
# Install tool set
####################

echo "Installing packages ..."

apt-get update

apt-get install -y \
    bash-completion \
    bmon \
    bpytop \
    ca-certificates \
    curl \
    distro-info \
    dnsutils \
    ethtool \
    git \
    htop \
    iftop \
    iotop \
    iproute2 \
    jq \
    lshw \
    lsof \
    mtr-tiny \
    nano \
    ncdu \
    net-tools \
    netcat-openbsd \
    nethogs \
    nload \
    nmon \
    openssl \
    pv \
    rsync \
    screen \
    sipcalc \
    smartmontools \
    sudo \
    sysbench \
    sysstat \
    tcpdump \
    tmux \
    traceroute \
    unzip \
    wget

# Optional tools:
#
# apt-get install -y \
#     fail2ban \
#     mc \
#     nmap \
#     swaks \
#     termshark \
#     ufw \
#     wireguard-tools

# Install a system information tool when available.
if apt-cache show fastfetch >/dev/null 2>&1; then
    apt-get install -y fastfetch
elif apt-cache show neofetch >/dev/null 2>&1; then
    apt-get install -y neofetch
else
    echo "Hinweis: Weder fastfetch noch neofetch ist in den Paketquellen verfügbar."
fi

####################
# Configure tmux
####################

echo "Configuring tmux ..."

TMUX_DIR="$TARGET_HOME/.tmux"
TPM_DIR="$TMUX_DIR/plugins/tpm"
TMUX_CONFIG_URL="https://raw.githubusercontent.com/RGMediatec/config/main/tmux/.tmux.conf"
TMUX_COMPLETION_URL="https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux"

mkdir -p "$TMUX_DIR/plugins"

if [[ -d "$TPM_DIR/.git" ]]; then
    echo "Updating tmux plugin manager ..."
    git -C "$TPM_DIR" pull --ff-only
else
    rm -rf "$TPM_DIR"
    git clone --depth 1 \
        https://github.com/tmux-plugins/tpm \
        "$TPM_DIR"
fi

curl -fsSL \
    "$TMUX_CONFIG_URL" \
    -o "$TARGET_HOME/.tmux.conf"

mkdir -p "$TARGET_HOME/.local/share/bash-completion/completions"

curl -fsSL \
    "$TMUX_COMPLETION_URL" \
    -o "$TARGET_HOME/.local/share/bash-completion/completions/tmux"

if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
    "$TPM_DIR/bin/install_plugins" || {
        echo "Hinweis: Nicht alle tmux-Plugins konnten installiert werden."
    }
fi

####################
# SSH configuration
####################

echo "Configuring SSH ..."

SSH_DIR="$TARGET_HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArKDvXiBMJ7QmccKV+p4CdCCsXlz2kXJ5P/XnKmEoa6 philipp@rgmediatec"

install -d -m 700 "$SSH_DIR"
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"

if ! grep -qxF "$SSH_KEY" "$AUTHORIZED_KEYS"; then
    printf '%s\n' "$SSH_KEY" >> "$AUTHORIZED_KEYS"
    echo "SSH public key added."
else
    echo "SSH public key already exists."
fi

# Use an SSH configuration drop-in instead of editing sshd_config
# directly. This is safer and easier to maintain.
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/99-rgmediatec-init.conf <<'EOF'
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF

# Validate configuration before reloading SSH.
if /usr/sbin/sshd -t; then
    if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
        systemctl reload ssh.service
    elif systemctl list-unit-files sshd.service >/dev/null 2>&1; then
        systemctl reload sshd.service
    else
        echo "Warnung: Kein ssh.service oder sshd.service gefunden."
    fi
else
    echo "Fehler: Die SSH-Konfiguration ist ungültig."
    echo "Die SSH-Konfiguration wurde nicht neu geladen."
    exit 1
fi

####################
# Aliases
####################

echo "Installing bash aliases ..."

ALIASES_URL="https://raw.githubusercontent.com/RGMediatec/config/main/cfg/.bash_aliases"

curl -fsSL \
    "$ALIASES_URL" \
    -o "$TARGET_HOME/.bash_aliases"

if ! bash -n "$TARGET_HOME/.bash_aliases"; then
    echo "Fehler: Die heruntergeladene .bash_aliases enthält Syntaxfehler."
    exit 1
fi

# Make sure interactive Bash sessions load ~/.bash_aliases.
BASHRC="$TARGET_HOME/.bashrc"

touch "$BASHRC"

if ! grep -qF 'if [ -f ~/.bash_aliases ]; then' "$BASHRC"; then
    cat >> "$BASHRC" <<'EOF'

# Load personal aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
fi

# Loading aliases is optional here because this script normally runs
# non-interactively.
# shellcheck disable=SC1090
source "$TARGET_HOME/.bash_aliases"

####################
# Finish
####################

echo
echo "Initial configuration completed successfully."
echo "Open a new shell or run:"
echo
echo "    source ~/.bashrc"
echo
echo "A reboot is normally not required."
