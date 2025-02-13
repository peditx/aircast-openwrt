# AirCast for OpenWrt
[![Visitor Badge](https://img.shields.io/badge/Chat%20on-Telegram-blue.svg)](https://t.me/peditx) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)

![AirCast Cover](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)

## Introduction
AirCast is a powerful streaming bridge that enables seamless audio casting from various devices to non-AirPlay-compatible speakers. This project is the first of its kind on OpenWrt, developed by **PeDitX**.

## Features
- **Supports Multiple Architectures**: Works on x86_64, ARM, MIPS, and more.
- **Auto-Detects Bridge IP**: Ensures proper network configuration.
- **Runs as a Procd Service**: Ensures stability and automatic restarts.
- **Easy to Install & Use**: Single command installation and interactive control menu.

## Supported Architectures
- x86_64
- aarch64
- armv7l
- armv6l
- armv5l
- mips
- mipsel

## Installation
Run the following command to install AirCast on OpenWrt:
```sh
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/refs/heads/main/aircast_install.sh && sh aircast_install.sh
```

## Control
Use `aircast-control` for easy management:
```sh
aircast-control
```
Options:
- **status**: Check the status of AirCast.
- **restart**: Restart AirCast.
- **on**: Start the AirCast service.
- **off**: Stop the AirCast service.

## Acknowledgments
Special thanks to:
- [AirConnect by philippe44](https://github.com/philippe44/AirConnect)
- [EZpasswall by PeDitX](https://github.com/peditx/EZpasswall/)
- [OpenWrt](https://openwrt.org/)

© PeDitX 2025 | Telegram: [@peditx](https://t.me/peditx)

