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
    if ! wget --referer="http://ftp.halifax.rwth-aachen.de/archlinux/iso/${ARCHISODATE}/" --user-agent="Mozilla/999.0 (X11; Linux x86_64) AppleWebKit/999.0 (KHTML, like Gecko) Chrome/999.0 Firefox/999.0 Safari/999.0" "http://ftp.halifax.rwth-aachen.de/archlinux/iso/${ARCHISODATE}/archlinux-${ARCHISODATE}-x86_64.iso"; then
        log_error "Download error"
        exit 1
    fi
    sync
fi

log_text "Validate checksum of archlinux-${ARCHISODATE}-x86_64.iso"
if ! echo "${ARCHISOHASH}" | sha256sum --check --status; then
    log_error "Checksum mismatch"
    exit 1
fi

ARCHISOMODDED="archlinux-${ARCHISODATE}-x86_64-with-cidata-and-install-scripts.iso"
[ -f output/cloud-init.img ] && rm output/cloud-init.img
[ -f output/install.img ] && rm output/install.img
[ -f "output/${ARCHISOMODDED}" ] && rm "output/${ARCHISOMODDED}"

log_text "Create CIDATA image to append it to the archiso image"
xorriso -volid "CIDATA" \
        -outdev "output/cloud-init.img" \
        -map CIDATA/meta-data /meta-data \
        -map CIDATA/network-config /network-config \
        -map CIDATA/user-data /user-data

log_text "Create INSTALL image to append it to the archiso image"
xorriso -volid "INSTALL" \
        -outdev "output/install.img" \
        -map install /install/ \
        -map packer /packer/ \
        -map LICENSE /LICENSE \
        -map pipeline.bat /pipeline.bat \
        -map pipeline.ps1 /pipeline.ps1 \
        -map pipeline.sh /pipeline.sh

log_text "Create the modified archiso image"
xorriso -indev "archlinux-${ARCHISODATE}-x86_64.iso" \
        -outdev "output/${ARCHISOMODDED}" \
        -append_partition 3 0x83 output/cloud-init.img \
        -append_partition 4 0x83 output/install.img \
        -boot_image any replay
