#!/usr/bin/env bash

log_text "Blacklist some packages"
mkdir -p ${MOUNTPOINT%%/}/etc/apt/preferences.d
cp "${SCRIPTDIR}/package_manager/ignored-packages" ${MOUNTPOINT%%/}/etc/apt/preferences.d/

log_text "Enable repositories"
tee /etc/apt/sources.list <<EOF
deb  https://ftp.halifax.rwth-aachen.de/ubuntu  ${UBUNTU_RELEASE}           main universe multiverse
deb  https://ftp.halifax.rwth-aachen.de/ubuntu  ${UBUNTU_RELEASE}-security  main universe multiverse
EOF

log_text "Update"
apt update
