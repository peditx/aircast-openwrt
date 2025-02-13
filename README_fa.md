# AirCast برای OpenWrt
[![بازدیدکننده](https://img.shields.io/badge/Chat%20on-Telegram-blue.svg)](https://t.me/peditx) [![مجوز: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)

![AirCast Cover](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)

## معرفی
AirCast یک پل استریمینگ قدرتمند است که امکان پخش صدای بی‌دردسر از دستگاه‌های مختلف به بلندگوهای غیر سازگار با AirPlay را فراهم می‌کند. این پروژه اولین از نوع خود در OpenWrt است که توسط **PeDitX** توسعه یافته است.

## ویژگی‌ها
- **پشتیبانی از معماری‌های متعدد**: بر روی x86_64، ARM، MIPS و موارد دیگر کار می‌کند.
- **شناسایی خودکار IP پل**: اطمینان از پیکربندی صحیح شبکه.
- **اجرای به عنوان سرویس Procd**: اطمینان از پایداری و راه‌اندازی مجدد خودکار.
- **نصب و استفاده آسان**: نصب با یک فرمان و منوی کنترلی تعاملی.

## معماری‌های پشتیبانی شده
- x86_64
- aarch64
- armv7l
- armv6l
- armv5l
- mips
- mipsel

## نصب
برای نصب AirCast بر روی OpenWrt، فرمان زیر را اجرا کنید:
```sh
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/refs/heads/main/aircast_install.sh && sh aircast_install.sh
```

## کنترل
برای مدیریت آسان از `aircast-control` استفاده کنید:
```sh
aircast-control
```
گزینه‌ها:
- **status**: وضعیت AirCast را بررسی کنید.
- **restart**: AirCast را راه‌اندازی مجدد کنید.
- **on**: سرویس AirCast را شروع کنید.
- **off**: سرویس AirCast را متوقف کنید.

## تشکر و قدردانی
تشکر ویژه از:
- [AirConnect توسط philippe44](https://github.com/philippe44/AirConnect)
- [EZpasswall توسط PeDitX](https://github.com/peditx/EZpasswall/)
- [OpenWrt](https://openwrt.org/)

© PeDitX 2025 | تلگرام: [@peditx](https://t.me/peditx)
