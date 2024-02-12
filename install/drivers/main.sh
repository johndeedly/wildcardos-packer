#!/usr/bin/env bash

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    source "${SCRIPTDIR}/drivers/main_arch.sh"
fi

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    source "${SCRIPTDIR}/drivers/main_ubuntu.sh"
fi

if [[ ${TAGS[@]} =~ "rockylinux" ]]; then
    source "${SCRIPTDIR}/drivers/main_rocky.sh"
fi
