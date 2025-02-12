#!/bin/sh

# ------ Part 1: Detect System Architecture ------
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) AIRCAST_ARCH="x86_64" ;;
    aarch64) AIRCAST_ARCH="aarch64" ;;
    armv7l) AIRCAST_ARCH="arm" ;;
    armv6l) AIRCAST_ARCH="armv6" ;;
    armv5l) AIRCAST_ARCH="armv5" ;;
    mips) AIRCAST_ARCH="mips" ;;
    mipsel) AIRCAST_ARCH="mipsel" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# ------ Part 2: Install Dependencies ------
echo "Installing dependencies..."
opkg update
opkg install curl libopenssl ca-bundle nmap || {
    echo "Error installing packages!"
    exit 1
}

# ------ Part 3: Download Binary ------
REPO_URL="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/files"
BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH-static"

echo "Downloading aircast..."
if curl -L -o /tmp/aircast "$BINARY_URL"; then
    echo "Download successful!"
else
    echo "Download failed!"
    exit 1
fi

# ------ Part 4: System Configuration ------
echo "Configuring system..."
mv /tmp/aircast /usr/bin/aircast
chmod +x /usr/bin/aircast

# ------ Part 5: Create Config File ------
cat << 'EOF' > /etc/config.xml
<?xml version="1.0"?>
<config>
    <interface>br-lan</interface>
    <ip>10.1.1.1</ip>
    <device_name>AirCast-OpenWRT</device_name>
    <port>33221</port>
    <log_level>debug</log_level>
    <mdns>
        <enable>0</enable>
    </mdns>
</config>
EOF

# ------ Part 6: Lock Config File ------
chmod 644 /etc/config.xml
chown root:root /etc/config.xml
chattr +i /etc/config.xml

# ------ Part 7: Create Service ------
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_set_param command /usr/bin/aircast \
        -c /etc/config.xml \
        --foreground \
        --no-mdns \
        --log-timestamps
    procd_set_param respawn 300 5 0
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_set_param user root
    procd_set_param pidfile /var/run/aircast.pid
}

stop_service() {
    kill -TERM $(cat /var/run/aircast.pid 2>/dev/null)
}
EOF

# ------ Part 8: Enable Service ------
chmod +x /etc/init.d/aircast
/etc/init.d/aircast enable
/etc/init.d/aircast restart

# ------ Part 9: Verification ------
echo "\n\n--- Final Checks ---"
sleep 3
echo "\nProcess check:"
ps | grep -v grep | grep aircast

echo "\nPort check:"
nmap -p 33221 127.0.0.1 | grep 'open'

echo "\nLog check:"
logread | grep aircast | tail -n 5

echo "\nInstallation complete! Test with Apple devices."
