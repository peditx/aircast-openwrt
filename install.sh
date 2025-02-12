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

# Download the correct binary
curl -L -o /usr/bin/aircast "$BINARY_URL" || wget -O /usr/bin/aircast "$BINARY_URL"
chmod +x /usr/bin/aircast

# Create AirCast config file
cat << EOF > /etc/aircast.conf
interface=br-lan
device_name=AirCastDevice
ip=$(ip addr show br-lan | grep inet | awk '{print $2}' | cut -d/ -f1)
EOF

# Create service startup script
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    # Ensure AirCast uses the correct network interface and config file
    procd_open_instance
    procd_set_param command /usr/bin/aircast --config /etc/aircast.conf
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

# Additional step for DHCP (bridge interface should already handle this)
echo "\nThe bridge interface (br-lan) is configured to handle DHCP."

