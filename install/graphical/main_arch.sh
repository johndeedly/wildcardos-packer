#!/usr/bin/env bash

log_text "List of basic packages to create a system with graphical support"
PACKAGE_LIST=(
    # video and sound wiring
    pipewire
    pipewire-pulse
    pipewire-jack
    pipewire-alsa
    wireplumber
    pamixer
    pavucontrol
    playerctl
    alsa-utils
    qpwgraph
    rtkit
    realtime-privileges
    # x11
    xorg-server
    xorg-xinit
    xorg-xrandr
    xautolock
    slock
    xclip
    xsel
    brightnessctl
    gammastep
    arandr
    dunst
    libnotify
    xarchiver
    flameshot
    libinput
    xf86-input-libinput
    xorg-xinput
    kitty
    wofi
    dex
    xrdp
    ibus
    ibus-typing-booster
    # wallpapers fonts and icons
    archlinux-wallpaper
    elementary-wallpapers
    elementary-icon-theme
    ttf-dejavu
    ttf-dejavu-nerd
    ttf-liberation
    ttf-font-awesome
    ttf-hanazono
    ttf-hannom
    ttf-baekmuk
    noto-fonts-emoji
    ttf-ms-fonts
    # complementary programs
    # firefox and chromium are flatpaks now
    cups
    ipp-usb
    libreoffice-fresh
    libreoffice-fresh-de
    krita
    evolution
    seahorse
    freerdp
    notepadqq
    gitg
    keepassxc
    pdfpc
    zettlr
    obsidian
    texlive-bin
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    wine
    winetricks
    mpv
    gpicview
    qalculate-gtk
    drawio-desktop
    code
    # easy package management
    pamac-flatpak
    flatpak
)

log_text "Install and configure base packages needed for graphical environments"
pacman_whenneeded ${PACKAGE_LIST[@]}

log_text "Enable cups printer service"
systemctl enable cups

# https://bbs.archlinux.org/viewtopic.php?id=289146
log_text "Add user to realtime group"
usermod -aG realtime $USERID

log_text "Add flathub repo to system when not present"
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

log_text "Install firefox flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub org.mozilla.firefox

log_text "Install chromium flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub org.chromium.Chromium

log_text "Install code-oss extensions for user"
su -s /bin/bash -l $USERID <<EOS
# csharp
code --install-extension muhammad-sammy.csharp --force
# xml
code --install-extension dotjoshjohnson.xml --force
# better comments
code --install-extension aaron-bond.better-comments --force
# git graph
code --install-extension mhutchie.git-graph --force
# git blame
code --install-extension waderyan.gitblame --force
# yara
code --install-extension infosec-intern.yara --force
# hex editor
code --install-extension ms-vscode.hexeditor --force
# german language pack
code --install-extension ms-ceintl.vscode-language-pack-de --force
# color code highlighter
code --install-extension naumovs.color-highlight --force
# reset application defaults
#   Code claims to be a file manager 😓 -> inode/directory removed from list
[ -f /usr/share/applications/code-oss.desktop ] && \
  xdg-mime default code-oss.desktop `grep 'MimeType=' /usr/share/applications/code-oss.desktop | sed -e 's/.*=//' -e 's/;/ /g' -e 's/inode\/directory//g'`
xdg-mime default code-oss.desktop 'text/plain' 'text/html' 'text/x-shellscript' 'application/json' 'text/xml' 'text/x-php' 'text/x-c' 'text/x-c++'
EOS
