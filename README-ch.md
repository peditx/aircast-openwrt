# AirCast for OpenWrt
[![访问徽章](https://img.shields.io/badge/Chat%20on-Telegram-blue.svg)](https://t.me/peditx) [![许可证: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)

![AirCast 封面](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)

## 介绍
AirCast 是一个强大的流媒体桥接工具，可以从各种设备将音频无缝传输到不支持 AirPlay 的扬声器。这个项目是 OpenWrt 上的第一个此类工具，由 **PeDitX** 开发。

## 特性
- **支持多种架构**：支持 x86_64、ARM、MIPS 等架构。
- **自动检测桥接 IP**：确保正确的网络配置。
- **作为 Procd 服务运行**：保证稳定性并支持自动重启。
- **简单安装和使用**：只需一个命令即可安装，并提供交互式控制菜单。

## 支持的架构
- x86_64
- aarch64
- armv7l
- armv6l
- armv5l
- mips
- mipsel

## 安装
运行以下命令以在 OpenWrt 上安装 AirCast：
```sh
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/refs/heads/main/aircast_install.sh && sh aircast_install.sh
```

## 控制
使用 `aircast-control` 进行简便管理：
```sh
aircast-control
```
选项：
- **status**: 检查 AirCast 的状态。
- **restart**: 重启 AirCast。
- **on**: 启动 AirCast 服务。
- **off**: 停止 AirCast 服务。

## 鸣谢
特别感谢：
- [AirConnect by philippe44](https://github.com/philippe44/AirConnect)
- [EZpasswall by PeDitX](https://github.com/peditx/EZpasswall/)
- [OpenWrt](https://openwrt.org/)

© PeDitX 2025 | Telegram: [@peditx](https://t.me/peditx)
