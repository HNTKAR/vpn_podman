#!/bin/bash

echoIB() {
    echo -e "\e[1;3;34m$1\e[0m\n"
}

trap 'exit' SIGTERM

ip link add dev wg0 type wireguard

echo Public key:
echoIB $(cat /key/PublicKey)
echo Preshared key:
echoIB $(cat /key/PresharedKey)

sleep inf &
wait $!

