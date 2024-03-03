#!/usr/bin/env bash

# error handling
set -E -o functrace
err_report() {
  echo "errexit command '${1}' returned ${2} on line $(caller)" 1>&2
  exit "${2}"
}
trap 'err_report "${BASH_COMMAND}" "${?}"' ERR

mkdir -p output

ARCHISODATE=$(curl -sL "https://archlinux.org/download/" | grep -oE 'magnet:.*?dn=archlinux-.*?-x86_64.iso' | cut -d- -f2)

[ -f output/cloud-init.img ] && rm output/cloud-init.img
[ -f "output/archlinux-${ARCHISODATE}-x86_64-with-cidata.iso" ] && rm "output/archlinux-${ARCHISODATE}-x86_64-with-cidata.iso"
mkfs.fat -C -n CIDATA output/cloud-init.img 2048
mcopy -i output/cloud-init.img CIDATA/meta-data CIDATA/user-data CIDATA/network-config ::
xorriso -indev "archlinux-${ARCHISODATE}-x86_64.iso" -outdev "output/archlinux-${ARCHISODATE}-x86_64-with-cidata.iso" -append_partition 3 0x0c output/cloud-init.img -boot_image any replay
