#!/bin/sh

# 启动Tailscale
/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
/app/tailscale up --auth-key=${TAILSCALE_AUTHKEY} --hostname=cloudrun-app --ssh --accept-routes

# 等待Tailscale连接
echo "Waiting for Tailscale to connect..."
while ! tailscale status; do
  sleep 5
done
echo "Tailscale connected"

# 设置代理
export ALL_PROXY=socks5://localhost:1055/

# 下载并安装x-ui
echo "Downloading and installing x-ui..."
cd /root/
if ! wget --no-check-certificate https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz; then
    echo "Failed to download x-ui package"
    exit 1
fi

if [ ! -s x-ui-linux-amd64.tar.gz ]; then
    echo "Downloaded file is empty or doesn't exist"
    exit 1
fi

echo "Installing x-ui..."
rm -rf x-ui/ /usr/local/x-ui/ /usr/bin/x-ui
if ! tar zxvf x-ui-linux-amd64.tar.gz; then
    echo "Failed to extract x-ui package"
    exit 1
fi

if [ ! -d "x-ui" ]; then
    echo "Extracted x-ui directory not found"
    exit 1
fi

chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh
cp x-ui/x-ui.sh /usr/bin/x-ui
cp -f x-ui/x-ui.service /etc/systemd/system/
mv x-ui/ /usr/local/

systemctl daemon-reload
systemctl enable x-ui
if ! systemctl restart x-ui; then
    echo "Failed to start x-ui service"
    journalctl -u x-ui.service -b --no-pager
    exit 1
fi

echo "x-ui installation completed successfully"

# 健康检查端点
echo "Starting health check server on port $PORT"
while true; do { echo -e "HTTP/1.1 200 OK\n\n$(date)"; } | nc -l -p $PORT; done &

# 保持容器运行
while true; do
  sleep 60
done
