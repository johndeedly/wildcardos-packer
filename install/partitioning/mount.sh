#!/usr/bin/env bash

# create all btrfs subvols
mount -o noatime ${PART_ROOT} /mnt
btrfs subvol create /mnt/@
umount /mnt
mount -o noatime /dev/volgrp/data /mnt
btrfs subvol create /mnt/@home
btrfs subvol create /mnt/@var
btrfs subvol create /mnt/@root
btrfs subvol create /mnt/@srv
btrfs subvol create /mnt/@opt
umount /mnt

# mount root filesystem
mount --mkdir -o subvol=@,compress=zstd:4,noatime ${PART_ROOT} ${MOUNTPOINT%%/}

# mount boot into place
mkdir -m755 ${MOUNTPOINT%%/}/boot
mount ${PART_EFI} ${MOUNTPOINT%%/}/boot

# create and protect /mnt folder
mkdir -m000 ${MOUNTPOINT%%/}/mnt
chattr +i ${MOUNTPOINT%%/}/mnt

# mount all the other data subvols into place
mkdir -m755 ${MOUNTPOINT%%/}/home
mount -o subvol=@home,compress=zstd:4,noatime /dev/volgrp/data ${MOUNTPOINT%%/}/home
chmod 755 ${MOUNTPOINT%%/}/home

mkdir -m755 ${MOUNTPOINT%%/}/var
mount -o subvol=@var,compress=zstd:4,noatime /dev/volgrp/data ${MOUNTPOINT%%/}/var
chmod 755 ${MOUNTPOINT%%/}/var

mkdir -m750 ${MOUNTPOINT%%/}/root
mount -o subvol=@root,compress=zstd:4,noatime /dev/volgrp/data ${MOUNTPOINT%%/}/root
chmod 750 ${MOUNTPOINT%%/}/root

mkdir -m755 ${MOUNTPOINT%%/}/srv
mount -o subvol=@srv,compress=zstd:4,noatime /dev/volgrp/data ${MOUNTPOINT%%/}/srv
chmod 755 ${MOUNTPOINT%%/}/srv

mkdir -m755 ${MOUNTPOINT%%/}/opt
mount -o subvol=@opt,compress=zstd:4,noatime /dev/volgrp/data ${MOUNTPOINT%%/}/opt
chmod 755 ${MOUNTPOINT%%/}/opt

# enable qemu shared folder for host.0 bindmount
if mountpoint -q -- /share; then
  mkdir -m777 ${MOUNTPOINT%%/}/share
  umount /share
  mount -t 9p -o trans=virtio,version=9p2000.L,rw host.0 ${MOUNTPOINT%%/}/share
fi

if [[ ${TAGS[@]} =~ "dualboot" ]]; then
  mkdir -m755 ${MOUNTPOINT%%/}/win
  mkdir -m755 ${MOUNTPOINT%%/}/win/sys
  mount -t ntfs3 -o rw,noatime,uid=0,gid=0,iocharset=utf8,discard,nohidden,hide_dot_files,windows_names ${PART_WIN} ${MOUNTPOINT%%/}/win/sys
  chmod 1777 ${MOUNTPOINT%%/}/win/sys

  mkdir -m755 ${MOUNTPOINT%%/}/win/diag
  mount -t ntfs3 -o rw,noatime,uid=0,gid=0,iocharset=utf8,discard,nohidden,hide_dot_files,windows_names ${PART_DIAG} ${MOUNTPOINT%%/}/win/diag
  chmod 1777 ${MOUNTPOINT%%/}/win/diag

  mkdir -m755 ${MOUNTPOINT%%/}/win/data
  mount -t ntfs3 -o rw,noatime,uid=0,gid=0,iocharset=utf8,discard,nohidden,hide_dot_files,windows_names ${PART_WINDATA} ${MOUNTPOINT%%/}/win/data
  chmod 1777 ${MOUNTPOINT%%/}/win/data
fi
