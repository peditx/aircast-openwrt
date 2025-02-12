#!/bin/sh

# 1. Detect system architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        AIRCAST_ARCH="x86_64"
        ;;
    aarch64)
        AIRCAST_ARCH="aarch64"
        ;;
    armv7l)
        AIRCAST_ARCH="arm"
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
        echo "Unsupported system architecture: $ARCH"
        exit 1
        ;;
esac

# 2. Update package list and install required packages
opkg update
opkg install curl || opkg install wget

# 3. Define repository URL and determine binary URL
REPO_URL="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/files"
if curl --head --silent --fail "$REPO_URL/aircast-linux-$AIRCAST_ARCH-static" > /dev/null; then
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH-static"
else
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH"
fi

# 4. Stop any running AirCast processes and remove the old binary
echo "Stopping any running AirCast processes..."
killall aircast 2>/dev/null
sleep 2

if [ -f /usr/bin/aircast ]; then
    echo "Removing old AirCast binary..."
    rm /usr/bin/aircast
fi

# 5. Download the new AirCast binary
echo "Downloading new AirCast binary..."
curl -L -o /usr/bin/aircast "$BINARY_URL" || wget -O /usr/bin/aircast "$BINARY_URL"
chmod +x /usr/bin/aircast

# 6. Generate config file in /etc with suppressed output
echo "Generating config file..."
/usr/bin/aircast -i /etc/config.xml >/dev/null 2>&1

# Check if config file created
if [ ! -f /etc/config.xml ]; then
    echo "Error: Failed to generate config.xml!"
    exit 1
fi

# 7. Modify config with correct path
sed -i 's/<interface>.*<\/interface>/<interface>br-lan<\/interface>/' /etc/config.xml
sed -i 's/<ip>.*<\/ip>/<ip>10.1.1.1<\/ip>/' /etc/config.xml
sed -i 's/<device_name>.*<\/device_name>/<device_name>AirCastDevice<\/device_name>/' /etc/config.xml

# Set permissions
chmod 644 /etc/config.xml

# 8. Create init.d service with procd support
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_set_param command /usr/bin/aircast -c /etc/config.xml
    procd_set_param respawn
    procd_set_param stdout 1
    procd_set_param stderr 1
}

stop_service() {
    killall aircast
}
EOF
chmod +x /etc/init.d/aircast

# 9. Enable and start service
/etc/init.d/aircast enable
/etc/init.d/aircast start

# 10. Verify
echo "\n✅ Installation Complete! Status:"
sleep 2
/etc/init.d/aircast status
ps | grep -v grep | grep aircast

echo "\nConfig path: /etc/config.xml"
echo "Bridge interface: br-lan | IP: 10.1.1.1"
