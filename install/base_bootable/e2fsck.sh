#!/bin/sh
. /usr/share/initramfs-tools/hook-functions
copy_exec /sbin/e2fsck /sbin
copy_exec /sbin/fsck /sbin
copy_exec /sbin/fsck.ext2 /sbin
copy_exec /sbin/fsck.ext4 /sbin
copy_exec /sbin/fsck.btrfs /sbin
copy_exec /sbin/logsave /sbin
