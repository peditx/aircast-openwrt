# AirCast для OpenWrt
[![Бейдж посетителя](https://img.shields.io/badge/Chat%20on-Telegram-blue.svg)](https://t.me/peditx) [![Лицензия: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)

![AirCast Cover](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)

## Введение
AirCast — это мощный потоковый мост, который позволяет бесперебойно передавать аудио с различных устройств на динамики, несовместимые с AirPlay. Этот проект является первым подобным решением для OpenWrt, разработанным **PeDitX**.

## Особенности
- **Поддержка нескольких архитектур**: Работает на x86_64, ARM, MIPS и других.
- **Автоматическое определение IP моста**: Обеспечивает правильную настройку сети.
- **Запуск как сервис Procd**: Обеспечивает стабильность и автоматические перезапуски.
- **Легкость установки и использования**: Установка одной командой и интерактивное меню управления.

## Поддерживаемые архитектуры
- x86_64
- aarch64
- armv7l
- armv6l
- armv5l
- mips
- mipsel

## Установка
Для установки AirCast на OpenWrt выполните следующую команду:
```sh
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/refs/heads/main/aircast_install.sh && sh aircast_install.sh
```

## Управление
Для удобного управления используйте `aircast-control`:
```sh
aircast-control
```
Опции:
- **status**: Проверить статус AirCast.
- **restart**: Перезапустить AirCast.
- **on**: Запустить сервис AirCast.
- **off**: Остановить сервис AirCast.

## Благодарности
Особая благодарность:
- [AirConnect от philippe44](https://github.com/philippe44/AirConnect)
- [EZpasswall от PeDitX](https://github.com/peditx/EZpasswall/)
- [OpenWrt](https://openwrt.org/)

© PeDitX 2025 | Telegram: [@peditx](https://t.me/peditx)
