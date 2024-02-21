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
        mount -t 9p -o trans=virtio,version=9p2000.L,rw host.0 /share || mount -t vboxsf -o rw host.0 /share
    else
        log_error "/share doesn't appear to be mounted, aborting to prevent accidentally filling up the main filesystem"
        exit 3
    fi
fi

log_text "Install pxe boot setup"8
pacman_whenneeded mkinitcpio-nfs-utils curl ca-certificates-utils cifs-utils nfs-utils nbd
# TODO: why are files from linux-firmware conflicting with these packages?
pacman -S --overwrite=\* --noconfirm --noprogressbar --needed amd-ucode intel-ucode

log_text "Create skeleton for pxe boot mkinitcpio"
mkdir -p /usr/lib/initcpio/{install,hooks}
cp "${SCRIPTDIR}"/pxeboot/install/* /usr/lib/initcpio/install/
cp "${SCRIPTDIR}"/pxeboot/hooks/* /usr/lib/initcpio/hooks/
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

# fix file access
chown -R ${ROOTID}:${ROOTGRP} /srv/tftp
find /srv/tftp -type d -exec chmod 755 {} \;
find /srv/tftp -type f -exec chmod 644 {} \;

log_text "Copy tftp folder to share"
if [ ! -f /share/pxe/tftp/efi64/arch/x86_64/vmlinuz-linux ]; then
  mkdir -p /share/pxe/tftp
  cp -r /srv/tftp/* /share/pxe/tftp/
fi
