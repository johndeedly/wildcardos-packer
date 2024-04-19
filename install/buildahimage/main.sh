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

log_text "Preparing temporary build drive"
dd if=/dev/zero of=${BUILDAH} bs=1M count=16 iflag=fullblock status=progress
mkfs.ext4 -L BUILDAH ${BUILDAH}
mkdir -p /buildah
mount -t ext4 ${BUILDAH} /buildah

log_text "Preparing podman buildah context"
archiso_pacman_whenneeded buildah podman fuse-overlayfs
export TMPDIR="/buildah/tmp"
mkdir -p /buildah/run/containers/storage /buildah/var/lib/containers/storage "${TMPDIR}"
sed -i 's|/run/containers/storage|/buildah/run/containers/storage|g' /etc/containers/storage.conf
sed -i 's|/var/lib/containers/storage|/buildah/var/lib/containers/storage|g' /etc/containers/storage.conf
podman system migrate

log_text "podman info"
podman info
log_text "buildah info"
buildah info

buildah --cap-add=SYS_CHROOT,NET_ADMIN,NET_RAW --name worker from scratch
buildah config --entrypoint "/usr/sbin/init" --cmd '["--log-level=info", "--unit=multi-user.target"]' worker
scratchmnt=$(buildah mount worker)
mkdir -p /install
mount --bind "${scratchmnt}" /install

log_text "Creating podman image"
rsync -a \
  --exclude "boot/*" \
  --exclude "dev/*" \
  --exclude "etc/fstab" \
  --exclude "etc/crypttab" \
  --exclude "etc/crypttab.initramfs" \
  --exclude "proc/*" \
  --exclude "sys/*" \
  --exclude "run/*" \
  --exclude "mnt/*" \
  --exclude "media/*" \
  --exclude "share/*" \
  --exclude "win/*" \
  --exclude "tmp/*" \
  --exclude "var/tmp/*" \
  --exclude "var/cache/pacman/pkg/*" \
  ${MOUNTPOINT%%/}/ /install/

log_text "Fixating podman image"
tee /install/etc/.updated /install/var/.updated <<EOF
# For details, see manpage of systemd.unit -> 'ConditionNeedsUpdate'.
TIMESTAMP_NSEC=$(date +%s%N)
EOF
chmod 644 /install/etc/.updated /install/var/.updated

fuser -km /install || true
sync
umount /install || true
buildah umount worker

pushd /share
  buildah commit worker worker
  podman save -o wildcardos-buildah.tar worker
  gzip -k wildcardos-buildah.tar
  ls -l --si wildcardos-buildah.tar wildcardos-buildah.tar.gz
popd
