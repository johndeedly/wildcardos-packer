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

log_text "Configure text-mode console"
source "${SCRIPTDIR}/console_setup/main.sh"

log_text "Configure package manager"
source "${SCRIPTDIR}/package_manager/main.sh"

log_text "Install and configure placeholders"
source "${SCRIPTDIR}/placeholders/main.sh"

log_text "Configure system drivers"
source "${SCRIPTDIR}/drivers/main.sh"

if [[ ${TAGS[@]} =~ "bootstrap" ]]; then
  source "${SCRIPTDIR}/bootstrap/main.sh"
fi

if [[ ${TAGS[@]} =~ "graphical" ]]; then
  source "${SCRIPTDIR}/graphical/main.sh"
fi

if [[ ${TAGS[@]} =~ "cinnamon" ]]; then
  source "${SCRIPTDIR}/cinnamon/main.sh"
fi

if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" ]]; then
    log_text "Filesystem services"
    source "${SCRIPTDIR}/filesystem_services/main.sh"
fi

if [[ ${TAGS[@]} =~ "pxeboot" ]]; then
  source "${SCRIPTDIR}/pxeboot/main.sh"
fi

if [[ ${TAGS[@]} =~ "pxeserve" ]]; then
  source "${SCRIPTDIR}/pxeserve/main.sh"
fi
