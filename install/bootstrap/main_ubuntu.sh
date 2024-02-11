#!/usr/bin/env bash

log_text "Add package source for dotnet"
REPO_VERSION=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
wget "https://packages.microsoft.com/config/ubuntu/$REPO_VERSION/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update

log_text "Install and configure base packages needed for everything else"
pacman_whenneeded nano neovim htop btop dialog git \
    bash-completion ncdu rustc cargo pv mc lfm fzf \
    lshw libxml2 jq \
    policykit-1 man manpages-de trash-cli \
    dotnet-sdk-8.0 dotnet-runtime-8.0 aspnetcore-runtime-8.0 \
    dotnet-sdk-6.0 dotnet-runtime-6.0 aspnetcore-runtime-6.0 \
    python-is-python3 python3-pip wngerman python3-setuptools python3-wheel \
    openssh-server openssh-client ufw wireguard-tools wget \
    gvfs gvfs-backends sshfs cifs-utils nfs-kernel-server \
    unzip p7zip rsync \
    xdg-user-dirs xdg-utils

log_text "Install and configure ly"
pacman_whenneeded cmake libpam0g-dev libx11-xcb-dev
pushd /var/tmp
    git clone --recurse-submodules https://github.com/fairyglade/ly ly
    pushd /var/tmp/ly
        make
        make install installsystemd
    popd
popd
rm -rf /var/tmp/ly

log_text "Install and configure viu"
CARGO_TARGET_DIR=/var/tmp CARGO_INSTALL_ROOT=/usr/local cargo install viu --locked

log_text "Install and configure starship"
CARGO_TARGET_DIR=/var/tmp CARGO_INSTALL_ROOT=/usr/local cargo install starship --locked

log_text "Enable system packages"
systemctl enable systemd-networkd systemd-resolved systemd-homed ssh ufw ly

log_text "Disable tty login"
systemctl mask console-getty.service
for i in {1..9}; do
  systemctl mask getty@tty${i}.service
done

log_text "Configure ly to have username and shell prefilled on first boot"
tee /etc/ly/save <<EOF
${USERID}
0
EOF

log_text "Install xkcd for user, root and skeleton"
su -s /bin/bash - "${USERID}" <<EOS
PYTHONUSERBASE=$USERHOME python3 -m pip install --user --break-system-packages --no-warn-script-location xkcdpass || true
EOS
PYTHONUSERBASE=$ROOTHOME python3 -m pip install --user --break-system-packages --no-warn-script-location xkcdpass || true
PYTHONUSERBASE=/etc/skel/.local python3 -m pip install --user --break-system-packages --no-warn-script-location xkcdpass || true

log_text "Install PowerShell"
dotnet tool install --global PowerShell --version 7.4.0
su -s /bin/bash - "${USERID}" <<EOS
dotnet tool install --global PowerShell --version 7.4.0
EOS
