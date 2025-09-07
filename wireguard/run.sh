#!/bin/bash

container_exit() {
    echo "Stopping WireGuard container..."
    iptables -t nat -D POSTROUTING -o $NIC_NAME -j MASQUERADE
    iptables -D FORWARD -i wg0 -j ACCEPT
    ip link del dev wg0
    exit 0
}

trap "container_exit" SIGTERM
mkdir -p /usr/V/$CONTAINER_NAME/{key,conf,logs}
chown $(id -u):$(id -u) -R /usr/V/$CONTAINER_NAME
chmod 700 /usr/V/$CONTAINER_NAME

NIC_NAME=$(ip addr|grep BROADCAST|cut -d ":" -f 2|sed s/\ //g|sed s/\@.*//g|head -n 1)
ip link add dev wg0 type wireguard
ip address add dev wg0 $VPN_NET

if [ ! -f /usr/V/$CONTAINER_NAME/conf/wg0.conf ]; then
    wg genkey | tee /usr/V/$CONTAINER_NAME/key/private.key | wg pubkey > /usr/V/$CONTAINER_NAME/key/public.key
    wg set wg0 listen-port $PORT private-key /usr/V/$CONTAINER_NAME/key/private.key
    wg showconf wg0 > /usr/V/$CONTAINER_NAME/conf/wg0.conf
else
    wg syncconf wg0 /usr/V/$CONTAINER_NAME/conf/wg0.conf
fi

ip link set down dev wg0
ip link set up dev wg0

echo "WireGuard interface wg0 created with IP $VPN_NET"
echo "Listening on port $PORT"
echo "wireguard public key: $(cat /usr/V/$CONTAINER_NAME/key/public.key)"

iptables -t nat -A POSTROUTING -o $NIC_NAME -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT

sleep infinity &
wait $!
container_exit
