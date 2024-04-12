#!/usr/bin/env bash

if [ -n "$INSTALLED_HARDWARE_CPU_AMD" ]; then
    log_text "Install amd microcodes"
    pacman_whenneeded amd-ucode
fi

if [ -n "$INSTALLED_HARDWARE_CPU_INTEL" ]; then
    log_text "Install intel microcodes"
    pacman_whenneeded intel-ucode
fi

if [ -n $INSTALLED_HARDWARE_WIRELESS ]; then
    log_text "Install wireless drivers"
    pacman_whenneeded iwd iw
    log_text "Configure wireless drivers"
    systemctl enable iwd
    mkdir -p /etc/iwd
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
    pacman_whenneeded bluez bluez-utils bluez-plugins
    log_text "Configure bluetooth drivers"
    systemctl enable bluetooth
    mkdir -p /etc/bluetooth
    sed -i 's/^#\?AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
fi

if [ -n $INSTALLED_HARDWARE_VIRTUALBOX ]; then
    log_text "Install virtualbox drivers"
    pacman_whenneeded virtualbox-guest-utils
    log_text "Configure virtualbox drivers"
    systemctl enable vboxservice
    log_text "Add user to the vboxsf group"
    usermod -aG vboxsf "${USERID}"
fi

if [ -n $INSTALLED_HARDWARE_QEMU ]; then
    log_text "Install qemu drivers"
    pacman_whenneeded qemu-guest-agent
fi
