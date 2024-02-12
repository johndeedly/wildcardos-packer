#!/usr/bin/env bash

log_text "Prepare debootstrap and eatmydata"
archiso_pacman_whenneeded debootstrap libeatmydata

log_text "List of basic packages to create a system with filesystem drivers"
PACKAGE_LIST=(
    # always needed, always present
    ubuntu-minimal
    doas
    eatmydata
    curl
    wget
    zstd
    # systemd base
    dbus-broker
    systemd
    systemd-homed
    systemd-boot
    # linux kernel and headers
    linux-generic
    linux-image-generic
    linux-headers-generic
    # firmwares to support more hardware
    linux-firmware
    # efi system per default
    efibootmgr
    # efi partition, btrfs system, lvm2 data and swap
    dosfstools
    lvm2
    btrfs-progs
    # initramfs and cryptfs
    initramfs-tools
    cryptsetup
    cryptsetup-initramfs
)
if [ -n "$INSTALLED_HARDWARE_CPU_AMD" ]; then
    PACKAGE_LIST+=( amd64-microcode )
fi
if [ -n "$INSTALLED_HARDWARE_CPU_INTEL" ]; then
    PACKAGE_LIST+=( intel-microcode )
fi
if [ -n $INSTALLED_HARDWARE_WIRELESS ]; then
    PACKAGE_LIST+=( iwd iw )
fi
if [ -n $INSTALLED_HARDWARE_BLUETOOTH ]; then
    PACKAGE_LIST+=( bluez bluez-tools )
fi
if [ -n $INSTALLED_HARDWARE_VIRTUAL_MACHINE ]; then
    PACKAGE_LIST+=( virtualbox-guest-utils qemu-guest-agent )
fi

log_text "Configure kernel image creation without symlinks in boot"
mkdir -p ${MOUNTPOINT%%/}/etc
cp "${SCRIPTDIR}/base_bootable/kernel-img.conf" ${MOUNTPOINT%%/}/etc/

log_text "Create post update initrd hook"
mkdir -p ${MOUNTPOINT%%/}/etc/initramfs/post-update.d
cp "${SCRIPTDIR}/base_bootable/zz-remove-version-string" ${MOUNTPOINT%%/}/etc/initramfs/post-update.d/
chmod a+x ${MOUNTPOINT%%/}/etc/initramfs/post-update.d/zz-remove-version-string

log_text "Create initrd hook to copy filesystem check executables to the boot image"
mkdir -p ${MOUNTPOINT%%/}/etc/initramfs-tools/hooks
cp "${SCRIPTDIR}/base_bootable/e2fsck.sh" ${MOUNTPOINT%%/}/etc/initramfs-tools/hooks/
chmod a+x ${MOUNTPOINT%%/}/etc/initramfs-tools/hooks/e2fsck.sh

log_text "Initrd should not make backups on vfat as 'ln -s' is not supported"
mkdir -p ${MOUNTPOINT%%/}/etc/initramfs-tools
cp "${SCRIPTDIR}/base_bootable/update-initramfs.conf" ${MOUNTPOINT%%/}/etc/initramfs-tools/

log_text "Root needs to find it's utilities under /sbin"
tee -a ${MOUNTPOINT%%/}/root/.bash_profile <<EOF
export PATH="\$PATH:/usr/local/sbin:/usr/sbin"
EOF

log_text "Make sure the resuming device after cryptsetup is the rootfs uuid"
ROOTUUID=$(blkid ${PART_ROOT} -s UUID -o value)
mkdir -p ${MOUNTPOINT%%/}/etc/initramfs-tools/conf.d
tee ${MOUNTPOINT%%/}/etc/initramfs-tools/conf.d/resume <<EOF
RESUME=UUID=${ROOTUUID}
EOF

log_text "Install base system into mountpoint folder"
if [ ! -e /usr/share/debootstrap/scripts/${UBUNTU_RELEASE} ]; then
    # all newer releases softlink to gutsy, so we try the same
    ln -s gutsy /usr/share/debootstrap/scripts/${UBUNTU_RELEASE}
fi
eatmydata debootstrap --include=$(echo -en "${PACKAGE_LIST[@]}" | tr ' ' ',') --components=main,universe ${UBUNTU_RELEASE} ${MOUNTPOINT%%/} https://ftp.halifax.rwth-aachen.de/ubuntu
sync
