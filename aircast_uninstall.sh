#!/bin/sh

echo "Starting Air-Cast uninstallation..."

# 1. Stop and disable the service
echo "Stopping and disabling Air-Cast service..."
if [ -f /etc/init.d/aircast ]; then
    /etc/init.d/aircast stop >/dev/null 2>&1 || true
    /etc/init.d/aircast disable >/dev/null 2>&1 || true
fi

# 2. Remove files and directories
echo "Removing service script..."
rm -f /etc/init.d/aircast

echo "Removing binary and installation directory..."
rm -f /usr/bin/aircast
rm -rf /etc/aircast

echo "Removing UCI configuration..."
rm -f /etc/config/aircast

echo "Removing LuCI files..."
rm -f /usr/lib/lua/luci/controller/aircast.lua
rm -f /usr/lib/lua/luci/view/aircast_status.htm

echo "Removing temporary files..."
rm -f /tmp/aircast*

# 3. Remove firewall rule
echo "Removing firewall rule..."
uci -q delete firewall.aircast_mdns
uci commit firewall
/etc/init.d/firewall reload >/dev/null 2>&1

# 4. Clean LuCI cache
echo "Clearing LuCI cache..."
rm -f /tmp/luci-indexcache

echo "Air-Cast has been completely uninstalled."

exit 0
