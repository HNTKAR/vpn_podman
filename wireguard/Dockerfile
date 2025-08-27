FROM alpine

ENV VPN_NET="172.20.0.1/20"
ENV TZ='Asia/Tokyo'
ENV PORT="51820"
ENV POD_NAME="VPN"
ENV CONTAINER_NAME="vpn-wireguard"

RUN apk update
RUN apk upgrade

RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime

RUN apk add bash tzdata wireguard-tools iptables

COPY ["wireguard/run.sh", "wireguard/peer", "/usr/local/bin/"]
RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/run.sh"]
