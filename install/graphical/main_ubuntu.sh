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
    # x11
    xorg
    xinit
    xautolock
    suckless-tools
    xclip
    xsel
    brightnessctl
    gammastep
    arandr
    dunst
    libnotify-bin
    xarchiver
    flameshot
    libinput-bin
    libinput-tools
    xserver-xorg-input-libinput
    kitty
    wofi
    dex
    xrdp
    ibus
    ibus-typing-booster
    # wallpapers fonts and icons
    elementary-icon-theme
    fonts-dejavu
    # complementary programs
    # firefox and chromium are flatpaks now
    libreoffice
    libreoffice-l10n-de
    krita
    evolution
    seahorse
    freerdp2-x11
    notepadqq
    gitg
    keepassxc
    pdf-presenter-console
    texlive
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    wine
    winetricks
    mpv
    gpicview
    qalculate-gtk
    # easy package management
    gnome-software
    gnome-software-plugin-flatpak
    flatpak
)

log_text "Install and configure base packages needed for graphical environments"
pacman_whenneeded ${PACKAGE_LIST[@]}

log_text "Disable and mask light display manager, thanks ubuntu"
systemctl disable lightdm
rm /etc/systemd/system/display-manager.service || true

log_text "Reenable ly display manager, thanks ubuntu"
systemctl enable ly
ln -s /usr/lib/systemd/system/ly.service /etc/systemd/system/display-manager.service || true

log_text "Add flathub repo to system when not present"
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

log_text "Install firefox flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub org.mozilla.firefox

log_text "Install chromium flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub org.chromium.Chromium

log_text "Install zettlr flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub com.zettlr.Zettlr

log_text "Install obsidian flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub md.obsidian.Obsidian

log_text "Install drawio flatpak"
flatpak install --system --assumeyes --noninteractive --or-update flathub com.jgraph.drawio.desktop

log_text "Download elementary os wallpapers"
git clone --depth 1 https://github.com/elementary/wallpapers.git /var/tmp/elementary
mkdir -p /usr/share/backgrounds
cp /var/tmp/elementary/backgrounds/* /usr/share/backgrounds/
ln -s 'Photo of Valley.jpg' /usr/share/backgrounds/elementaryos-default
rm -rf /var/tmp/elementary
