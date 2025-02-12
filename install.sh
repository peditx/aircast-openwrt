#!/bin/sh

# Detect system architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    AIRCAST_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    AIRCAST_ARCH="aarch64"
elif [ "$ARCH" = "armv7l" ]; then
    AIRCAST_ARCH="arm"
elif [ "$ARCH" = "armv6l" ]; then
    AIRCAST_ARCH="armv6"
elif [ "$ARCH" = "armv5l" ]; then
    AIRCAST_ARCH="armv5"
elif [ "$ARCH" = "mips" ]; then
    AIRCAST_ARCH="mips"
elif [ "$ARCH" = "mipsel" ]; then
    AIRCAST_ARCH="mipsel"
else
    echo "Unsupported system architecture: $ARCH"
    exit 1
fi

# Install required packages
opkg update
opkg install curl || opkg install wget

# Define custom repository URL
REPO_URL="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/files"

# Try downloading static version first, fallback to normal if not available
if curl --head --silent --fail "$REPO_URL/aircast-linux-$AIRCAST_ARCH-static" > /dev/null; then
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH-static"
else
    BINARY_URL="$REPO_URL/aircast-linux-$AIRCAST_ARCH"
fi

# Stop any running aircast processes before installing new one
echo "Stopping any running AirCast processes..."
killall aircast

# Wait for process termination
sleep 2

# Remove old binary if it exists
if [ -f /usr/bin/aircast ]; then
    echo "Removing old aircast binary..."
    rm /usr/bin/aircast
fi

# Download the correct binary
echo "Downloading new AirCast binary..."
curl -L -o /usr/bin/aircast "$BINARY_URL" || wget -O /usr/bin/aircast "$BINARY_URL"
chmod +x /usr/bin/aircast

# Create service startup script
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/aircast
    procd_set_param respawn
    procd_close_instance
}
EOF
chmod +x /etc/init.d/aircast

# Enable and start service
/etc/init.d/aircast enable
/etc/init.d/aircast start

# Display service status
echo "\n✅ AirCast installation and setup completed! Device is ready to cast."
ps | grep aircast

# Print out bridge interface DHCP info
echo "\nThe bridge interface (br-lan) is configured to handle DHCP."
