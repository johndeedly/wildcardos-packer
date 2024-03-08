#!/usr/bin/env bash

log_text "Integrity check"
if ! mountpoint -q -- ${MOUNTPOINT%%/}; then
  log_error "${MOUNTPOINT%%/} doesn't appear to be mounted, aborting to prevent accidentally filling up the main filesystem"
  exit 1
elif [ ! -d /share ]; then
  log_error "/share doesn't exist"
  exit 2
elif ! mountpoint -q -- /share; then
  if mountpoint -q -- ${MOUNTPOINT%%/}/share; then
    umount ${MOUNTPOINT%%/}/share
    mkdir -m777 -p /share
    if [ -n "$RUNTIME_ENVIRONMENT_VIRTUALBOX" ]; then
      mount -t vboxsf -o rw host.0 /share
    elif [ -n "$RUNTIME_ENVIRONMENT_QEMU" ]; then
      mount -t 9p -o trans=virtio,version=9p2000.L,rw host.0 /share
    fi
  else
    log_error "/share doesn't appear to be mounted, aborting to prevent accidentally filling up the main filesystem"
    exit 3
  fi
fi

log_text "Fixating pxe boot image"
tee ${MOUNTPOINT%%/}/etc/.updated ${MOUNTPOINT%%/}/var/.updated <<EOF
# For details, see manpage of systemd.unit -> 'ConditionNeedsUpdate'.
TIMESTAMP_NSEC=$(date +%s%N)
EOF
chmod 644 ${MOUNTPOINT%%/}/etc/.updated ${MOUNTPOINT%%/}/var/.updated

log_text "Creating pxe boot image"
if [ ! -f /share/pxe/arch/x86_64/pxeboot.img ]; then
  mkdir -p /share/pxe/arch/x86_64
  findmnt -R ${MOUNTPOINT%%/}
  mksquashfs ${MOUNTPOINT%%/} /share/pxe/arch/x86_64/pxeboot.img -comp zstd -Xcompression-level 4 -b 1M -progress -wildcards \
    -e "boot/*" "dev/*" "etc/fstab" "etc/crypttab" "etc/crypttab.initramfs" "proc/*" "sys/*" "run/*" "mnt/*" "media/*" "share/*" "win/*" "tmp/*" "var/tmp/*" "var/cache/pacman/pkg/*"
fi
