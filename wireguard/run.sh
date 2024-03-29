#!/bin/bash

echoIB() {
    echo -e "\e[1;3;34m$1\e[0m\n"
}

trap 'exit' SIGTERM

ip link add dev wg0 type wireguard 
iptables -t nat -A POSTROUTING -o eth0 -s $VPN_CIDR -j MASQUERADE

echo Public key:
echoIB $(cat /key/PublicKey)
echo Preshared key:
echoIB $(cat /key/PresharedKey)

sleep inf &
wait $!
