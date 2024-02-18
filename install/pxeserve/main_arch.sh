#!/usr/bin/env bash

log_text "Install packages needed for pxe boot"
pacman_whenneeded syslinux darkhttpd nfs-utils nbd samba dnsmasq

log_text "Configure network"
DHCP_ADDITIONAL_SETUP=(
  "dhcp-option=option:dns-server,192.168.123.128\n"
  "dhcp-option=option6:dns-server,[2001:db8:7b:1::]\n"
  "dhcp-option=option:ntp-server,192.168.123.128\n"
  "dhcp-option=option6:ntp-server,[2001:db8:7b:1::]\n"
  "\n"
  "# Override the default route supplied by dnsmasq, which assumes the"
)

PXESETUP=(
  "dhcp-match=set:efi-x86_64,option:client-arch,7\n"
  "dhcp-match=set:efi-x86_64,option:client-arch,9\n"
  "dhcp-match=set:efi-x86,option:client-arch,6\n"
  "dhcp-match=set:bios,option:client-arch,0\n"

  "dhcp-boot=tag:efi-x86_64,efi64\/syslinux.efi\n"
  "dhcp-boot=tag:efi-x86,efi32\/syslinux.efi\n"
  "dhcp-boot=tag:bios,bios\/lpxelinux.0"
)

DHCP_209_SETUP=(
  "dhcp-option-force=tag:efi-x86_64,209,pxelinux.cfg\/default\n"
  "dhcp-option-force=tag:efi-x86,209,pxelinux.cfg\/default\n"
  "dhcp-option-force=tag:bios,209,pxelinux.cfg\/default"
)

DHCP_210_SETUP=(
  "dhcp-option-force=tag:efi-x86_64,210,efi64\/\n"
  "dhcp-option-force=tag:efi-x86,210,efi32\/\n"
  "dhcp-option-force=tag:bios,210,bios\/"
)

cp ${SCRIPTDIR}/pxeserve/files/10-all.link /etc/systemd/network/
cp ${SCRIPTDIR}/pxeserve/files/20-extern.network /etc/systemd/network/
cp ${SCRIPTDIR}/pxeserve/files/20-intern.network /etc/systemd/network/
rm /etc/systemd/network/20-wired.network

log_text Disable dns
sed -i '0,/^#\?port.*/s//port=0/' /etc/dnsmasq.conf
tee /etc/default/dnsmasq <<EOF
DNSMASQ_OPTS="-p0"
EOF

sed -i '0,/^#\?domain-needed.*/s//domain-needed/' /etc/dnsmasq.conf
sed -i '0,/^#\?bogus-priv.*/s//bogus-priv/' /etc/dnsmasq.conf
sed -i '0,/^#\?local=.*/s//local=\/locally\//' /etc/dnsmasq.conf
sed -i '0,/^#\?domain=.*/s//domain=locally/' /etc/dnsmasq.conf
sed -i '0,/^#\?dhcp-range=.*/s//dhcp-range=192.168.123.1,192.168.123.127,255.255.255.0,12h/' /etc/dnsmasq.conf
sed -i '0,/^#\?dhcp-range=.*::.*/s//dhcp-range=2001:db8:7b::1,2001:db8:7b::ffff,64,12h/' /etc/dnsmasq.conf
sed -i '0,/^# Override the default route.*/s//'"${DHCP_ADDITIONAL_SETUP[*]}"'/' /etc/dnsmasq.conf
sed -i '0,/^#\?enable-ra.*/s//enable-ra/' /etc/dnsmasq.conf
sed -i '0,/^#\?enable-tftp.*/s//enable-tftp/' /etc/dnsmasq.conf
sed -i '0,/^#\?tftp-root=.*/s//tftp-root=\/srv\/tftp/' /etc/dnsmasq.conf
sed -i '0,/^#\?log-dhcp.*/s//log-dhcp/' /etc/dnsmasq.conf
sed -i '0,/^#\?log-queries.*/s//log-queries/' /etc/dnsmasq.conf
sed -i '0,/^#\?dhcp-boot=.*/s//'"${PXESETUP[*]}"'/' /etc/dnsmasq.conf
sed -i '0,/^#\?dhcp-option-force=209.*/s//'"${DHCP_209_SETUP[*]}"'/' /etc/dnsmasq.conf
sed -i '0,/^#\?dhcp-option-force=210.*/s//'"${DHCP_210_SETUP[*]}"'/' /etc/dnsmasq.conf

