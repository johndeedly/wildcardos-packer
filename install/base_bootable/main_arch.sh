#!/usr/bin/env bash

log_text "List of basic packages to create a system with filesystem drivers"
PACKAGE_LIST=(
    # always needed, always present
    base
    doas
    # linux kernel and headers
    linux
    linux-headers
    # firmwares to support more hardware
    linux-firmware
    # efi system per default
    efibootmgr
    # efi partition, btrfs system, lvm2 data and swap
    dosfstools
    mtools
    lvm2
    btrfs-progs
    # remote syslogging
    syslog-ng
)
if [ -n "$INSTALLED_HARDWARE_CPU_AMD" ]; then
    PACKAGE_LIST+=( amd-ucode )
fi
if [ -n "$INSTALLED_HARDWARE_CPU_INTEL" ]; then
    PACKAGE_LIST+=( intel-ucode )
fi
if [ -n $INSTALLED_HARDWARE_WIRELESS ]; then
    PACKAGE_LIST+=( iwd iw )
fi
if [ -n $INSTALLED_HARDWARE_BLUETOOTH ]; then
    PACKAGE_LIST+=( bluez bluez-utils bluez-plugins )
fi
if [ -n $INSTALLED_HARDWARE_VIRTUAL_MACHINE ]; then
    PACKAGE_LIST+=( virtualbox-guest-utils qemu-guest-agent )
fi

log_text "Create a basic system inside the mountpoint folder"
sed -i 's/pacman -r/pacman --disable-download-timeout -r/' /usr/bin/pacstrap
pacstrap -K -M -c ${MOUNTPOINT%%/} ${PACKAGE_LIST[@]}

if [ $? -ne 0 ]; then
    log_text "Download pacman mirrorlist"
    curl -sL 'https://archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&ip_version=6' > /etc/pacman.d/mirrorlist
    
    log_text "Enable full mirrorlist"
    sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist

    log_text "Manual pacstrap initialization steps to get archlinux-keyring into the target"
    pacman-key --init
    pacman-key --populate
    pacman-key --refresh-keys

    log_text "Create a basic system inside the mountpoint folder"
    pacstrap -M -c ${MOUNTPOINT%%/} ${PACKAGE_LIST[@]}
fi
