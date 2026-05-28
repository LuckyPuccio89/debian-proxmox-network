#!/bin/bash
# Configurazione rete per Desktop Ryzen 5800X
# Adatta IP e nomi interfacce alla tua configurazione
set -e

# ============================================================
# PERSONALIZZA QUI:
LAN_IP="192.168.1.XXX"
LAN_GW="192.168.1.1"
LAN_IFACE="enp3s0"
WIFI_SSID="TuaReteWiFi"
WIFI_IFACE="wlp2s0"
# ============================================================

echo "Configurazione Desktop Ryzen 5800X"
echo "  LAN IP: $LAN_IP  GW: $LAN_GW  IF: $LAN_IFACE"
echo "  WiFi: $WIFI_SSID ($WIFI_IFACE)"
read -p "Continuare? (s/N): " confirm
[ "$confirm" != "s" ] && echo "Annullato." && exit 1

cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback
iface $LAN_IFACE inet manual
auto vmbr0
iface vmbr0 inet static
	address $LAN_IP/24
	gateway $LAN_GW
	bridge-ports $LAN_IFACE
	bridge-stp off
	bridge-fd 0
source /etc/network/interfaces.d/*
EOF

cat > /etc/default/pveproxy << EOF
LISTEN_IP="$LAN_IP"
EOF

cat > /etc/NetworkManager/NetworkManager.conf << 'EOF'
[main]
plugins=ifupdown,keyfile
[ifupdown]
managed=false
EOF

chattr -i /etc/resolv.conf 2>/dev/null || true
cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
chattr +i /etc/resolv.conf

echo "precedence ::ffff:0:0/96  100" > /etc/gai.conf

WIFI_IP=$(ip -4 addr show $WIFI_IFACE 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)
if [ -n "$WIFI_IP" ]; then
    cat > /etc/systemd/system/socat-pveproxy.service << EOF
[Unit]
Description=socat relay: WiFi -> Proxmox LAN
[Service]
Type=simple
ExecStart=/usr/bin/socat TCP-LISTEN:8006,bind=$WIFI_IP,fork,reuseaddr TCP:$LAN_IP:8006
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    nmcli connection modify "$WIFI_SSID" ipv4.route-metric 0 2>/dev/null || true
fi

systemctl daemon-reload
systemctl enable --now socat-pveproxy 2>/dev/null || systemctl restart socat-pveproxy 2>/dev/null || true
systemctl restart NetworkManager
ifdown vmbr0 2>/dev/null; ifup vmbr0
systemctl restart pveproxy spiceproxy 2>/dev/null || true

echo "=== VERIFICA ==="
ip route show default
ss -tlnp | grep -E '8006|3128' 2>/dev/null || echo "(nessun Proxmox)"
cat /etc/resolv.conf
[ -n "$WIFI_IP" ] && echo "Accesso LAN: https://$LAN_IP:8006"
[ -n "$WIFI_IP" ] && echo "Accesso WiFi: https://$WIFI_IP:8006"
