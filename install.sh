#!/bin/sh

# 1. تشخیص معماری سیستم
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        AIRCAST_ARCH="x86_64"
        ;;
    aarch64)
        AIRCAST_ARCH="aarch64"
        ;;
    armv7l)
        AIRCAST_ARCH="armv7"
        ;;
    armv6l)
        AIRCAST_ARCH="armv6"
        ;;
    armv5l)
        AIRCAST_ARCH="armv5"
        ;;
    mips)
        AIRCAST_ARCH="mips"
        ;;
    mipsel)
        AIRCAST_ARCH="mipsel"
        ;;
    *)
        echo "معماری سیستم پشتیبانی نمیشود: $ARCH"
        exit 1
        ;;
esac

# 2. آپدیت پکیجها و نصب curl/wget
opkg update
opkg install curl || opkg install wget

# 3. بررسی وجود باینری در ریپازیتوری
REPO_URL="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/files"

# تعیین ابزار بررسی (curl/wget)
if which curl >/dev/null; then
    CHECK_CMD="curl --head --silent --fail"
else
    CHECK_CMD="wget --spider --quiet"
fi

# انتخاب آدرس باینری
if $CHECK_CMD "$REPO_URL/aircast-linux-$AIRCAST_ARCH-static" >/dev/null; then
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH-static"
else
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH"
fi

# 4. متوقف کردن سرویس قدیمی
echo "متوقف کردن سرویس AirCast..."
killall -q aircast || true
sleep 2

# حذف باینری قدیمی
[ -f /usr/bin/aircast ] && rm /usr/bin/aircast

# 5. دانلود باینری جدید
echo "دانلود باینری AirCast..."
if which curl >/dev/null; then
    curl -L -o /usr/bin/aircast "$BINARY_URL"
else
    wget -O /usr/bin/aircast "$BINARY_URL"
fi
chmod +x /usr/bin/aircast

# 6. ایجاد فایل کانفیگ با تنظیمات صحیح
echo "ایجاد فایل کانفیگ..."
cat <<EOF > /etc/config.xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <interface>eth1</interface> <!-- تغییر به eth1 مطابق لاگ شما -->
    <device_name>AirCast-OpenWrt</device_name>
    <ip>192.168.100.10</ip> <!-- آیپی مطابق خروجی لاگ -->
</config>
EOF
chmod 644 /etc/config.xml

# 7. ایجاد سرویس procd
echo "تنظیم سرویس init.d..."
cat <<'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1
DEPENDS="network"

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/aircast -c /etc/config.xml # پارامتر ضروری
    procd_set_param respawn
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}
EOF
chmod +x /etc/init.d/aircast

# 8. راه‌اندازی سرویس
/etc/init.d/aircast enable
/etc/init.d/aircast restart

# 9. بررسی وضعیت
echo "نصب کامل شد! وضعیت سرویس:"
logread | grep -i aircast
ps | grep aircast
