#!/usr/bin/env bash

log_text Ensure default preference directories exists
mkdir -p /etc/firefox \
    /usr/lib/firefox/defaults/pref \
    /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/defaults/pref

# https[://]support[.]mozilla[.]org/en-US/kb/customizing-firefox-using-autoconfig
log_text "Configure firefox - create autoconfig"
cp ${SCRIPTDIR}/graphical/files/autoconfig.js /usr/lib/firefox/defaults/pref/
cp ${SCRIPTDIR}/graphical/files/autoconfig.js /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/defaults/pref/

# https[://]github[.]com/arkenfox/user.js/blob/master/user.js
log_text "Configure firefox - create configuration file"
cp ${SCRIPTDIR}/graphical/files/firefox.cfg /etc/firefox/
cp ${SCRIPTDIR}/graphical/files/firefox.cfg /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/

log_text Ensure distribution directory exists
mkdir -p /usr/lib/firefox/distribution \
    /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies

log_text "Configure firefox - create policies file"
cp ${SCRIPTDIR}/graphical/files/policies.json /usr/lib/firefox/distribution/
cp ${SCRIPTDIR}/graphical/files/policies.json /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies/
