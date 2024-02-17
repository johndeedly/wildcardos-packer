#!/usr/bin/env bash

WALLPAPER=$( find /usr/share/backgrounds -type f \( -name '*.gif' -o -name '*.png' -o -name '*.jpg' \) | shuf -n 1 )
URLPARSE=$( python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${WALLPAPER}" )
if [[ "${XDG_CURRENT_DESKTOP}" =~ [Gg]nome ]]; then
  gsettings set org.gnome.desktop.background picture-uri "file://${URLPARSE}"
fi
if [[ "${XDG_CURRENT_DESKTOP}" =~ [Mm]ate ]]; then
  gsettings set org.mate.desktop.background picture-uri "file://${URLPARSE}"
fi
if [[ "${XDG_CURRENT_DESKTOP}" =~ [Cc]innamon ]]; then
  gsettings set org.cinnamon.desktop.background picture-uri "file://${URLPARSE}"
fi
