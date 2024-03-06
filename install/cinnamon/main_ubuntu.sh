#!/usr/bin/env bash

log_text "List of basic packages to create a system with graphical support"
PACKAGE_LIST=(
    cinnamon
    cinnamon-l10n
    network-manager
    system-config-printer
)

log_text "Install and configure base packages needed for cinnamon environment"
pacman_whenneeded ${PACKAGE_LIST[@]}
