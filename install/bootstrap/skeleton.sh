#!/usr/bin/env bash

log_text "Create skeleton for bash profile"
cp ${SCRIPTDIR}/bootstrap/bash_profile /etc/skel/.bash_profile
cp ${SCRIPTDIR}/bootstrap/bash_profile "${USERHOME}"/.bash_profile
chown "${USERID}:${USERGRP}" "${USERHOME}"/.bash_profile
cp ${SCRIPTDIR}/bootstrap/bash_profile "${ROOTHOME}"/.bash_profile

log_text "Create skeleton for bashrc"
cp ${SCRIPTDIR}/bootstrap/bashrc /etc/skel/.bashrc
cp ${SCRIPTDIR}/bootstrap/bashrc "${USERHOME}"/.bashrc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.bashrc
cp ${SCRIPTDIR}/bootstrap/bashrc "${ROOTHOME}"/.bashrc

log_text "Create skeleton for starship"
mkdir -p /etc/skel/.config "${ROOTHOME}"/.config "${USERHOME}"/.config
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config
cp ${SCRIPTDIR}/bootstrap/starship.toml /etc/skel/.config/starship.toml
cp ${SCRIPTDIR}/bootstrap/starship.toml "${USERHOME}"/.config/starship.toml
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/starship.toml
cp ${SCRIPTDIR}/bootstrap/starship.toml "${ROOTHOME}"/.config/starship.toml

log_text "Create skeleton for powershell"
mkdir -p /etc/skel/.config/powershell "${ROOTHOME}"/.config/powershell "${USERHOME}"/.config/powershell
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/powershell
cp ${SCRIPTDIR}/bootstrap/profile.ps1 /etc/skel/.config/powershell/Microsoft.PowerShell_profile.ps1
cp ${SCRIPTDIR}/bootstrap/profile.ps1 "${USERHOME}"/.config/powershell/Microsoft.PowerShell_profile.ps1
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/powershell/Microsoft.PowerShell_profile.ps1
cp ${SCRIPTDIR}/bootstrap/profile.ps1 "${ROOTHOME}"/.config/powershell/Microsoft.PowerShell_profile.ps1

log_text "Create skeleton for htop"
mkdir -p /etc/skel/.config/htop "${ROOTHOME}"/.config/htop "${USERHOME}"/.config/htop
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/htop
cp ${SCRIPTDIR}/bootstrap/htoprc /etc/skel/.config/htop/htoprc
cp ${SCRIPTDIR}/bootstrap/htoprc "${USERHOME}"/.config/htop/htoprc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/htop/htoprc
cp ${SCRIPTDIR}/bootstrap/htoprc "${ROOTHOME}"/.config/htop/htoprc

log_text "Create skeleton for nanorc"
cp ${SCRIPTDIR}/bootstrap/nanorc /etc/skel/.nanorc
cp ${SCRIPTDIR}/bootstrap/nanorc "${USERHOME}"/.nanorc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.nanorc
cp ${SCRIPTDIR}/bootstrap/nanorc "${ROOTHOME}"/.nanorc

log_text "Create skeleton for inputrc"
cp ${SCRIPTDIR}/bootstrap/inputrc /etc/skel/.inputrc
cp ${SCRIPTDIR}/bootstrap/inputrc "${USERHOME}"/.inputrc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.inputrc
cp ${SCRIPTDIR}/bootstrap/inputrc "${ROOTHOME}"/.inputrc

log_text "Configure script to execute on first user login after boot"
cp ${SCRIPTDIR}/bootstrap/userlogin.service /etc/systemd/user/userlogin.service
cp ${SCRIPTDIR}/bootstrap/userlogin.sh /usr/local/bin/userlogin.sh
chmod +x /usr/local/bin/userlogin.sh
systemctl --global enable userlogin.service
