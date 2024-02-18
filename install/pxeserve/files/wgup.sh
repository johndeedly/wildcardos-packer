#!/usr/bin/env bash

ip link add dev wg0 type wireguard
# router config
ip addr add 192.168.144.1/24 dev wg0
wg set wg0 listen-port 51820 private-key /root/.wg/root.key
# peer config
# wg set wg0 peer ##public_key## allowed-ips 192.168.144.2/32
# wg set wg0 peer ##public_key## allowed-ips 192.168.144.3/32
# ...
# on the clients route 0.0.0.0/0 and ::/0 through wireguard interface
# ...
wg
ufw status
ip link set wg0 up
