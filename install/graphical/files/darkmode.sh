#!/usr/bin/env bash
case $1 in 
  period-changed)
  case $3 in
    daytime)
      notify-send "Gammastep" "Light mode enabled"
      sed -i 's/.*WebContentsForceDark.*//g' "$HOME"/.config/chromium-flags.conf
      exec gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    ;;
    night)
      notify-send "Gammastep" "Dark mode enabled"
      tee -a "$HOME"/.config/chromium-flags.conf <<EOF
--enable-features=WebContentsForceDark:inversion_method/hsl_based/image_behavior/none/text_lightness_threshold/150/background_lightness_threshold/205
EOF
      exec gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    ;;
  esac
  ;;
esac
