# Debian Proxmox Network Config

Configurazione di rete per Proxmox su Debian 13 (Trixie) con KDE.

## Struttura

```
├── notebook/
│   └── setup.sh                      # Setup rete notebook (questo PC)
├── desktop5800x/
│   └── setup.sh                      # Template configurabile per Ryzen 5800X
├── lxc/
│   └── 100.conf                      # Container Grafica-3d (GPU pass-through)
├── docker/
│   ├── webtop-kde/                   # KDE desktop via browser
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   ├── BUILD.md
│   │   └── create_stack.py
│   └── webtop-stack/                 # OrcaSlicer + FreeCAD containers
│       ├── Dockerfile
│       └── docker-compose.yml
├── webtop-kde/                       # (alias/stessa config di docker/webtop-kde)
│   └── ...
├── webtop-stack/                     # (alias/stessa config di docker/webtop-stack)
│   └── ...
├── etc-config/                       # Copia dei file di sistema modificati
│   ├── network-interfaces
│   ├── default-pveproxy
│   ├── NetworkManager.conf
│   ├── gai.conf
│   └── socat-pveproxy.service
└── README.md
```

## Cosa fa notebook/setup.sh

- Proxmox (pveproxy/spiceproxy) bindato solo su IP LAN
- Routing senza metrica (usa entrambe le interfacce)
- DNS statico (8.8.8.8, 1.1.1.1) immutabile
- Preferenza IPv4 (gai.conf)
- socat relay: WiFi -> Proxmox LAN (porta 8006)

## Accesso Proxmox (notebook)

| Via | URL |
|-----|-----|
| LAN | https://192.168.1.40:8006 |
| WiFi | https://192.168.68.54:8006 (tramite socat) |
