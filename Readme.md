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

# タグの名称を設定
TagName="main"

# 利用するNIC名を設定
NIC="eth0"

# 利用するIPアドレスを指定
NewIP="192.168.0.11"

# 所属ネットワークのサブネットアドレスを指定
SubnetAddr="192.168.0.0/24"

# ネットワークの作成
sudo podman network create --driver ipvlan --opt parent=$NIC --subnet $SubnetAddr LocalLAN

# ポッドの作成
sudo podman pod create --replace --network LocalLAN --ip=$NewIP --name vpn

# wireguard
sudo podman build --tag vpn-wireguard:$TagName --file wireguard/Dockerfile
sudo podman run --detach --replace --privileged --pod vpn --name vpn-wireguard vpn-wireguard:$TagName

# ポートフォワーディングの設定
sudo firewall-cmd --add-forward-port=port=$PORT:proto=udp:toport=$PORT:toaddr=$NewIP
sudo firewall-cmd --add-forward-port=port=$PORT:proto=udp:toport=$PORT:toaddr=$NewIP --permanent
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