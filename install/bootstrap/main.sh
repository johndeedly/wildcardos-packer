#!/usr/bin/env bash

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    source "${SCRIPTDIR}/bootstrap/main_arch.sh"
fi

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    source "${SCRIPTDIR}/bootstrap/main_ubuntu.sh"
fi

if [[ ${TAGS[@]} =~ "rockylinux" ]]; then
    source "${SCRIPTDIR}/bootstrap/main_rocky.sh"
fi

log_text "Create user skeleton"
source "${SCRIPTDIR}/bootstrap/skeleton.sh"

log_text "Prepare NvChad environment"
su -s /bin/bash - "${USERID}" <<EOS
mkdir -p "${USERHOME}/.config" "${USERHOME}/.local/share"
git clone --branch 'v2.0' 'https://github.com/NvChad/NvChad' "${USERHOME}/.config/nvim" --depth 1
EOS
cp -r ${SCRIPTDIR}/bootstrap/nvim-lua-custom "${USERHOME}/.config/nvim/lua/custom"
chown -R "${USERID}:${USERGRP}" "${USERHOME}/.config/nvim/lua/custom"
log_text "Setup NvChad environment"
su -s /bin/bash - "${USERID}" <<EOS
nvim -es -u "${USERHOME}/.config/nvim/init.lua" -c ":Lazy sync | Lazy load all" -c ":MasonInstallAll" -c ":TSInstall all" -c ":qall!" || true
EOS
log_text "Wait for NvChad to finish"
sleep 5
log_text "Mirror NvChad environment"
mkdir -p /etc/skel/.config/nvim /etc/skel/.local/share/nvim \
  "${ROOTHOME}/.config/nvim" "${ROOTHOME}/.local/share/nvim"
cp -rd "${USERHOME}/.config/nvim/"* /etc/skel/.config/nvim/ || log_error "Error copying config to skeleton"
cp -rd "${USERHOME}/.local/share/nvim/"* /etc/skel/.local/share/nvim/ || log_error "Error copying local share to skeleton"
cp -rd "${USERHOME}/.config/nvim/"* "${ROOTHOME}/.config/nvim/" || log_error "Error copying config to root"
cp -rd "${USERHOME}/.local/share/nvim/"* "${ROOTHOME}/.local/share/nvim/" || log_error "Error copying local share to root"

log_text "Enable ntfs kernel support (since 5.15)"
echo "ntfs3" | tee /etc/modules-load.d/ntfs3.conf
tee /etc/udev/rules.d/50-ntfs.rules <<EOF
SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs3"
EOF

log_text "Enable cifs kernel support"
echo "cifs" | tee /etc/modules-load.d/cifs.conf

log_text "Configure ufw"
# configure ufw
ufw disable
# outgoing is always allowed, incoming and routed should be denied
ufw default deny incoming
ufw default deny routed
ufw default allow outgoing
# only limited ssh access on all devices
ufw limit ssh comment 'allow limited ssh access'
ufw logging off
ufw enable

log_text "Create user homes on login"
# see https://wiki.archlinux.org/title/LDAP_authentication for more details
# TODO: on ubuntu system-login is missing - investigate!
if [ -f /etc/pam.d/system-login ]; then
    sed -i 's/session\s\+required\s\+pam_env.so/session    required   pam_env.so\nsession    required   pam_mkhomedir.so     skel=\/etc\/skel umask=0077/' /etc/pam.d/system-login
fi

log_text "Append gnome keyring to pam login"
# see https://wiki.archlinux.org/title/GNOME/Keyring#PAM_step
# TODO: protection from upper error
if [ -f /etc/pam.d/login ]; then
    sed -i 's/auth\s\+include\s\+system-local-login/auth       include      system-local-login\nauth       optional     pam_gnome_keyring.so/' /etc/pam.d/login
    sed -i 's/session\s\+include\s\+system-local-login/session    include      system-local-login\nsession    optional     pam_gnome_keyring.so auto_start/' /etc/pam.d/login
fi
if [ -f /etc/pam.d/passwd ]; then
    sed -i 's/password\s\+include\s\+system-auth/password        include         system-auth\npassword        optional        pam_gnome_keyring.so/' /etc/pam.d/passwd
fi
