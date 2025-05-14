**一个简易容器配置以及镜像，能够确保能够同时运行tailscale的同时运行3x-ui，专用于托管应用（非代码托管型）。**

这样或许可以降低搭建中继服务器的成本，毕竟容器的话跟虚拟机还是有一定的区别的

## 如何使用

对于容器托管应用，镜像为ghcr.io/modimobeikete/tailscale-3x-ui:main
环境变量要添加的如下：
TAILSCALE_AUTHKEY
数值为你在Tailscale获取的认证密钥

## 安装在服务器上。

如果需要使用的话，用这些代码

```
docker run -d \
  -e TAILSCALE_AUTHKEY=（你自己的认证密钥） \
  -p 2053:2053 \
  --cap-add=NET_ADMIN \
  --name 3docker \
  （任意名字记得改）
```

## 特殊容器

如果说容器是要指定存储空间的（如ClawRun 必须指明存储空间不然无限重启的），目前所用到的目录如下：


```
/var/lib/tailscale
/etc/x-ui/
/root/cert/
/usr/bin/x-ui
/etc/systemd/system/
/usr/local/
```

### 缺点

如果说你有想玩游戏的需求，经过测试，虽然节点使用起来大同小异，但是他在某些地方会出现问题，后续会持续测试。

   - **VRchat:** 会无限连接超时。

有关这些问题，目前先暂时把问题反馈tailscale那里，如果真的要用，可以用UOT过度一下。
