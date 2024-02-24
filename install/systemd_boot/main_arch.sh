#!/usr/bin/env bash

log_text "Create boot image and loader"
if [[ ${TAGS[@]} =~ "encryption" ]]; then
    sed -i "s/^MODULES=(.*/MODULES=(vfat)/g" ${MOUNTPOINT%%/}/etc/mkinitcpio.conf
    sed -i "s/^HOOKS=(.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block lvm2 sd-encrypt filesystems fsck)/g" ${MOUNTPOINT%%/}/etc/mkinitcpio.conf
else
    sed -i "s/^HOOKS=(.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block lvm2 filesystems fsck)/g" ${MOUNTPOINT%%/}/etc/mkinitcpio.conf
fi
arch-chroot ${MOUNTPOINT%%/} mkinitcpio -P

log_text "Install systemd-boot"
arch-chroot ${MOUNTPOINT%%/} bootctl --esp-path=/boot install

log_text "Configure facts"
ROOTUUID=$(blkid ${PART_ROOT} -s UUID -o value)
BOOTOPTIONS="options root=UUID=${ROOTUUID} rootflags=subvol=@ rw loglevel=3 acpi=force acpi_osi=Linux"
AMDINITRDOPTS=""
if [ -n "$INSTALLED_HARDWARE_CPU_AMD" ]; then
    AMDINITRDOPTS="initrd  /amd-ucode.img"
fi
INTELINITRDOPTS=""
if [ -n "$INSTALLED_HARDWARE_CPU_INTEL" ]; then
    INTELINITRDOPTS="initrd  /intel-ucode.img"
fi

log_text "Default kernel boot option"
mkdir -p ${MOUNTPOINT%%/}/boot/loader/entries
tee ${MOUNTPOINT%%/}/boot/loader/entries/80_arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
${AMDINITRDOPTS}
${INTELINITRDOPTS}
initrd  /initramfs-linux.img
${BOOTOPTIONS}
EOF

log_text "Fallback kernel boot option"
tee ${MOUNTPOINT%%/}/boot/loader/entries/60_arch_fallback.conf <<EOF
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
${AMDINITRDOPTS}
${INTELINITRDOPTS}
initrd  /initramfs-linux-fallback.img
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
