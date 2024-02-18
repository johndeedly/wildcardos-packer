#!/usr/bin/env bash

# error handling
set -E -o functrace
err_report() {
  echo "errexit command '${1}' returned ${2} on line $(caller)" 1>&2
  exit "${2}"
}
trap 'err_report "${BASH_COMMAND}" "${?}"' ERR

if ! mount -o remount,size=75% /run/archiso/cowspace; then
echo "not running inside an archiso environment - protecting the host from damage" 1>&2
exit 1
fi

while ! systemctl show pacman-init.service | grep SubState=exited; do
  systemctl --no-pager status -n0 pacman-init.service || true
  sleep 5
done

if ! pacman -Q powershell-bin; then
pacman -Syy
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U --needed --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --needed --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
tee -a /etc/pacman.conf <<EOF > /dev/null

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
pacman -Syy

echo "install powershell"
pacman -S --needed --noconfirm --color=auto powershell-bin
fi

if ! pacman -Q packer; then
echo "install packer"
pacman -S --needed --noconfirm --color=auto packer
fi

echo "execute installation"
./pipeline.ps1 "$@"
