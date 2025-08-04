# はじめに
以下に各コンテナの説明や環境の設定を記載

## 全体設定
|名称|値|備考|
|:-:|:-:|:-:|
|イメージ名|vpn||
|ポッド名|VPN||
|コンテナ名|vpn-wireguard|

## wireguard container
|名称|値|備考|
|:-:|:-:|:-:|
|localtime|Asia/Tokyo||
|VPN network|10.0.0.1/24|VPN_NETを指定することで変更可能|
|VPN port|51820|PORTを指定することで変更可能|

# 実行スクリプト

## 各種コンテナの起動
<!-- ブランチの切り替えにより、alpineをベースとしたイメージにも変更可能 -->
```bash
cd vpn_podman


# Build Container
sudo podman build --tag vpn --file wireguard/Dockerfile

# Creeate Pod
sudo podman pod create --replace --publish 51820:51820/udp --volume VPN_:/usr/VPN --name VPN

# Start vpn-wireguard container
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

