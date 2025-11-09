FROM alpine

ENV TZ='Asia/Tokyo'
ENV VPN_NET="172.20.0.1/20"
ENV PORT="51820"

RUN apk update
RUN apk upgrade

RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime

RUN apk add tzdata wireguard-tools iptables

RUN mkdir -p /usr
COPY ["wireguard/run.sh", "wireguard/peer", "/usr/local/bin/"]
RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/run.sh"]
