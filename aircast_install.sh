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

# 4. Stop any running AirCast processes and remove old binary
echo "Stopping running AirCast processes..."
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

# 6. Create init.d service script for AirCast
cat << 'EOF' > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    # Get the IP address from br-lan; default to 10.1.1.1 if not found
    BRIP=$(ip addr show br-lan | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    if [ -z "$BRIP" ]; then
        BRIP="10.1.1.1"
    fi
    echo "Starting AirCast with IP: $BRIP"
    procd_open_instance
    procd_set_param command /usr/bin/aircast -b "$BRIP"
    procd_set_param respawn
    procd_close_instance
}
EOF
chmod +x /etc/init.d/aircast

# 7. Enable and start the AirCast service
/etc/init.d/aircast enable
/etc/init.d/aircast start

# 8. Create aircast-control script
cat << 'EOF' > /usr/bin/aircast-control
#!/bin/sh

action=$(whiptail --title "AirCast Control" --menu "Choose an option:" 15 50 4 \
    "status" "Check AirCast status" \
    "restart" "Restart AirCast" \
    "on" "Start AirCast service" \
    "off" "Stop AirCast service" 3>&1 1>&2 2>&3)

case "$action" in
    status)
        /etc/init.d/aircast status
        ;;
    restart)
        /etc/init.d/aircast restart
        ;;
    on)
        /etc/init.d/aircast start
        ;;
    off)
        /etc/init.d/aircast stop
        ;;
    *)
        echo "Invalid option"
        ;;
esac
EOF
chmod +x /usr/bin/aircast-control

# 9. Display service status
echo "\n✅ AirCast installation and setup completed! Device is ready to cast."
ps | grep aircast

echo "\nThe bridge interface (br-lan) is configured to handle DHCP."
