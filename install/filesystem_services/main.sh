#!/usr/bin/env bash

log_text "Enable regular filesystem trim"
systemctl enable fstrim.timer

log_text "Build and install btrfs-autosnap"
log_text "Disabled, until the user really wants to enable it (remove .disabled)"
cp "${SCRIPTDIR}/filesystem_services/btrfs-autosnap.sh" /usr/local/bin/btrfs-autosnap
chmod a+x /usr/local/bin/btrfs-autosnap
cp "${SCRIPTDIR}/filesystem_services/btrfs-autosnap.conf" /etc/btrfs-autosnap.conf
cp "${SCRIPTDIR}/filesystem_services/01-btrfs-autosnap.hook" /etc/pacman.d/hooks/01-btrfs-autosnap.hook.disabled
