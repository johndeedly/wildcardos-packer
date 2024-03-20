#!/usr/bin/env bash

if [[ ${TAGS[@]} =~ "archlinux" ]]; then
    source "${SCRIPTDIR}/cinnamon/main_arch.sh"
fi

if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    source "${SCRIPTDIR}/cinnamon/main_ubuntu.sh"
fi

log_text "Configure cinnamon to be the default window manager"
sed -i 's/XDG_CURRENT_DESKTOP=.*/XDG_CURRENT_DESKTOP="cinnamon"/' /etc/skel/.xinitrc
tee -a /etc/skel/.xinitrc <<EOF

exec cinnamon-session --session cinnamon
EOF
cp /etc/skel/.xinitrc "${USERHOME}"/.xinitrc
cp /etc/skel/.xinitrc "${ROOTHOME}"/.xinitrc

log_text "Configure additional application defaults and settings"
systemctl enable NetworkManager.service
su - "${USERID}" <<EOS
XDG_CONFIG_HOME="${USERHOME}"/.config dconf dump /org/cinnamon/ > "${USERHOME}"/dconf-dump.ini
tee -a "${USERHOME}"/dconf-dump.ini <<EOX

[/]
favorite-apps=['org.mozilla.firefox.desktop:flatpak', 'org.chromium.Chromium.desktop:flatpak', 'kitty.desktop', 'cinnamon-settings.desktop', 'nemo.desktop']

[desktop/background]
picture-uri='file:///usr/share/backgrounds/elementaryos-default'
picture-options='zoom'
primary-color='000000'
secondary-color='000000'
draw-background=true

[desktop/interface]
icon-theme='elementary'

[desktop/applications/calculator]
exec='qalculate-gtk'

[desktop/applications/terminal]
exec='kitty'
exec-arg='--'

[desktop/keybindings]
custom-list=['__dummy__', 'custom0', 'custom1', 'custom2', 'custom3', 'custom4']
looking-glass-keybinding=@as []
pointer-next-monitor=@as []
pointer-previous-monitor=@as []
show-desklets=@as []

[desktop/keybindings/custom-keybindings/custom0]
binding=['<Shift><Alt>Return']
command='wofi --fork --normal-window --insensitive --allow-images --allow-markup --show drun'
name='wofi'

[desktop/keybindings/custom-keybindings/custom1]
binding=['<Alt>p', 'XF86Display']
command='arandr'
name='arandr'

[desktop/keybindings/custom-keybindings/custom2]
binding=['<Shift><Alt>e']
command='kitty /usr/bin/lf'
name='lf'

[desktop/keybindings/custom-keybindings/custom3]
binding=['<Shift><Alt>w']
command='flatpak run org.chromium.Chromium'
name='chromium'

[desktop/keybindings/custom-keybindings/custom4]
binding=['<Control><Shift>e']
command='ibus emoji'
name='emoji picker'

[desktop/keybindings/media-keys]
calculator=['<Alt>period']
email=@as []
home=['<Alt>e']
screensaver=['<Alt>l', 'XF86ScreenSaver']
search=@as []
terminal=['<Alt>Return']
www=['<Alt>w']

