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
sudo podman pod create --replace --publish 51820:51820/udp --volume vpn-vol:/usr/VPN --name VPN

# Start vpn-wireguard container
sudo podman run --cap-drop all --cap-add CAP_NET_ADMIN --pod VPN --name vpn-wireguard --detach --replace vpn
```

## 通信対象となる端末の登録
設定する公開鍵は通信対象の端末(スマートフォンやノートPCなど)であり、サーバーのものではない。  
端末と証明書は常に1対1で関連付けられる。
```bash
# 端末の追加
sudo podman exec -it vpn-wireguard peer add -k <key>

# 端末の削除
sudo podman exec -it vpn-wireguard peer rm -k <key>

# 登録済み端末の取得
sudo podman exec -it vpn-wireguard peer show
```

## 自動起動の設定
```sh
# コンテナはビルド済みであることが前提
sudo cp Quadlet/* /usr/share/containers/systemd/
sudo /usr/lib/systemd/system-generators/podman-system-generator
sudo systemctl enable --now pod-VPN
```

## 自動起動解除
```sh
sudo systemctl disable --now pod-VPN
sudo rm /etc/systemd/system/{pod-VPN,pod-VPN.service}
```

