#!/usr/bin/env bash

log_text "Create a basic system inside the mountpoint folder"
sed -i 's/pacman -r/pacman --disable-download-timeout -r/' /usr/bin/pacstrap
pacstrap -K -M -c ${MOUNTPOINT%%/} base dbus-broker systemd

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
    pacstrap -M -c ${MOUNTPOINT%%/} base dbus-broker systemd
fi
