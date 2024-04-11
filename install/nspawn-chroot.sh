#!/usr/bin/env bash

# https://www.enricozini.org/blog/2021/debian/nspawn-chroot-maintenance/
scriptdir=$(realpath $(dirname $0))
chroot="$1"
shift
# TODO, maybe? Bug with "--resolv-conf=bind-host" when guest tries to modify resolv.conf in pacman steps
exec systemd-nspawn --capability=CAP_SYS_CHROOT,CAP_NET_ADMIN,CAP_NET_RAW --resolv-conf=bind-host --link-journal=host --bind="$scriptdir" --setenv="SCRIPTDIR=$scriptdir" --console=pipe -qD "$chroot" -- "$@"
