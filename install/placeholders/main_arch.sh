#!/usr/bin/env bash

log_text "Packages needed to build placeholders"
pacman_whenneeded fakeroot binutils

log_text "Create sudo-dummy build environment"
mkdir -p "${TEMPHOME}"/sudo-dummy
chown "${TEMPID}:${TEMPGRP}" "${TEMPHOME}"/sudo-dummy
chmod 7777 "${TEMPHOME}"/sudo-dummy
cp ${SCRIPTDIR}/placeholders/sudo.pkgbuild "${TEMPHOME}"/sudo-dummy/PKGBUILD
chown "${TEMPID}:${TEMPGRP}" "${TEMPHOME}"/sudo-dummy/PKGBUILD

log_text "Build and install sudo-dummy"
su -s /bin/bash - "${TEMPID}" <<EOS
pushd "${TEMPHOME}"/sudo-dummy
    makepkg --clean
popd
EOS
pacman -U --needed --noconfirm --color=auto "${TEMPHOME}"/sudo-dummy/sudo-dummy-1-1-any.pkg.tar.zst
rm -rf "${TEMPHOME}"/sudo-dummy/

log_text "Install base-devel, now without sudo dependency"
pacman_whenneeded base-devel

log_text "Create vim-dummy build environment"
mkdir -p "${TEMPHOME}"/vim-dummy
chown "${TEMPID}:${TEMPGRP}" "${TEMPHOME}"/vim-dummy
chmod 7777 "${TEMPHOME}"/vim-dummy
cp ${SCRIPTDIR}/placeholders/vim.pkgbuild "${TEMPHOME}"/vim-dummy/PKGBUILD
chown "${TEMPID}:${TEMPGRP}" "${TEMPHOME}"/vim-dummy/PKGBUILD

log_text "Build and install vim-dummy"
su -s /bin/bash - "${TEMPID}" <<EOS
pushd "${TEMPHOME}"/vim-dummy
    makepkg --clean
popd
EOS
pacman -U --needed --noconfirm --color=auto "${TEMPHOME}"/vim-dummy/vim-dummy-1-1-any.pkg.tar.zst
rm -rf "${TEMPHOME}"/vim-dummy/
