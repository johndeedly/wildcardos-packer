#!/usr/bin/env bash

log_text "Enable regular filesystem trim"
systemctl enable fstrim.timer

log_text "Install snapper for auto snapshots"
if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    pacman_whenneeded snapper snapper-gui-git
fi
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    pacman_whenneeded snapper snapper-gui
fi

log_text "Configure snapper for / and /home partitions"
snapper --no-dbus -c root create-config /
snapper --no-dbus -c home create-config /home
sed -i 's/^TIMELINE_LIMIT_MONTHLY.*/TIMELINE_LIMIT_MONTHLY="5"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_YEARLY.*/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_MONTHLY.*/TIMELINE_LIMIT_MONTHLY="5"/' /etc/snapper/configs/home
sed -i 's/^TIMELINE_LIMIT_YEARLY.*/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/home

log_text "Enable snapper timeline and cleanup timers"
systemctl enable snapper-timeline.timer snapper-cleanup.timer
