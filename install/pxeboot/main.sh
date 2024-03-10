#!/usr/bin/env bash

log_text "Install pxe boot setup"
pacman_whenneeded mkinitcpio-nfs-utils curl ca-certificates-utils cifs-utils nfs-utils nbd open-iscsi nvme-cli
# TODO: why are files from linux-firmware conflicting with these packages?
pacman -S --overwrite=\* --noconfirm --noprogressbar --needed amd-ucode intel-ucode

log_text "Create skeleton for pxe boot mkinitcpio"
mkdir -p /etc/initcpio/{install,hooks}
cp "${SCRIPTDIR}"/pxeboot/install/* /etc/initcpio/install/
chmod a+x /etc/initcpio/install/*
cp "${SCRIPTDIR}"/pxeboot/hooks/* /etc/initcpio/hooks/
chmod a+x /etc/initcpio/hooks/*
mkdir -p /etc/mkinitcpio{,.conf}.d
cp "${SCRIPTDIR}"/pxeboot/pxe.conf /etc/
cp "${SCRIPTDIR}"/pxeboot/pxe.preset /etc/mkinitcpio.d/

log_text "Generate initcpio for pxe boot"
mkdir -p /var/tmp/mkinitcpio
mkinitcpio -p pxe -t /var/tmp/mkinitcpio
rm -rf /var/tmp/mkinitcpio

log_text "Copy everything to the tftp folder"
mkdir -p /srv/tftp/arch/x86_64
cp /boot/vmlinuz-linux /boot/initramfs-linux-pxe.img /srv/tftp/arch/x86_64/
cp /boot/intel-ucode.img /boot/amd-ucode.img /srv/tftp/arch/

ITER=( "bios" "efi32" "efi64" )
for item in "${ITER[@]}"
do
  mkdir -p "/srv/tftp/$item/arch/x86_64"
  ln /srv/tftp/arch/x86_64/vmlinuz-linux "/srv/tftp/$item/arch/x86_64/vmlinuz-linux"
  ln /srv/tftp/arch/x86_64/initramfs-linux-pxe.img "/srv/tftp/$item/arch/x86_64/initramfs-linux-pxe.img"
  ln /srv/tftp/arch/intel-ucode.img "/srv/tftp/$item/arch/intel-ucode.img"
  ln /srv/tftp/arch/amd-ucode.img "/srv/tftp/$item/arch/amd-ucode.img"
done
unset item
unset ITER

log_text "Fix file access"
chown -R ${ROOTID}:${ROOTGRP} /srv/tftp
find /srv/tftp -type d -exec chmod 755 {} \;
find /srv/tftp -type f -exec chmod 644 {} \;

if mountpoint -q -- /share; then
  log_text "Share is a mountpoint"
  if [ ! -f /share/pxe/tftp/efi64/arch/x86_64/vmlinuz-linux ]; then
    log_text "Copy tftp folder to share"
    mkdir -p /share/pxe/tftp
    cp -r /srv/tftp/* /share/pxe/tftp/
  fi
fi
