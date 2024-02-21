#!/usr/bin/env bash

log_text "Configure touchpad"
mkdir -p /etc/X11/xorg.conf.d
cp ${SCRIPTDIR}/graphical/files/30-touchpad.conf /etc/X11/xorg.conf.d/

log_text "Set keyboard regionals for X11"
cp ${SCRIPTDIR}/graphical/files/00-keyboard.conf /etc/X11/xorg.conf.d/

if [ -n $INSTALLED_HARDWARE_VIRTUAL_MACHINE ]; then
    log_text "Enable software cursor in virtual environments"
    cp ${SCRIPTDIR}/graphical/files/05-swcursor.conf /etc/X11/xorg.conf.d/
fi

log_text "Copy slock_run"
cp ${SCRIPTDIR}/graphical/files/slock_run /usr/local/bin/
chmod a+x /usr/local/bin/slock_run

log_text "Global xterm fallback to kitty terminal"
ln -s /usr/bin/kitty /usr/local/bin/xterm

log_text "Copy 32-bit link to wine"
tee /usr/local/bin/wine32 <<EOF >/dev/null
#!/usr/bin/env bash
WINEPREFIX="\$HOME/.local/wine32" WINEARCH=win32 wine \$@
EOF
chmod a+x /usr/local/bin/wine32

log_text "Wine first time startup for $USERID"
su -s /bin/bash -l $USERID <<EOS
wine wineboot -u || true
wine32 wineboot -u || true
EOS

log_text "Set xdg-mime defaults"
su -s /bin/bash -l $USERID <<EOS
# libreoffice
[ -f /usr/share/applications/libreoffice-math.desktop ] && \
    xdg-mime default libreoffice-math.desktop `grep 'MimeType=' /usr/share/applications/libreoffice-math.desktop | sed -e 's/.*=//' -e 's/;/ /g'`
[ -f /usr/share/applications/libreoffice-draw.desktop ] && \
    xdg-mime default libreoffice-draw.desktop `grep 'MimeType=' /usr/share/applications/libreoffice-draw.desktop | sed -e 's/.*=//' -e 's/;/ /g'`
[ -f /usr/share/applications/libreoffice-calc.desktop ] && \
    xdg-mime default libreoffice-calc.desktop `grep 'MimeType=' /usr/share/applications/libreoffice-calc.desktop | sed -e 's/.*=//' -e 's/;/ /g'`
[ -f /usr/share/applications/libreoffice-writer.desktop ] && \
    xdg-mime default libreoffice-writer.desktop `grep 'MimeType=' /usr/share/applications/libreoffice-writer.desktop | sed -e 's/.*=//' -e 's/;/ /g'`
[ -f /usr/share/applications/libreoffice-impress.desktop ] && \
    xdg-mime default libreoffice-impress.desktop `grep 'MimeType=' /usr/share/applications/libreoffice-impress.desktop | sed -e 's/.*=//' -e 's/;/ /g'`

# browser (libreoffice first, then firefox)
[ -f /var/lib/flatpak/exports/share/applications/org.mozilla.firefox.desktop ] && \
    xdg-mime default org.mozilla.firefox.desktop `grep 'MimeType=' /var/lib/flatpak/exports/share/applications/org.mozilla.firefox.desktop | sed -e 's/.*=//' -e 's/;/ /g'`

# email program
[ -f /usr/share/applications/org.gnome.Evolution.desktop ] && \
    xdg-mime default org.gnome.Evolution.desktop `grep 'MimeType=' /usr/share/applications/org.gnome.Evolution.desktop | sed -e 's/.*=//' -e 's/;/ /g'`

# archive program
[ -f /usr/share/applications/xarchiver.desktop ] && \
    xdg-mime default xarchiver.desktop `grep 'MimeType=' /usr/share/applications/xarchiver.desktop | sed -e 's/.*=//' -e 's/;/ /g'`

# video playback program
[ -f /usr/share/applications/mpv.desktop ] && \
    xdg-mime default mpv.desktop `grep 'MimeType=' /usr/share/applications/mpv.desktop | sed -e 's/.*=//' -e 's/;/ /g'`

# notepad program
[ -f /usr/share/applications/notepadqq.desktop ] && \
    xdg-mime default notepadqq.desktop `grep 'MimeType=' /usr/share/applications/notepadqq.desktop | sed -e 's/.*=//' -e 's/;/ /g'`

# image previewer (firefox first, then gpicview)
[ -f /usr/share/applications/gpicview.desktop ] && \
    xdg-mime default gpicview.desktop `grep 'MimeType=' /usr/share/applications/gpicview.desktop | sed -e 's/.*=//' -e 's/;/ /g'`
EOS

log_text "Set xdg-settings defaults"
su -s /bin/bash -l $USERID <<EOS
xdg-settings set default-web-browser org.mozilla.firefox.desktop || log_error "Could not set default browser"
xdg-settings set default-url-scheme-handler mailto org.gnome.Evolution.desktop || log_error "Could not set default email program"
EOS

log_text "Enable xrdp service"
systemctl enable xrdp xrdp-sesman

log_text "Open firewall for xrdp"
ufw disable
ufw limit 3389/tcp comment 'allow limited xrdp access'
ufw enable

log_text "Enable xinitrc when a rdp session starts"
sed -i 's/^# exec xterm/exec \/bin\/bash --login -i ~\/.xinitrc/' /etc/xrdp/startwm.sh
