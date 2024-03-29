FROM alpine

ENV VPN_CIDR="10.0.0.1/24"
ENV TZ='Asia/Tokyo'
ENV PORT="51820"
ENV LOG_LEVEL=verbose

COPY ["run.sh", "peer", "/usr/local/bin/"]

RUN apk add --no-cache wireguard-tools iptables

RUN mkdir /key && \
    wg genkey | tee /key/PrivateKey | wg pubkey > /key/PublicKey && \
    wg genpsk > /key/PresharedKey

RUN chmod -R 777 "/usr/local/bin/" &&\
    chmod -R 077 "/key/"

ENTRYPOINT ["/usr/local/bin/run.sh"]