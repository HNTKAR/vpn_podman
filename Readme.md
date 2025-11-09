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
|VPN network|172.20.0.1/24|VPN_NETを指定することで変更可能|
|VPN network|172.20.0.1/24|VPN_NETを指定することで変更可能|
|VPN port|51820|PORTを指定することで変更可能|

# 実行スクリプト

## systemdを使用した起動の設定(自動起動有効化済み)
### 有効化
```sh
cd /Path/to/vpn_podman
sudo mkdir -p /usr/local/lib/systemd/system
sudo cp Systemd/* /usr/local/lib/systemd/system/
sudo mkdir -p /usr/local/lib/systemd/system
sudo cp Systemd/* /usr/local/lib/systemd/system/
sudo cp Quadlet/* /etc/containers/systemd/
sudo /usr/lib/systemd/system-generators/podman-system-generator
sudo systemctl daemon-reload
sudo systemctl start podman_build_vpn
sudo systemctl enable --now podman_logger_VPN
sudo systemctl start podman_pod_VPN
```

### 無効化
```sh
sudo systemctl stop podman_pod_VPN
sudo rm /etc/containers/systemd/vpn-*
sudo systemctl daemon-reload
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

# 補足
## systemdを使用しない起動方法
```bash
cd Path/to/vpn_podman

# Build Container
sudo podman build --tag vpn --file wireguard/Dockerfile .
sudo podman build --tag vpn --file wireguard/Dockerfile .

# Creeate Pod
sudo podman pod create --replace --publish 51820:51820/udp --sysctl=net.ipv4.ip_forward=1 --volume VPN_:/usr/VPN --name VPN

# Start vpn-wireguard container
sudo podman run --cap-drop all --cap-add CAP_NET_ADMIN --pod VPN --name vpn-wireguard --detach --replace vpn
```