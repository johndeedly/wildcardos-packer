#!/usr/bin/env bash

# error handling
set -E -o functrace
err_report() {
  echo "errexit command '${1}' returned ${2} on line $(caller)" 1>&2
  exit "${2}"
}
trap 'err_report "${BASH_COMMAND}" "${?}"' ERR

# read passed down environment
[ -e "${SCRIPTDIR}/nspawn-env" ] && source "${SCRIPTDIR}/nspawn-env"

# common functions
source "${SCRIPTDIR}/common.sh"


log_text "Create users"
source "${SCRIPTDIR}/create_users/main.sh"

log_text "I18N"
sed -i 's/^#\?de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf
rm /etc/localtime || true
ln -s /usr/share/zoneinfo/CET /etc/localtime
tee /etc/vconsole.conf <<EOF
KEYMAP=de-latin1
XKBLAYOUT=de
XKBMODEL=pc105
EOF
loadkeys de-latin1 || true

log_text "Configure package manager"
source "${SCRIPTDIR}/package_manager/main.sh"

log_text "Install and configure placeholders"
source "${SCRIPTDIR}/placeholders/main.sh"

if [[ ${TAGS[@]} =~ "bootstrap" ]]; then
  source "${SCRIPTDIR}/bootstrap/main.sh"
fi

if [[ ${TAGS[@]} =~ "pxeboot" ]]; then
  source "${SCRIPTDIR}/pxeboot/main.sh"
fi
