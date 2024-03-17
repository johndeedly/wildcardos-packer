#!/usr/bin/env bash

log_text Create skeleton for dunstrc
mkdir -p /etc/skel/.config/dunst "${ROOTHOME}"/.config/dunst "${USERHOME}"/.config/dunst
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/dunst
cp ${SCRIPTDIR}/graphical/files/dunstrc /etc/skel/.config/dunst/dunstrc
cp ${SCRIPTDIR}/graphical/files/dunstrc "${USERHOME}"/.config/dunst/dunstrc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/dunst/dunstrc
cp ${SCRIPTDIR}/graphical/files/dunstrc "${ROOTHOME}"/.config/dunst/dunstrc

log_text Create skeleton for fontconfig
mkdir -p /etc/skel/.config/fontconfig "${ROOTHOME}"/.config/fontconfig "${USERHOME}"/.config/fontconfig
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/fontconfig
cp ${SCRIPTDIR}/graphical/files/fonts.conf /etc/skel/.config/fontconfig/fonts.conf
cp ${SCRIPTDIR}/graphical/files/fonts.conf "${USERHOME}"/.config/fontconfig/fonts.conf
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/fontconfig/fonts.conf
cp ${SCRIPTDIR}/graphical/files/fonts.conf "${ROOTHOME}"/.config/fontconfig/fonts.conf

log_text Create skeleton for gtkrc-2.0
cp ${SCRIPTDIR}/graphical/files/gtkrc-2.0 /etc/skel/.gtkrc-2.0
cp ${SCRIPTDIR}/graphical/files/gtkrc-2.0 "${USERHOME}"/.gtkrc-2.0
chown "${USERID}:${USERGRP}" "${USERHOME}"/.gtkrc-2.0
cp ${SCRIPTDIR}/graphical/files/gtkrc-2.0 "${ROOTHOME}"/.gtkrc-2.0

log_text Create skeleton for gtk-3.0
mkdir -p /etc/skel/.config/gtk-3.0 "${ROOTHOME}"/.config/gtk-3.0 "${USERHOME}"/.config/gtk-3.0
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/gtk-3.0
cp ${SCRIPTDIR}/graphical/files/gtk-3.0 /etc/skel/.config/gtk-3.0/settings.ini
cp ${SCRIPTDIR}/graphical/files/gtk-3.0 "${USERHOME}"/.config/gtk-3.0/settings.ini
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/gtk-3.0/settings.ini
cp ${SCRIPTDIR}/graphical/files/gtk-3.0 "${ROOTHOME}"/.config/gtk-3.0/settings.ini

log_text Create skeleton for gtk-4.0
mkdir -p /etc/skel/.config/gtk-4.0 "${ROOTHOME}"/.config/gtk-4.0 "${USERHOME}"/.config/gtk-4.0
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/gtk-4.0
cp ${SCRIPTDIR}/graphical/files/gtk-4.0 /etc/skel/.config/gtk-4.0/settings.ini
cp ${SCRIPTDIR}/graphical/files/gtk-4.0 "${USERHOME}"/.config/gtk-4.0/settings.ini
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/gtk-4.0/settings.ini
cp ${SCRIPTDIR}/graphical/files/gtk-4.0 "${ROOTHOME}"/.config/gtk-4.0/settings.ini

log_text Create skeleton for gammastep
mkdir -p /etc/skel/.config/gammastep/hooks "${ROOTHOME}"/.config/gammastep/hooks "${USERHOME}"/.config/gammastep/hooks
cp ${SCRIPTDIR}/graphical/files/darkmode.sh /etc/skel/.config/gammastep/hooks/darkmode
chmod a+x /etc/skel/.config/gammastep/hooks/darkmode
cp ${SCRIPTDIR}/graphical/files/darkmode.sh "${USERHOME}"/.config/gammastep/hooks/darkmode
chmod a+x "${USERHOME}"/.config/gammastep/hooks/darkmode
cp ${SCRIPTDIR}/graphical/files/darkmode.sh "${ROOTHOME}"/.config/gammastep/hooks/darkmode
chmod a+x "${ROOTHOME}"/.config/gammastep/hooks/darkmode
chown -R "${USERID}:${USERGRP}" "${USERHOME}/.config/gammastep"

