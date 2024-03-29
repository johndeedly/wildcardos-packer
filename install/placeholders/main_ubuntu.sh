#!/usr/bin/env bash

log_text "Packages needed to build placeholders"
pacman_whenneeded dpkg

log_text "Create and build sudo-dummy"
cp -r ${SCRIPTDIR}/placeholders/sudo "${TEMPHOME}"/
chmod a+x "${TEMPHOME}"/sudo/DEBIAN/*
pushd "${TEMPHOME}"
    dpkg -b ./sudo sudo-dummy.deb
    DEBIAN_FRONTEND="noninteractive" eatmydata apt -y -q install "${TEMPHOME}"/sudo-dummy.deb
    sync
popd
rm -rf "${TEMPHOME}"/sudo/ "${TEMPHOME}"/sudo-dummy.deb

log_text "Create symlinks for sudo-dummy"
ln -s /usr/bin/doas /usr/local/bin/sudo

log_text "Install build-essential, now without sudo dependency"
pacman_whenneeded build-essential

log_text "Create and build vim-dummy"
cp -r ${SCRIPTDIR}/placeholders/vim "${TEMPHOME}"/
chmod a+x "${TEMPHOME}"/vim/DEBIAN/*
pushd "${TEMPHOME}"
    dpkg -b ./vim vim-dummy.deb
    DEBIAN_FRONTEND="noninteractive" eatmydata apt -y -q install "${TEMPHOME}"/vim-dummy.deb
    sync
popd
rm -rf "${TEMPHOME}"/vim-dummy/ "${TEMPHOME}"/vim-dummy.deb

log_text "Create symlinks for vim-dummy"
ln -s /usr/bin/nvim /usr/local/bin/vi
ln -s /usr/bin/nvim /usr/local/bin/vim
ln -s /usr/bin/nvim /usr/local/bin/gvim

log_text "Canonical, I do not want ads in my shell"
log_text "Create and build fake ubuntu-advantage-tools"
cp -r ${SCRIPTDIR}/placeholders/ubuntu-advantage-tools "${TEMPHOME}"/
chmod a+x "${TEMPHOME}"/ubuntu-advantage-tools/DEBIAN/*
pushd "${TEMPHOME}"
    dpkg -b ./ubuntu-advantage-tools fake-ubuntu-advantage-tools.deb
    DEBIAN_FRONTEND="noninteractive" eatmydata apt -y -q install "${TEMPHOME}"/fake-ubuntu-advantage-tools.deb
    sync
popd
rm -rf "${TEMPHOME}"/ubuntu-advantage-tools/ "${TEMPHOME}"/fake-ubuntu-advantage-tools.deb

log_text "Disable rsyslog"
systemctl disable rsyslog

log_text "Force replace rsyslog with syslog-ng"
DEBIAN_FRONTEND="noninteractive" eatmydata apt -y -q install syslog-ng

log_text "Disable syslog-ng"
systemctl disable syslog-ng
