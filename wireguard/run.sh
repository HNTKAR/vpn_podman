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
ip link set down dev wg0
ip link set up dev wg0

iptables -t nat -A POSTROUTING -o $NIC_NAME -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT

sleep infinity &
wait $!
