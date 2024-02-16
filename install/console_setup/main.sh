#!/usr/bin/env bash

log_text "Configure systemd vconsole service"
cp "${SCRIPTDIR}/console_setup/vconsole.conf" /etc/vconsole.conf

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    log_text "Debian/Ubuntu patched out systemd vconsole setup for some reason... thanks for nothing"
    cp "${SCRIPTDIR}/console_setup/vconsole.conf" /etc/default/keyboard
    cp "${SCRIPTDIR}/console_setup/console-setup" /etc/default/console-setup
fi

log_text "Try changing keyboard layout and font for the active session"
loadkeys de-latin1 || true
if [ -d /usr/share/kbd/consolefonts ]; then
    setfont /usr/share/kbd/consolefonts/Lat2-Terminus16.psfu.gz || true
elif [ -d /usr/share/consolefonts ]; then
    setfont /usr/share/consolefonts/Lat2-Terminus16.psf.gz || true
fi
