#!/usr/bin/env bash

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    source "${SCRIPTDIR}/base_bootable/main_arch.sh"
fi

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    source "${SCRIPTDIR}/base_bootable/main_ubuntu.sh"
fi

if [[ ${TAGS[@]} =~ "rockylinux" ]]; then
    source "${SCRIPTDIR}/base_bootable/main_rocky.sh"
fi

log_text "Configure doas"
mkdir -p ${MOUNTPOINT%%/}/etc
cp "${SCRIPTDIR}/base_bootable/doas.conf" ${MOUNTPOINT%%/}/etc/

log_text "Configure network"
mkdir -p ${MOUNTPOINT%%/}/etc/systemd/network
cp "${SCRIPTDIR}/base_bootable/20-wired.network" ${MOUNTPOINT%%/}/etc/systemd/network/
cp "${SCRIPTDIR}/base_bootable/20-wireless.network" ${MOUNTPOINT%%/}/etc/systemd/network/

log_text "Configure wait online service to wait for only one network to be online"
mkdir -p ${MOUNTPOINT%%/}/etc/systemd/system/systemd-networkd-wait-online.service.d
cp "${SCRIPTDIR}/base_bootable/wait-online-any.conf" \
  ${MOUNTPOINT%%/}/etc/systemd/system/systemd-networkd-wait-online.service.d/

log_text "Set default shell for the system to bash"
rm ${MOUNTPOINT%%/}/bin/sh
ln -s bash ${MOUNTPOINT%%/}/bin/sh

log_text "Create minimal bash profile and bashrc to have path set"
mkdir -p ${MOUNTPOINT%%/}/etc/skel ${MOUNTPOINT%%/}/root
tee -a ${MOUNTPOINT%%/}/etc/skel/.bash_profile \
    ${MOUNTPOINT%%/}/etc/skel/.bashrc \
    ${MOUNTPOINT%%/}/root/.bash_profile \
    ${MOUNTPOINT%%/}/root/.bashrc <<EOF
TERM=linux
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/var/lib/flatpak/exports/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:~/.local/.bin
EOF
