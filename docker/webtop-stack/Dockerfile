ARG APP=none

FROM lscr.io/linuxserver/webtop:ubuntu-kde

ARG APP

RUN \
  echo "**** Remove dockremap user (conflicting UID) ****" && \
  userdel -r dockremap 2>/dev/null; \
  groupdel dockremap 2>/dev/null; \
  echo "**** Rename abc user to Stefano ****" && \
  usermod -l Stefano abc && \
  usermod -d /home/Stefano -m Stefano && \
  echo "**** Set primary group to root ****" && \
  usermod -g 0 Stefano && \
  echo "**** Create Stefano group (needed by patched s6 scripts) ****" && \
  groupadd -f Stefano && \
  echo "**** Patch s6 scripts: replace abc with Stefano ****" && \
  find /etc/s6-overlay/ -type f -exec sed -i 's/\babc\b/Stefano/g' {} + && \
  echo "**** Fix chown group references in s6 scripts ****" && \
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
  echo "**** Install APP: ${APP} ****" && \
  if [ "$APP" = "orcaslicer" ]; then \
    flatpak install -y --noninteractive flathub com.orcaslicer.OrcaSlicer; \
  elif [ "$APP" = "freecad" ]; then \
    flatpak install -y --noninteractive flathub org.freecad.FreeCAD; \
  fi && \
  echo "**** Cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

ENV USER=Stefano
