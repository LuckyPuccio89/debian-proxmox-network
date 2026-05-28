#!/bin/bash
# Script di configurazione rete - Proxmox solo su LAN, internet via WiFi/LAN
# Eseguire come root

set -e

echo "[*] Configurazione /etc/network/interfaces (vmbr0 su LAN, senza metrica)"
cat > /etc/network/interfaces << 'EOF'
auto lo
iface lo inet loopback

iface nic0 inet manual

auto vmbr0
iface vmbr0 inet static
	address 192.168.1.40/24
	gateway 192.168.1.1
	bridge-ports nic0
	bridge-stp off
	bridge-fd 0

#iface wlan0 inet manual

source /etc/network/interfaces.d/*
EOF

echo "[*] Configurazione /etc/default/pveproxy (Proxmox solo su LAN IP)"
mkdir -p /etc/default
cat > /etc/default/pveproxy << 'EOF'
LISTEN_IP="192.168.1.40"
EOF

echo "[*] Configurazione NetworkManager (no dns=none, default)"
cat > /etc/NetworkManager/NetworkManager.conf << 'EOF'
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=false
EOF

echo "[*] Configurazione /etc/resolv.conf statico + immutabile"
chattr -i /etc/resolv.conf 2>/dev/null || true
cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
chattr +i /etc/resolv.conf

echo "[*] Configurazione /etc/gai.conf (preferisci IPv4)"
cat > /etc/gai.conf << 'EOF'
# Configuration for getaddrinfo(3).
# For sites which prefer IPv4 connections:
precedence ::ffff:0:0/96  100
EOF

echo "[*] Creazione servizio systemd socat relay (WiFi -> Proxmox LAN)"
cat > /etc/systemd/system/socat-pveproxy.service << 'EOF'
[Unit]
Description=socat relay: WiFi -> Proxmox LAN
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP-LISTEN:8006,bind=192.168.68.54,fork,reuseaddr TCP:192.168.1.40:8006
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Imposta WiFi (Casa_Pucci) senza metrica"
nmcli connection modify Casa_Pucci ipv4.route-metric 0 2>/dev/null || echo "[!] Connessione WiFi 'Casa_Pucci' non trovata, salta"

echo "[*] Ricarica systemd e abilita servizi"
systemctl daemon-reload
systemctl enable --now socat-pveproxy 2>/dev/null || systemctl restart socat-pveproxy
systemctl restart NetworkManager

echo "[*] Riavvio interfaccia di rete vmbr0"
ifdown vmbr0 2>/dev/null; ifup vmbr0

echo "[*] Riavvio servizi Proxmox"
systemctl restart pveproxy spiceproxy

echo ""
echo "=== VERIFICA ==="
echo "Routing:"
ip route show default
echo ""
echo "Proxmox services:"
ss -tlnp | grep -E '8006|3128'
echo ""
echo "DNS:"
cat /etc/resolv.conf
echo ""
echo "Fatto. Proxmox accessibile su:"
echo "  LAN:  https://192.168.1.40:8006"
echo "  WiFi: https://192.168.68.54:8006 (tramite socat)"
