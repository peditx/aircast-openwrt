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
killall aircast
sleep 2

if [ -f /usr/bin/aircast ]; then
    echo "Removing old AirCast binary..."
    rm /usr/bin/aircast
fi

# 5. Download the new AirCast binary
echo "Downloading new AirCast binary..."
curl -L -o /usr/bin/aircast "$BINARY_URL" || wget -O /usr/bin/aircast "$BINARY_URL"
chmod +x /usr/bin/aircast

# 6. Generate a reference config file in /etc if it doesn't exist,
# then modify it to set the desired interface and IP.
echo "Generating reference config file..."
cd /etc || exit 1
/usr/bin/aircast -i config.xml

# At this point, a reference config.xml should be generated.
# Update the configuration with your desired settings.
# (Adjust the sed commands as needed based on the actual format of the reference file.)
sed -i 's/<interface>.*<\/interface>/<interface>br-lan<\/interface>/' config.xml
sed -i 's/<ip>.*<\/ip>/<ip>10.1.1.1<\/ip>/' config.xml
# You can also update the device name if present:
sed -i 's/<device_name>.*<\/device_name>/<device_name>AirCastDevice<\/device_name>/' config.xml

# 7. Create the init.d service script for AirCast.
# This script changes the working directory to /etc (so that config.xml is found)
# and launches AirCast (which will load config.xml from the current directory).
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    cd /etc && /usr/bin/aircast
}
EOF
chmod +x /etc/init.d/aircast

# 8. Enable and start the AirCast service
/etc/init.d/aircast enable
/etc/init.d/aircast start

# 9. Display service status
echo "\n✅ AirCast installation and setup completed! Device is ready to cast."
ps | grep aircast

echo "\nThe bridge interface (br-lan) is configured to handle DHCP."
