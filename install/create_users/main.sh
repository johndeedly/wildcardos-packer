#!/usr/bin/env bash

log_text "Enable root account and one user"
ROOTID=$(getent passwd 0 | cut -d: -f1)
ROOTHASH=$(openssl passwd -6 -salt abcxyz "$(<${SCRIPTDIR}/create_users/root.pwd)")
sed -i 's/^'"$ROOTID"':[^:]*:/'"$ROOTID"':'"${ROOTHASH//\//\\/}"':/' /etc/shadow
groupadd --system --force users
groupadd --system --force wheel
USERID=$(<${SCRIPTDIR}/create_users/user.id)
USERHASH=$(openssl passwd -6 -salt abcxyz "$(<${SCRIPTDIR}/create_users/user.pwd)")
useradd -m -u 1000 -g users -G wheel "$USERID"
sed -i 's/^'"$USERID"':[^:]*:/'"$USERID"':'"${USERHASH//\//\\/}"':/' /etc/shadow

log_text "Read administrative database to get usernames, group names and home directories"
ROOTID=$(getent passwd 0 | cut -d: -f1)
ROOTGRP=$(getent group "$(getent passwd 0 | cut -d: -f4)" | cut -d: -f1)
ROOTHOME=$(getent passwd 0 | cut -d: -f6)
USERID=$(getent passwd 1000 | cut -d: -f1)
USERGRP=$(getent group "$(getent passwd 1000 | cut -d: -f4)" | cut -d: -f1)
USERHOME=$(getent passwd 1000 | cut -d: -f6)
TEMPID=$(getent passwd 65534 | cut -d: -f1)
TEMPGRP=$(getent group "$(getent passwd 65534 | cut -d: -f4)" | cut -d: -f1)
TEMPHOME=$(getent passwd 65534 | cut -d: -f6)

log_text "Make sure temp user has a temporary writable home"
if [ -n "${TEMPHOME}" ] && [ -e "${TEMPHOME}" ]; then
  statU="$(stat -c '%U' "${TEMPHOME}")"
  if [ "x${statU}" != "x${TEMPID}" ]; then
    TEMPHOME="/var/tmp"
  fi
else
  TEMPHOME="/var/tmp"
fi

log_text "After this point a user needs to be present inside the environment"
if [ -z "$ROOTID" ] || [ -z "$USERID" ] || [ -z "$TEMPID" ]; then
  log_error "No root, user or temp user detected: something is wrong here"
  exit 1
fi

log_text "Create subuids and subgids"
tee /etc/subuid <<EOF
${ROOTID}:100000:65536
${USERID}:165536:65536
EOF
tee /etc/subgid <<EOF
${ROOTID}:100000:65536
${USERID}:165536:65536
EOF

if [ -n "$VERBOSE" ]; then
  echo -en "root user:  ${ROOTID}|${ROOTGRP}|${ROOTHOME}\n"
  echo -en "daily user: ${USERID}|${USERGRP}|${USERHOME}\n"
  echo -en "temp user:  ${TEMPID}|${TEMPGRP}|${TEMPHOME}\n"
fi
