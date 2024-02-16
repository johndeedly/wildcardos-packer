#!/usr/bin/env bash

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    source "${SCRIPTDIR}/graphical/main_arch.sh"
fi

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    source "${SCRIPTDIR}/graphical/main_ubuntu.sh"
fi

log_text "Configure graphical environment"
source "${SCRIPTDIR}/graphical/configure_system.sh"

log_text "Configure xeventbind"
source "${SCRIPTDIR}/graphical/xeventbind.sh"

log_text "Configure firefox"
source "${SCRIPTDIR}/graphical/firefox.sh"

log_text "Configure chromium"
source "${SCRIPTDIR}/graphical/chromium.sh"

log_text "Create skeleton for graphical environment"
source "${SCRIPTDIR}/graphical/skeleton.sh"
