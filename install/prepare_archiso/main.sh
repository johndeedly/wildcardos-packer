#!/usr/bin/env bash

log_text "Install dmidecode to detect execution inside a vm"
archiso_pacman_whenneeded dmidecode

DMIDECODE_SYSTEM_MANUFACTURER=$(dmidecode -s system-manufacturer)
DMIDECODE_SYSTEM_PRODUCT_NAME=$(dmidecode -s system-product-name)
RUNTIME_ENVIRONMENT_VMWARE=""
RUNTIME_ENVIRONMENT_VIRTUALBOX=""
RUNTIME_ENVIRONMENT_QEMU=""
RUNTIME_ENVIRONMENT_VIRTUALPC=""
RUNTIME_ENVIRONMENT_XEN=""
RUNTIME_ENVIRONMENT_HOST=""
if [[ "$DMIDECODE_SYSTEM_PRODUCT_NAME" =~ VMware ]]; then
    log_text "Running inside VMware"
    RUNTIME_ENVIRONMENT_VMWARE="YES"
elif [[ "$DMIDECODE_SYSTEM_PRODUCT_NAME" =~ VirtualBox ]]; then
    log_text "Running inside VirtualBox"
    RUNTIME_ENVIRONMENT_VIRTUALBOX="YES"
elif [[ "$DMIDECODE_SYSTEM_MANUFACTURER" =~ QEMU ]]; then
    log_text "Running inside QEMU"
    RUNTIME_ENVIRONMENT_QEMU="YES"
elif [[ "$DMIDECODE_SYSTEM_MANUFACTURER" =~ Microsoft ]] && [[ "$(dmidecode | grep -E -i 'product')" =~ Virtual ]]; then
    log_text "Running inside VirtualPC"
    RUNTIME_ENVIRONMENT_VIRTUALPC="YES"
elif dmidecode | grep -E 'domU'; then
    log_text "Running inside Xen"
    RUNTIME_ENVIRONMENT_XEN="YES"
else
    log_text "Probably running on a physical host"
    RUNTIME_ENVIRONMENT_HOST="YES"
fi

log_text "Mount the external output folder as share"
if [ -n "$RUNTIME_ENVIRONMENT_VIRTUALBOX" ]; then
  mount --mkdir -t vboxsf -o rw host.0 /share
elif [ -n "$RUNTIME_ENVIRONMENT_QEMU" ]; then
  mount --mkdir -t 9p -o trans=virtio,version=9p2000.L,rw host.0 /share
fi

log_text "Remount copy on write space"
mount -o remount,size=75% /run/archiso/cowspace || true

log_text "Make the journal log persistent on ramfs"
mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
systemctl restart systemd-journald

log_text "Wait for pacman keyring init to be done"
while ! systemctl show pacman-init.service | grep SubState=exited; do
  systemctl --no-pager status -n0 pacman-init.service || true
  sleep 5
done

log_text "Prepare nspawn environment to allow ufw firewall configuration"
modprobe iptable_filter
modprobe ip6table_filter
