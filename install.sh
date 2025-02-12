#!/bin/sh

# Detect system architecture
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

# Update package list and install curl (or wget if curl is not available)
opkg update
opkg install curl || opkg install wget

# Define repository URL
REPO_URL="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/files"

# Try to download the static version first; if unavailable, use the normal version
if curl --head --silent --fail "$REPO_URL/aircast-linux-$AIRCAST_ARCH-static" > /dev/null; then
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH-static"
else
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH"
fi

# Stop any running AirCast processes
echo "Stopping AirCast processes..."
killall aircast
sleep 2

# Remove the old binary if it exists
if [ -f /usr/bin/aircast ]; then
    echo "Removing old AirCast binary..."
    rm /usr/bin/aircast
fi

# Download the new AirCast binary
echo "Downloading new AirCast binary..."
curl -L -o /usr/bin/aircast "$BINARY_URL" || wget -O /usr/bin/aircast "$BINARY_URL"
chmod +x /usr/bin/aircast

# Create the default config file (config.xml) in /etc
cat <<EOF > /etc/config.xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <interface>br-lan</interface>
    <device_name>AirCastDevice</device_name>
    <ip>10.1.1.1</ip>
</config>
EOF

# Create the init.d script for AirCast service
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    # Change directory to /etc so that config.xml is in the working directory
    cd /etc && /usr/bin/aircast
}
EOF
chmod +x /etc/init.d/aircast

# Enable and start the AirCast service
/etc/init.d/aircast enable
/etc/init.d/aircast start

# Display the status
echo "\n✅ AirCast installation and setup completed! Device is ready to cast."
ps | grep aircast

echo "\nThe bridge interface (br-lan) is configured to handle DHCP."
