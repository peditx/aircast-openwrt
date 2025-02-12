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
opkg install whiptail

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

# Whiptail to get device name
DEVICE_NAME=$(whiptail --inputbox "Enter the name of the device:" 8 39 "AirCastDevice" 3>&1 1>&2 2>&3)

# Automatically get the IP address of the device (from br-lan interface)
IP_ADDRESS=$(ip addr show br-lan | grep "inet " | awk '{print $2}' | cut -d/ -f1)

# If IP is not found, fallback to a default IP
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS="192.168.1.1"
fi

# Create service startup script with interface br-lan
cat << EOF > /etc/init.d/aircast
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/aircast -i br-lan --device-name "$DEVICE_NAME" --ip "$IP_ADDRESS"
    procd_set_param respawn
    procd_close_instance
}
EOF
chmod +x /etc/init.d/aircast

# Enable and start service
/etc/init.d/aircast enable
/etc/init.d/aircast start

# Create control script to manage AirCast
cat << 'EOF' > /usr/bin/aircast-control
#!/bin/sh

# Menu for managing AirCast devices
CHOICE=$(whiptail --title "AirCast Control" --menu "Choose an option" 15 50 4 \
"1" "Show AirCast status" \
"2" "Change device name" \
"3" "Restart AirCast" \
"4" "Exit" 3>&1 1>&2 2>&3)

case \$CHOICE in
    1)
        # Show AirCast status
        whiptail --msgbox "$(ps | grep aircast)" 20 60
        ;;
    2)
        # Change device name
        DEVICE_NAME=\$(whiptail --inputbox "Enter the new name of the device:" 8 39 "AirCastDevice" 3>&1 1>&2 2>&3)

        # Update the startup script with new name
        sed -i "s/--device-name.*/--device-name \"\$DEVICE_NAME\"/" /etc/init.d/aircast

        # Restart the service
        /etc/init.d/aircast restart
        whiptail --msgbox "Device name changed and AirCast restarted." 8 45
        ;;
    3)
        # Restart AirCast
        /etc/init.d/aircast restart
        whiptail --msgbox "AirCast restarted." 8 45
        ;;
    4)
        # Exit the menu
        exit 0
        ;;
    *)
        # Invalid option
        whiptail --msgbox "Invalid option. Exiting." 8 45
        ;;
esac
EOF

chmod +x /usr/bin/aircast-control

# Display completion message
echo "\n✅ AirCast installation and setup completed! You can control AirCast using the 'aircast-control' command."
