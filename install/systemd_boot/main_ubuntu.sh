#!/usr/bin/env bash

log_text "Create boot image and loader"
if [[ ${TAGS[@]} =~ "encryption" ]]; then
    tee -a ${MOUNTPOINT%%/}/etc/modules <<EOF
vfat
EOF
    tee -a ${MOUNTPOINT%%/}/etc/initramfs-tools/modules <<EOF
vfat
EOF
fi
arch-chroot ${MOUNTPOINT%%/} /bin/bash --login -c 'PATH="/usr/local/sbin:/usr/sbin:/usr/local/bin:/usr/bin:/root/.local/bin"; update-initramfs -u'

log_text "Install systemd-boot"
arch-chroot ${MOUNTPOINT%%/} bootctl --esp-path=/boot install

log_text "Configure facts"
ROOTUUID=$(blkid ${PART_ROOT} -s UUID -o value)
BOOTOPTIONS="options root=UUID=${ROOTUUID} rootflags=subvol=@ rw loglevel=3 acpi=force acpi_osi=Linux"

log_text "Default kernel boot option"
mkdir -p ${MOUNTPOINT%%/}/boot/loader/entries
tee ${MOUNTPOINT%%/}/boot/loader/entries/80_ubuntu.conf <<EOF
title   Ubuntu
linux   /vmlinuz
initrd  /initrd.img
${BOOTOPTIONS}
EOF

log_text "Windows boot option"
tee ${MOUNTPOINT%%/}/boot/loader/entries/40_windows.conf <<EOF
title   Windows Boot Manager
efi     /EFI/Microsoft/Boot/bootmgfw.efi
EOF

log_text "Configure systemd-boot"
tee ${MOUNTPOINT%%/}/boot/loader/loader.conf <<EOF
default  @saved
timeout  4
editor   no
auto-entries   no
auto-firmware  yes
console-mode   max
EOF

log_text "Throw the dice for the random seed"
mount -o remount,rw ${MOUNTPOINT%%/}/boot
arch-chroot ${MOUNTPOINT%%/} bootctl random-seed
