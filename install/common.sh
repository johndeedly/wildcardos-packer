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
    log_text "Install packages ${*// /,}"
    pacman -Sy --noconfirm --needed --noprogressbar --color=auto $*
}

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    function pacman_whenneeded() {
        log_text "Install packages ${*// /,}"
        yes | LC_ALL=C pacman -Sy --noconfirm --needed --noprogressbar --color=auto $*
    }
    function pacman_package_whenneeded() {
        log_text "Install packages ${*// /,}"
        yes | LC_ALL=C pacman -U --noconfirm --needed --noprogressbar --color=auto $*
    }
elif [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    function pacman_whenneeded() {
        log_text "Install packages ${*// /,}"
        if ! [[ "$PATH" =~ "/usr/sbin" ]]; then
            PATH="$PATH:/usr/local/sbin:/usr/sbin"
        fi
        DEBIAN_FRONTEND="noninteractive" eatmydata apt -y install $*
        sync
    }
    function pacman_package_whenneeded() {
        log_text "Install packages ${*// /,}"
        if ! [[ "$PATH" =~ "/usr/sbin" ]]; then
            PATH="$PATH:/usr/local/sbin:/usr/sbin"
        fi
        DEBIAN_FRONTEND="noninteractive" eatmydata apt -y install $*
        sync
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
