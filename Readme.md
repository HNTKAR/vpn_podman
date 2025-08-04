# はじめに
以下に各コンテナの説明や環境の設定を記載

## 全体設定
|名称|値|備考|
|:-:|:-:|:-:|
|ポッド名|vpn|ポッド作成時に設定|

## wireguard container
|名称|値|備考|
|:-:|:-:|:-:|
|localtime|Asia/Tokyo|ENV TZ|
|VPN network|10.0.0.1/24|ENV VPN_CIDR|
|VPN port|51820|ENV PORT|

# 実行スクリプト

## 各種コンテナの起動
<!-- ブランチの切り替えにより、alpineをベースとしたイメージにも変更可能 -->
```bash
cd vpn_podman

# 利用するNIC名を設定
NIC="eth0"

# 利用するIPアドレスを指定
NewIP="192.168.0.11"

# 所属ネットワークのサブネットアドレスを指定
SubnetAddr="192.168.0.0/24"

# コンテナのビルド
sudo podman build --tag vpn --file wireguard/Dockerfile

# ポッドの作成
sudo podman pod create --replace --publish 51820:51820/udp --name VPN

# wireguard
sudo podman run --cap-drop all --cap-add CAP_NET_ADMIN --pod VPN --name vpn-wireguard --detach --replace vpn
```

## 通信対象となる端末の登録
```bash
# 設定する公開鍵やIPは通信対象の端末(スマートフォンやノートPCなど)であり、サーバーのものではない
sudo podman exec -it vpn-wireguard peer -p <通信対象の公開鍵> -a <通信対象の端末に割り当てたWireguard用のIPアドレス/32>
```

## 自動起動の設定
```sh
sudo podman generate systemd -f -n --new --restart-policy=on-failure vpn >tmp.service
cat tmp.service | \
xargs -I {} sudo cp {} -frp /etc/systemd/system/
sed -e "s/.*\///g" tmp.service | \
grep pod | \
xargs -n 1 sudo systemctl enable --now
```

## 自動起動解除
```sh
sed -e "s/.*\///g" tmp.service | \
grep pod | \
xargs -n 1 sudo systemctl disable --now
```
sudo podman pod create --replace --publish 51820:51820/udp --name vpn_test
sudo podman run --privileged -it --pod vpn_test --name tester --replace vpn_test sh

VPN_NET="172.20.0.1/20"
ip link add dev wg0 type wireguard
ip address add dev wg0 $VPN_NET
wg set wg0 listen-port 51820 private-key /key/private.key peer ItW/JBxTN2dd6FV5RLRLefdxx5riCEtta49/tasBm2M= allowed-ips 0.0.0.0/0
ip link set down dev wg0
ip link set up dev wg0

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT

