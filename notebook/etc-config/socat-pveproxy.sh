#!/bin/bash
WIFI_IFACE="wlo1"
LISTEN_IP=$(ip -4 addr show "$WIFI_IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
if [ -z "$LISTEN_IP" ]; then
    echo "No IP found on $WIFI_IFACE" >&2
    exit 1
fi
exec /usr/bin/socat "TCP-LISTEN:8006,bind=$LISTEN_IP,fork,reuseaddr" TCP:192.168.1.40:8006
