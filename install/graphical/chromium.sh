#!/usr/bin/env bash

log_text Ensures managed policies dir exists
mkdir -p /etc/chromium/policies/managed \
    /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed

log_text "Copy json configuration policies (1)"
cp ${SCRIPTDIR}/graphical/files/adblock.json /etc/chromium/policies/managed/
cp ${SCRIPTDIR}/graphical/files/default-settings.json /etc/chromium/policies/managed/
cp ${SCRIPTDIR}/graphical/files/extensions-default.json /etc/chromium/policies/managed/
cp ${SCRIPTDIR}/graphical/files/telemetry-off.json /etc/chromium/policies/managed/
cp ${SCRIPTDIR}/graphical/files/duckduckgo.json /etc/chromium/policies/managed/
cp ${SCRIPTDIR}/graphical/files/restore-session.json /etc/chromium/policies/managed/

log_text "Copy json configuration policies (2)"
cp ${SCRIPTDIR}/graphical/files/adblock.json /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed/
cp ${SCRIPTDIR}/graphical/files/default-settings.json /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed/
cp ${SCRIPTDIR}/graphical/files/extensions-default.json /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed/
cp ${SCRIPTDIR}/graphical/files/telemetry-off.json /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed/
cp ${SCRIPTDIR}/graphical/files/duckduckgo.json /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed/
cp ${SCRIPTDIR}/graphical/files/restore-session.json /var/lib/flatpak/extension/org.chromium.Chromium.Policy.system-policies/x86_64/1/policies/managed/
