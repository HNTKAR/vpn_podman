FROM alpine

ENV VPN_NET="172.20.0.1/20"
ENV TZ='Asia/Tokyo'
ENV PORT="51820"

RUN apk update
RUN apk upgrade

RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime

RUN apk add tzdata wireguard-tools iptables

RUN mkdir -p /key /conf
RUN wg genkey | tee /key/private.key | wg pubkey > /key/public.key

COPY ["run.sh", "peer", "/usr/local/bin/"]
ENTRYPOINT ["/usr/local/bin/run.sh"]