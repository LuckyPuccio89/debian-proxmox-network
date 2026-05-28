FROM lscr.io/linuxserver/webtop:ubuntu-kde

RUN \
  echo "**** Remove dockremap user (conflicting UID) ****" && \
  userdel -r dockremap 2>/dev/null; \
  groupdel dockremap 2>/dev/null; \
  echo "**** Rename abc user to Stefano ****" && \
  usermod -l Stefano abc && \
  usermod -d /home/Stefano -m Stefano && \
  echo "**** Set primary group to root ****" && \
  usermod -g 0 Stefano && \
  echo "**** Create Stefano group (needed by patched s6 scripts that chown Stefano:Stefano) ****" && \
  groupadd -f Stefano && \
  echo "**** Patch s6 scripts: replace abc with Stefano ****" && \
  find /etc/s6-overlay/ -type f -exec sed -i 's/\babc\b/Stefano/g' {} + && \
  echo "**** Fix chown group references from Stefano:Stefano to Stefano:root in s6 scripts ****" && \
  find /etc/s6-overlay/ -type f -exec sed -i 's/:Stefano\b/:root/g' {} + && \
  echo "**** Install flatpak ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    flatpak \
    flatpak-builder \
    xdg-desktop-portal \
    xdg-desktop-portal-kde && \
  echo "**** Add flathub remote ****" && \
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
  echo "**** Cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

ENV USER=Stefano
