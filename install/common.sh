#!/usr/bin/env bash

function join_arr() {
    local IFS="$1"
    shift
    echo "$*"
}

function log_text() {
    # bold yellow
    echo -e "\033[1;33m:: $*\033[0m"
}

function log_error() {
    # bold red
    echo -e "\033[1;31m!! $*\033[0m"
}

function archiso_pacman_whenneeded() {
    log_text "Install package(s) ${*// /,}"
    /usr/bin/pacman -Sy --disable-download-timeout --noconfirm --needed --noprogressbar --color=auto $*
}

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    function pacman_whenneeded() {
        log_text "Install package(s) ${*// /,}"
        yes | LC_ALL=C /usr/bin/pacman -Sy --disable-download-timeout --noconfirm --needed --noprogressbar --color=auto $*
    }
    function pacman_package_whenneeded() {
        log_text "Install package(s) ${*// /,}"
        yes | LC_ALL=C /usr/bin/pacman -U --disable-download-timeout --noconfirm --needed --noprogressbar --color=auto $*
    }
elif [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    function pacman_whenneeded() {
        log_text "Install package(s) ${*// /,}"
        DEBIAN_FRONTEND="noninteractive" eatmydata apt -y install $*
    }
    function pacman_package_whenneeded() {
        log_text "Install package(s) ${*// /,}"
        DEBIAN_FRONTEND="noninteractive" eatmydata apt -y install $*
    }
elif [[ ${TAGS[@]} =~ "rockylinux" ]]; then
    function pacman_whenneeded() {
        log_error not implemented
        exit 1
    }
    function pacman_package_whenneeded() {
        log_error not implemented
        exit 1
    }
fi
