#!/usr/bin/env bash

if [ -n $INSTALLED_HARDWARE_WIRELESS ]; then
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
    log_text "Configure bluetooth drivers"
    systemctl enable bluetooth
    mkdir -p /etc/bluetooth
    sed -i 's/^#\?AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
fi

if [ -n $INSTALLED_HARDWARE_VIRTUALBOX ]; then
    log_text "Configure virtualbox drivers"
    systemctl enable vboxservice
fi