log_text Create skeleton for wofi
mkdir -p /etc/skel/.config/wofi "${ROOTHOME}"/.config/wofi "${USERHOME}"/.config/wofi
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/wofi
cp ${SCRIPTDIR}/graphical/files/style.css /etc/skel/.config/wofi/style.css
cp ${SCRIPTDIR}/graphical/files/style.css "${USERHOME}"/.config/wofi/style.css
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/wofi/style.css
cp ${SCRIPTDIR}/graphical/files/style.css "${ROOTHOME}"/.config/wofi/style.css

log_text Create skeleton for xarchiverrc
mkdir -p /etc/skel/.config/xarchiver "${ROOTHOME}"/.config/xarchiver "${USERHOME}"/.config/xarchiver
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/xarchiver
cp ${SCRIPTDIR}/graphical/files/xarchiverrc /etc/skel/.config/xarchiver/xarchiverrc
cp ${SCRIPTDIR}/graphical/files/xarchiverrc "${USERHOME}"/.config/xarchiver/xarchiverrc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/xarchiver/xarchiverrc
cp ${SCRIPTDIR}/graphical/files/xarchiverrc "${ROOTHOME}"/.config/xarchiver/xarchiverrc

log_text Create skeleton for flameshot
mkdir -p /etc/skel/.config/flameshot "${ROOTHOME}"/.config/flameshot "${USERHOME}"/.config/flameshot
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/flameshot
cp ${SCRIPTDIR}/graphical/files/flameshot.ini /etc/skel/.config/flameshot/flameshot.ini
cp ${SCRIPTDIR}/graphical/files/flameshot.ini "${USERHOME}"/.config/flameshot/flameshot.ini
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/flameshot/flameshot.ini
cp ${SCRIPTDIR}/graphical/files/flameshot.ini "${ROOTHOME}"/.config/flameshot/flameshot.ini

log_text Create skeleton for Xdefaults
cp ${SCRIPTDIR}/graphical/files/Xdefaults /etc/skel/.Xdefaults
cp ${SCRIPTDIR}/graphical/files/Xdefaults "${USERHOME}"/.Xdefaults
chown "${USERID}:${USERGRP}" "${USERHOME}"/.Xdefaults
cp ${SCRIPTDIR}/graphical/files/Xdefaults "${ROOTHOME}"/.Xdefaults

log_text Create skeleton for xinitrc
cp ${SCRIPTDIR}/graphical/files/xinitrc /etc/skel/.xinitrc
chmod a+x /etc/skel/.xinitrc
cp ${SCRIPTDIR}/graphical/files/xinitrc "${USERHOME}"/.xinitrc
chown "${USERID}:${USERGRP}" "${USERHOME}"/.xinitrc
chmod a+x "${USERHOME}"/.xinitrc
cp ${SCRIPTDIR}/graphical/files/xinitrc "${ROOTHOME}"/.xinitrc
chmod a+x "${ROOTHOME}"/.xinitrc

log_text Create skeleton for Xmodmap
cp ${SCRIPTDIR}/graphical/files/Xmodmap /etc/skel/.Xmodmap
cp ${SCRIPTDIR}/graphical/files/Xmodmap "${USERHOME}"/.Xmodmap
chown "${USERID}:${USERGRP}" "${USERHOME}"/.Xmodmap
cp ${SCRIPTDIR}/graphical/files/Xmodmap "${ROOTHOME}"/.Xmodmap

log_text Create skeleton for Xresources
cp ${SCRIPTDIR}/graphical/files/Xresources /etc/skel/.Xresources
cp ${SCRIPTDIR}/graphical/files/Xresources "${USERHOME}"/.Xresources
chown "${USERID}:${USERGRP}" "${USERHOME}"/.Xresources
cp ${SCRIPTDIR}/graphical/files/Xresources "${ROOTHOME}"/.Xresources

log_text Create skeleton for kitty
mkdir -p /etc/skel/.config/kitty "${ROOTHOME}"/.config/kitty "${USERHOME}"/.config/kitty
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/kitty
cp ${SCRIPTDIR}/graphical/files/kitty.conf /etc/skel/.config/kitty/kitty.conf
cp ${SCRIPTDIR}/graphical/files/kitty.conf "${USERHOME}"/.config/kitty/kitty.conf
chown "${USERID}:${USERGRP}" "${USERHOME}"/.config/kitty/kitty.conf
cp ${SCRIPTDIR}/graphical/files/kitty.conf "${ROOTHOME}"/.config/kitty/kitty.conf
