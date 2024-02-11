#!/usr/bin/env bash

if [ -n $INSTALLED_HARDWARE_WIRELESS ]; then
    log_text "Install wireless drivers"
    pacman_whenneeded iwd iw
    systemctl enable iwd
    tee /etc/iwd/main.conf <<EOF
[General]
EnableNetworkConfiguration=false

[Network]
EnableIPv6=true
NameResolvingService=systemd
EOF
    mkdir -p /etc/systemd/network
    ln -s /dev/null /etc/systemd/network/80-iwd.link
fi

if [ -n $INSTALLED_HARDWARE_BLUETOOTH ]; then
    log_text "Install bluetooth drivers"
    if [[ ${TAGS[@]} =~ "archlinux" ]]; then
        pacman_whenneeded bluez bluez-utils
    elif [[ ${TAGS[@]} =~ "ubuntu" ]]; then
        pacman_whenneeded bluez bluez-tools
    elif [[ ${TAGS[@]} =~ "rockylinux" ]]; then
        log_error "not implemented"
        exit 1
    fi
    systemctl enable bluetooth
    sed -i 's/^#\?AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
fi

if [ -n $INSTALLED_HARDWARE_CPU_AMD ]; then
    log_text "Install AMD microcodes"
    if [[ ${TAGS[@]} =~ "archlinux" ]]; then
        # TODO: why are files from linux-firmware conflicting with this package?
        pacman -S --overwrite=\* --noconfirm --noprogressbar --needed amd-ucode
    elif [[ ${TAGS[@]} =~ "ubuntu" ]]; then
        pacman_whenneeded amd64-microcode
    elif [[ ${TAGS[@]} =~ "rockylinux" ]]; then
        log_error "not implemented"
        exit 1
    fi
fi

if [ -n $INSTALLED_HARDWARE_CPU_INTEL ]; then
    log_text "Install Intel microcodes"
    if [[ ${TAGS[@]} =~ "archlinux" ]]; then
        # TODO: why are files from linux-firmware conflicting with this package?
        pacman -S --overwrite=\* --noconfirm --noprogressbar --needed intel-ucode
    elif [[ ${TAGS[@]} =~ "ubuntu" ]]; then
        pacman_whenneeded intel-microcode
    elif [[ ${TAGS[@]} =~ "rockylinux" ]]; then
        log_error "not implemented"
        exit 1
    fi
fi

if [ -n $INSTALLED_HARDWARE_VIRTUAL_MACHINE ]; then
    log_text "Install virtual machine drivers"
    pacman_whenneeded virtualbox-guest-utils qemu-guest-agent
    systemctl enable vboxservice
fi
