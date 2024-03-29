FROM alpine

ARG CONFIG_FILE="sample.conf"
ARG IP="172.16.0.1/24"
ENV VPN_CIDR=${IP}
ENV TZ='Asia/Tokyo'
ENV PORT="51820"

COPY ["peer"  ,"/usr/local/bin/"]
COPY ["run.sh" ,"/usr/local/bin/"]

RUN apk add --no-cache wireguard-tools

RUN mkdir /key && \
    wg genkey | tee /key/PrivateKey | wg pubkey > /key/PublicKey && \
    wg genpsk > /key/PresharedKey

RUN chmod -R 777 "/usr/local/bin/"
RUN ls -la /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/run.sh"]
# ENTRYPOINT ["ls"]
# CMD ["-la","/usr/local/bin/"]