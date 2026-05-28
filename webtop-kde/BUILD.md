# Build & Deploy webtop KDE con Flatpak

## Metodo 1: Portainer Stack

1. Accedi a https://192.168.1.39:9443
2. Vai su **Stacks** → **Add stack**
3. Nome: `webtop-kde`
4. Build method: **Dockerfile**
5. Carica i file:
   - `docker-compose.yml`
   - `Dockerfile`
6. Deploy lo stack

## Metodo 2: Docker CLI sulla macchina host

```bash
cd /root/webtop-kde

# Build immagine
docker build -t webtop-kde:latest .

# Esegui container
docker run -d \
  --name=webtop-kde \
  -e PUID=1000 \
  -e PGID=0 \
  -e TZ=Europe/Rome \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /home/Stefano/webtop-config:/config \
  --shm-size=2gb \
  --security-opt seccomp=unconfined \
  --device /dev/dri:/dev/dri \
  --restart unless-stopped \
  webtop-kde:latest
```

## Parametri

| Parametro | Valore | Note |
|-----------|--------|------|
| PUID | 1000 | Utente Stefano |
| PGID | 0 | Gruppo root |
| TZ | Europe/Rome | Fuso orario |
| shm_size | 2gb | Memoria condivisa per KDE |
| seccomp | unconfined | Necessario per app GUI moderne |
