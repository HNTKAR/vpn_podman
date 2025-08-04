#!/bin/bash

container_exit() {
    echo "Stopping WireGuard container..."
    iptables -t nat -D POSTROUTING -o $NIC_NAME -j MASQUERADE
    iptables -D FORWARD -i wg0 -j ACCEPT
    ip link del dev wg0
    exit 0
}

trap "container_exit" SIGTERM

NIC_NAME=$(ip addr|grep BROADCAST|cut -d ":" -f 2|sed s/\ //g)
ip link add dev wg0 type wireguard
ip address add dev wg0 $VPN_NET
wg set wg0 listen-port $PORT private-key /key/private.key 
ip link set down dev wg0
ip link set up dev wg0

echo "WireGuard interface wg0 created with IP $VPN_NET"
echo "Listening on port $PORT"
echo "wireguard private key is $(cat /key/private.key)"

iptables -t nat -A POSTROUTING -o $NIC_NAME -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT

sleep infinity &
wait $!