log_text "Configure wireguard server on port 51820"
cp ${SCRIPTDIR}/pxeserve/files/wg.conf /etc/sysctl.d/
cp /etc/ufw/before.rules /etc/ufw/before.rules.bak
cat /etc/ufw/before.rules.bak ${SCRIPTDIR}/pxeserve/files/before.rules.append > /etc/ufw/before.rules
cp /etc/ufw/before6.rules /etc/ufw/before6.rules.bak
cat /etc/ufw/before6.rules.bak ${SCRIPTDIR}/pxeserve/files/before6.rules.append > /etc/ufw/before6.rules
cp ${SCRIPTDIR}/pxeserve/files/wgup.sh /usr/local/bin/wgup.sh
chmod +x /usr/local/bin/wgup.sh
cp ${SCRIPTDIR}/pxeserve/files/wgdown.sh /usr/local/bin/wgdown.sh
chmod +x /usr/local/bin/wgdown.sh
cp ${SCRIPTDIR}/pxeserve/files/wireguard.service /etc/systemd/system/

log_text "Configure tftp"
mkdir -p /srv/tftp/{bios,efi32,efi64}/pxelinux.cfg
cp -ar /usr/lib/syslinux/bios /srv/tftp/
cp -ar /usr/lib/syslinux/efi32 /srv/tftp/
cp -ar /usr/lib/syslinux/efi64 /srv/tftp/
cp ${SCRIPTDIR}/pxeserve/files/pxelinux.default /srv/tftp/bios/pxelinux.cfg/default
cp ${SCRIPTDIR}/pxeserve/files/pxelinux.default /srv/tftp/efi32/pxelinux.cfg/default
cp ${SCRIPTDIR}/pxeserve/files/pxelinux.default /srv/tftp/efi64/pxelinux.cfg/default
mkdir -p /srv/tftp/{,bios,efi32,efi64}/arch/x86_64

log_text "Configure http"
mkdir -p /srv/http/arch/x86_64
cp ${SCRIPTDIR}/pxeserve/files/darkhttpd.service /etc/systemd/system/

log_text "Configure nfs"
mkdir -p /srv/nfs/arch/x86_64
sed -i '0,/^\[mountd\].*/s//[mountd]\nport=20048/' /etc/nfs.conf
cp ${SCRIPTDIR}/pxeserve/files/exports /etc/exports

log_text "Configure nbd"
mkdir -p /srv/nbd/arch/x86_64
cp ${SCRIPTDIR}/pxeserve/files/nbd.config /etc/nbd-server/config
cp ${SCRIPTDIR}/pxeserve/files/nbd.allow /etc/nbd-server/allow

log_text "Configure cifs"
mkdir -p /srv/cifs/arch/x86_64
cp ${SCRIPTDIR}/pxeserve/files/smb.conf /etc/samba/smb.conf

log_text "Change default access rights"
chown -R root:root /srv/tftp /srv/http /srv/nfs /srv/nbd /srv/cifs
find /srv/tftp /srv/http /srv/nfs /srv/nbd /srv/cifs -type d -exec chmod 755 {} \;
find /srv/tftp /srv/http /srv/nfs /srv/nbd /srv/cifs -type f -exec chmod 644 {} \;

log_text "Enable all configured services"
systemctl enable dnsmasq nfs-server nbd smb wireguard darkhttpd

log_text "Allow pxe protocols"
ufw disable

log_text "[-] Remove existing ssh rule"
ufw delete limit ssh

log_text "[-] eth1 - intern"
ufw allow in on eth1 to any port bootps comment 'bootps on intern'
ufw allow in on eth1 to any port ssh comment 'ssh on intern'
ufw allow in on eth1 to any port 53 comment 'dns on intern'
ufw allow in on eth1 to any port tftp comment 'tftp on intern'
ufw allow in on eth1 to any port 80 comment 'http on intern'
ufw allow in on eth1 to any port ntp comment 'ntp on intern'
ufw allow in on eth1 to any port 111 comment 'nfs on intern'
ufw allow in on eth1 to any port 2049 comment 'nfs on intern'
ufw allow in on eth1 to any port 20048 comment 'nfs on intern'
ufw allow in on eth1 to any port nbd comment 'nbd on intern'
ufw allow in on eth1 to any port 445 comment 'cifs on intern'
ufw allow in on eth1 to any port 139 comment 'cifs on intern'
ufw allow in on eth1 to any port 8443 comment 'step-ca on intern'
ufw allow in on eth1 to any port 51820 comment 'wireguard on intern'
ufw route allow in on eth1 out on wg0 comment 'allow forward from intern to wireguard'
ufw route allow in on eth1 out on eth1 comment 'allow local intern forwarding'

log_text "[-] wg0 - wireguard"
ufw route allow in on wg0 out on eth1 comment 'allow forward from wireguard to intern'
ufw route allow in on wg0 out on wg0 comment 'allow local wireguard forwarding'

log_text "[-] lo - loopback"
ufw allow in on lo comment 'allow loopback in'
ufw route allow in on lo out on lo comment 'allow loopback forward'

ufw enable
