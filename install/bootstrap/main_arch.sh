#!/usr/bin/env bash

log_text "Install standard packages"
pacman_whenneeded nano neovim htop btop dialog git ufw \
  bash-completion pacman-contrib openssh pv lshw libxml2 jq ly polkit \
  dotnet-host dotnet-sdk dotnet-runtime aspnet-runtime \
  dotnet-sdk-6.0 dotnet-runtime-6.0 aspnet-runtime-6.0 \
  python python-pip words python-setuptools python-wheel \
  wireguard-tools wget nfs-utils ncdu viu core/man man-pages-de trash-cli \
  gvfs gvfs-smb sshfs cifs-utils \
  unzip p7zip rsync mc lf fzf xdg-user-dirs xdg-utils \
  starship ttf-nerd-fonts-symbols

log_text "Enable system packages"
systemctl enable systemd-networkd systemd-resolved systemd-homed sshd ufw ly

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