[desktop/keybindings/wm]
activate-window-menu=@as []
begin-move=@as []
begin-resize=@as []
close=['<Alt>q']
move-to-monitor-down=['<Ctrl><Shift><Alt>Down']
move-to-monitor-left=['<Ctrl><Shift><Alt>Left']
move-to-monitor-right=['<Ctrl><Shift><Alt>Right']
move-to-monitor-up=['<Ctrl><Shift><Alt>Up']
move-to-workspace-1=['<Shift><Alt>1']
move-to-workspace-2=['<Shift><Alt>2']
move-to-workspace-3=['<Shift><Alt>3']
move-to-workspace-4=['<Shift><Alt>4']
move-to-workspace-5=['<Shift><Alt>5']
move-to-workspace-6=['<Shift><Alt>6']
move-to-workspace-7=['<Shift><Alt>7']
move-to-workspace-8=['<Shift><Alt>8']
move-to-workspace-9=['<Shift><Alt>9']
move-to-workspace-10=@as []
move-to-workspace-11=@as []
move-to-workspace-12=@as []
move-to-workspace-down=['<Shift><Alt>Down']
move-to-workspace-left=['<Shift><Alt>Left']
move-to-workspace-right=['<Shift><Alt>Right']
move-to-workspace-up=['<Shift><Alt>Up']
panel-run-dialog=@as []
push-tile-down=['<Ctrl><Alt>Down']
push-tile-left=['<Ctrl><Alt>Left']
push-tile-right=['<Ctrl><Alt>Right']
push-tile-up=['<Ctrl><Alt>Up']
show-desktop=@as []
switch-group=@as []
switch-group-backward=@as []
switch-monitor=@as []
switch-panels=@as []
switch-panels-backward=@as []
switch-to-workspace-1=['<Alt>1']
switch-to-workspace-2=['<Alt>2']
switch-to-workspace-3=['<Alt>3']
switch-to-workspace-4=['<Alt>4']
switch-to-workspace-5=['<Alt>5']
switch-to-workspace-6=['<Alt>6']
switch-to-workspace-7=['<Alt>7']
switch-to-workspace-8=['<Alt>8']
switch-to-workspace-9=['<Alt>9']
switch-to-workspace-10=@as []
switch-to-workspace-11=@as []
switch-to-workspace-12=@as []
switch-to-workspace-down=['<Alt>Down']
switch-to-workspace-left=['<Alt>Left']
switch-to-workspace-right=['<Alt>Right']
switch-to-workspace-up=['<Alt>Up']
switch-windows=['<Alt>Tab']
switch-windows-backward=['<Shift><Alt>Tab']
toggle-maximized=['<Alt>f']
unmaximize=@as []

[settings-daemon/plugins/power]
button-power='shutdown'
EOX
dbus-run-session -- bash -c 'XDG_CONFIG_HOME="${USERHOME}"/.config dconf load /org/cinnamon/ < "${USERHOME}"/dconf-dump.ini'
/usr/bin/rm "${USERHOME}"/dconf-dump.ini

[ -f /usr/share/applications/nemo.desktop ] && \
  xdg-mime default nemo.desktop `grep 'MimeType=' /usr/share/applications/nemo.desktop | sed -e 's/.*=//' -e 's/;/ /g'`
EOS

log_text "Create skeleton for autostart desktop files"
cp ${SCRIPTDIR}/cinnamon/files/flameshot.desktop /etc/xdg/autostart/flameshot.desktop
chmod a+x /etc/xdg/autostart/flameshot.desktop
cp ${SCRIPTDIR}/cinnamon/files/gammastep.desktop /etc/xdg/autostart/gammastep.desktop
chmod a+x /etc/xdg/autostart/gammastep.desktop

log_text "Enable wallpaper switcher"
cp ${SCRIPTDIR}/cinnamon/files/wallpaper.timer /etc/systemd/user/wallpaper.timer
cp ${SCRIPTDIR}/cinnamon/files/wallpaper.service /etc/systemd/user/wallpaper.service
cp ${SCRIPTDIR}/cinnamon/files/wallpaper.sh /usr/local/bin/wallpaper.sh
chmod a+x /usr/local/bin/wallpaper.sh
systemctl --global enable wallpaper.timer

# create skeleton for desktop configuration files
arrVar=( "calendar" "grouped-window-list" "menu" "network" "notifications" "sound" )
for item in "${arrVar[@]}"; do
  mkdir -p "/etc/skel/.config/cinnamon/spices/${item}@cinnamon.org"
  cp "${SCRIPTDIR}/cinnamon/files/${item}@cinnamon.org/"*.json "/etc/skel/.config/cinnamon/spices/${item}@cinnamon.org/"
  mkdir -p "${USERHOME}/.config/cinnamon/spices/${item}@cinnamon.org"
  cp "${SCRIPTDIR}/cinnamon/files/${item}@cinnamon.org/"*.json "${USERHOME}/.config/cinnamon/spices/${item}@cinnamon.org/"
  mkdir -p "${ROOTHOME}/.config/cinnamon/spices/${item}@cinnamon.org"
  cp "${SCRIPTDIR}/cinnamon/files/${item}@cinnamon.org/"*.json "${ROOTHOME}/.config/cinnamon/spices/${item}@cinnamon.org/"
done
chown -R "${USERID}:${USERGRP}" "${USERHOME}/.config/cinnamon"
unset item
unset arrVar

log_text "Configure ly to have username and cinnamon prefilled on first boot"
tee /etc/ly/save <<EOF
${USERID}
3
EOF
