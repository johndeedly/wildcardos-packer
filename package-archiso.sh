#!/usr/bin/env bash

# error handling
set -E -o functrace
err_report() {
  echo "errexit command '${1}' returned ${2} on line $(caller)" 1>&2
  exit "${2}"
}
trap 'err_report "${BASH_COMMAND}" "${?}"' ERR

function log_text() {
    # bold yellow
    echo -e "\033[1;33m:: $*\033[0m"
}

function log_error() {
    # bold red
    echo -e "\033[1;31m!! $*\033[0m"
}

mkdir -p output

ARCHISODATE=$(curl -sL "https://archlinux.org/download/" | grep -oE 'magnet:.*?dn=archlinux-.*?-x86_64.iso' | cut -d- -f2)
ARCHISOHASH=$(curl -sL "http://ftp.halifax.rwth-aachen.de/archlinux/iso/${ARCHISODATE}/sha256sums.txt" | grep -oE "^.*?${ARCHISODATE}-x86_64.iso$")

if ! [ -f "archlinux-${ARCHISODATE}-x86_64.iso" ]; then
    log_text "Downloading archlinux-${ARCHISODATE}-x86_64.iso"
    if ! wget -o "archlinux-${ARCHISODATE}-x86_64.iso" "http://ftp.halifax.rwth-aachen.de/archlinux/iso/${ARCHISODATE}/archlinux-${ARCHISODATE}-x86_64.iso"; then
        log_error "Download error"
        exit 1
    fi
fi

log_text "Validate checksum of archlinux-${ARCHISODATE}-x86_64.iso"
if ! echo "${ARCHISOHASH}" | sha256sum --check --status; then
    log_error "Checksum mismatch"
    exit 1
fi

ARCHISOMODDED="archlinux-${ARCHISODATE}-x86_64-with-cidata-and-install-scripts.iso"
[ -f output/cloud-init.img ] && rm output/cloud-init.img
[ -f "output/${ARCHISOMODDED}" ] && rm "output/${ARCHISOMODDED}"

log_text "Create CIDATA image to append it to the archiso image"
mkfs.fat -C -n CIDATA output/cloud-init.img 2048
mcopy -i output/cloud-init.img CIDATA/meta-data CIDATA/user-data CIDATA/network-config ::

log_text "Create the modified archiso image"
xorriso -indev "archlinux-${ARCHISODATE}-x86_64.iso" \
        -outdev "output/${ARCHISOMODDED}" \
        -append_partition 3 0x0c output/cloud-init.img \
        -map CIDATA /wildcard-os/CIDATA/ \
        -map install /wildcard-os/install/ \
        -map packer /wildcard-os/packer/ \
        -map LICENSE /wildcard-os/LICENSE \
        -map pipeline.bat /wildcard-os/pipeline.bat \
        -map pipeline.ps1 /wildcard-os/pipeline.ps1 \
        -map pipeline.sh /wildcard-os/pipeline.sh \
        -boot_image any replay
