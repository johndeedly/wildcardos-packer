#!/usr/bin/env bash

log_text "partitioning"

log_text "Partition the main drive"
source "${SCRIPTDIR}/partitioning/parted.sh"

log_text "Calculate swap size"
source "${SCRIPTDIR}/partitioning/swapsize.sh"

log_text "Format all partitions"
source "${SCRIPTDIR}/partitioning/mkfs.sh"

log_text "Mount everything into place"
source "${SCRIPTDIR}/partitioning/mount.sh"

log_text "Generate fstab"
mkdir -p ${MOUNTPOINT%%/}/etc
genfstab -U -p ${MOUNTPOINT%%/} > ${MOUNTPOINT%%/}/etc/fstab

if [[ ${TAGS[@]} =~ "encryption" ]]; then
    log_text "Generate crypttab"
    LUKSUUID=$(cryptsetup luksUUID ${PART_DATA})
    touch ${MOUNTPOINT%%/}/etc/crypttab
    tee ${MOUNTPOINT%%/}/etc/crypttab.initramfs <<EOF >/dev/null
data  /dev/disk/by-uuid/${LUKSUUID}  /luks.key:LABEL=EFI  luks
EOF
fi
