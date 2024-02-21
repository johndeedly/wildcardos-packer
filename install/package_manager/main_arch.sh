#!/usr/bin/env bash

log_text "Download pacman mirrorlist"
curl -sL 'https://archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&ip_version=6' > /etc/pacman.d/mirrorlist

log_text "Enable full mirrorlist"
sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist

log_text "Enable multilib in config"
sed -i '/^#\?\[multilib\]/{:a;N;/\n$/!ba;s/.*/[multilib]\nInclude = \/etc\/pacman.d\/mirrorlist\n/;}' /etc/pacman.conf

log_text "Enable parallel downloads"
sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf

log_text "Save some storage space (unneeded manuals in other languages and bogus background images)"
sed -i 's/^#\?NoExtract.*/NoExtract = usr\/share\/help\/* !usr\/share\/help\/C\/* !usr\/share\/help\/de*\/* !usr\/share\/help\/en*\/*\nNoExtract = usr\/share\/man\/* !usr\/share\/man\/de*\/* !usr\/share\/man\/man*\/*\nNoExtract = usr\/share\/backgrounds\/*\/* !usr\/share\/backgrounds\/archlinux\/*/' /etc/pacman.conf

log_text "Refresh pacman"
pacman -Syy --noconfirm --needed --noprogressbar --color=auto

log_text "Enable chaotic-aur repository"
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman_package_whenneeded 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman_package_whenneeded 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
tee -a /etc/pacman.conf <<EOF > /dev/null

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

log_text "Refresh pacman again"
pacman -Syyuu --noconfirm --needed --noprogressbar --color=auto
