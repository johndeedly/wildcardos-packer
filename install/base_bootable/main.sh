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

log_text "Disable hibernation and hybrid-sleep modes"
cp ${MOUNTPOINT%%/}/etc/systemd/logind.conf ${MOUNTPOINT%%/}/etc/systemd/logind.conf.bak
sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=poweroff/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandlePowerKeyLongPress=.*/HandlePowerKeyLongPress=poweroff/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleRebootKey=.*/HandleRebootKey=reboot/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleRebootKeyLongPress=.*/HandleRebootKeyLongPress=poweroff/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleSuspendKey=.*/HandleSuspendKey=suspend/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleSuspendKeyLongPress=.*/HandleSuspendKeyLongPress=poweroff/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleHibernateKey=.*/HandleHibernateKey=suspend/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleHibernateKeyLongPress=.*/HandleHibernateKeyLongPress=poweroff/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleLidSwitch=.*/HandleLidSwitch=suspend/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=suspend/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf
sed -i 's/^#\?HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' ${MOUNTPOINT%%/}/etc/systemd/logind.conf

cp ${MOUNTPOINT%%/}/etc/systemd/sleep.conf ${MOUNTPOINT%%/}/etc/systemd/sleep.conf.bak
sed -i 's/^#\?AllowSuspend=.*/AllowSuspend=yes/' ${MOUNTPOINT%%/}/etc/systemd/sleep.conf
sed -i 's/^#\?AllowHibernation=.*/AllowHibernation=no/' ${MOUNTPOINT%%/}/etc/systemd/sleep.conf
sed -i 's/^#\?AllowSuspendThenHibernate=.*/AllowSuspendThenHibernate=no/' ${MOUNTPOINT%%/}/etc/systemd/sleep.conf
sed -i 's/^#\?AllowHybridSleep=.*/AllowHybridSleep=no/' ${MOUNTPOINT%%/}/etc/systemd/sleep.conf

systemctl mask hibernate.target suspend-then-hibernate.target hybrid-sleep.target
