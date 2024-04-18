#!/usr/bin/env bash

log_text "Generate locales"
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    pacman_whenneeded locales
fi
sed -i 's/^#\? \?de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    echo "LANG=de_DE.UTF-8" > /etc/default/locale
    dpkg-reconfigure --frontend=noninteractive locales
    update-locale LANG=de_DE.UTF-8
elif [[ ${TAGS[@]} =~ "archlinux" ]]; then
    echo "LANG=de_DE.UTF-8" > /etc/locale.conf
    locale-gen
fi

log_text "Configure timezone"
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    pacman_whenneeded tzdata
fi
rm /etc/localtime || true
ln -s /usr/share/zoneinfo/CET /etc/localtime
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    echo "CET" > /etc/timezone
    dpkg-reconfigure --frontend=noninteractive tzdata
fi

log_text "Configure keyboard and console"
cp "${SCRIPTDIR}/console_setup/vconsole.conf" /etc/vconsole.conf
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    pacman_whenneeded keyboard-configuration console-setup
    cp "${SCRIPTDIR}/console_setup/vconsole.conf" /etc/default/keyboard
    cp "${SCRIPTDIR}/console_setup/console-setup" /etc/default/console-setup
    dpkg-reconfigure --frontend=noninteractive keyboard-configuration
    dpkg-reconfigure --frontend=noninteractive console-setup
elif [[ ${TAGS[@]} =~ "archlinux" ]]; then
    loadkeys de-latin1 || true
    if [ -d /usr/share/kbd/consolefonts ]; then
        setfont /usr/share/kbd/consolefonts/Lat2-Terminus16.psfu.gz || true
    elif [ -d /usr/share/consolefonts ]; then
        setfont /usr/share/consolefonts/Lat2-Terminus16.psf.gz || true
    fi
fi
