#!/usr/bin/env bash

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    source "${SCRIPTDIR}/pxeserve/main_arch.sh"
fi

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    log_error "Not implemented for ubuntu yet"
fi
