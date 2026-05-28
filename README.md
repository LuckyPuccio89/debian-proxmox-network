# Debian Proxmox Network Config

Configurazione di rete per Proxmox su Debian 13 (Trixie) con KDE.

## Struttura

```
setup-rete.sh          Script principale configurazione rete
lxc/                   Configurazioni container LXC
  └─ 100.conf          Container Grafica-3d (GPU pass-through)
docker/                Docker compose stacks
  ├─ webtop-kde/       Webtop KDE desktop via browser
  └─ webtop-stack/     Webtop app stack (OrcaSlicer, FreeCAD)
```

## Cosa fa setup-rete.sh

- Proxmox (pveproxy/spiceproxy) bindato solo su IP LAN
- Routing senza metrica (usa entrambe le interfacce)
- DNS statico (8.8.8.8, 1.1.1.1) immutabile
- Preferenza IPv4 (gai.conf)
- socat relay: WiFi -> Proxmox LAN (porta 8006)
- NetworkManager: DNS non gestito

## Accesso Proxmox

| Via | URL |
|-----|-----|
| LAN | https://192.168.1.40:8006 |
| WiFi | https://192.168.68.54:8006 |
