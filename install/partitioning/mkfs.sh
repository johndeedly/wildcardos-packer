#!/usr/bin/env bash

dd if=/dev/zero of=${PART_EFI} bs=1M count=16 iflag=fullblock status=progress
mkfs.fat -F32 -n EFI ${PART_EFI}

dd if=/dev/zero of=${PART_DATA} bs=1M count=32 iflag=fullblock status=progress
if [[ ${TAGS[@]} =~ "encryption" ]]; then
  # create key file with password
  mount ${PART_EFI} /mnt
  openssl rand -base64 12 > /mnt/luks.key
  # encrypt and unlock
  cat /mnt/luks.key | (cryptsetup -q -v luksFormat ${PART_DATA} -d -)
  cat /mnt/luks.key | (cryptsetup -q open ${PART_DATA} data -d -)
  umount /mnt
  pvcreate -f /dev/mapper/data
  vgcreate -f volgrp /dev/mapper/data
else
  pvcreate -f ${PART_DATA}
  vgcreate -f volgrp ${PART_DATA}
fi
lvcreate -L ${SWAPSIZE}M volgrp -n swap
lvcreate -l 100%FREE volgrp -n data

if [[ ${TAGS[@]} =~ "dualboot" ]]; then
  dd if=/dev/zero of=${PART_MSR} bs=1M count=16 iflag=fullblock status=progress
  dd if=/dev/zero of=${PART_WIN} bs=1M count=16 iflag=fullblock status=progress
  mkfs.ntfs -f -L WINDOWS ${PART_WIN}
  dd if=/dev/zero of=${PART_DIAG} bs=1M count=16 iflag=fullblock status=progress
  mkfs.ntfs -f -L WINRE ${PART_DIAG}
fi
dd if=/dev/zero of=${PART_ROOT} bs=1M count=16 iflag=fullblock status=progress
mkfs.btrfs -L ROOT ${PART_ROOT}
if [[ ${TAGS[@]} =~ "dualboot" ]]; then
  dd if=/dev/zero of=${PART_WINDATA} bs=1M count=16 iflag=fullblock status=progress
  mkfs.ntfs -f -L WINDATA ${PART_WINDATA}
fi
dd if=/dev/zero of=/dev/volgrp/swap bs=1M count=16 iflag=fullblock status=progress
mkswap -L SWAP /dev/volgrp/swap
swapon /dev/volgrp/swap
dd if=/dev/zero of=/dev/volgrp/data bs=1M count=16 iflag=fullblock status=progress
mkfs.btrfs -L DATA /dev/volgrp/data
