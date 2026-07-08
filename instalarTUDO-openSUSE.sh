#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script como root (usando sudo)."
  exit 1
fi

echo "=========================================="
echo "1. ATUALIZANDO O SISTEMA (100% AUTOMÁTICO)"
echo "=========================================="
# No Tumbleweed, a atualização do sistema é feita via 'dup' (distribution upgrade)
zypper --non-interactive dup

echo "=========================================="
echo "2. INSTALANDO AMBIENTE DESKTOP: CINNAMON"
echo "=========================================="
zypper --non-interactive install -t pattern cinnamon

echo "=========================================="
echo "3. INSTALANDO APLICATIVOS (ZYPPER / NORMAL)"
echo "=========================================="
zypper --non-interactive install \
    gvim \
    glances \
    htop \
    links \
    virtualbox \
    eclipse \
    gimp \
    mysql-workbench \
    phpMyAdmin \
    rpi-imager

echo "=========================================="
echo "4. CONFIGURANDO FLATPAK E FLATHUB"
echo "=========================================="
zypper --non-interactive install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "=========================================="
echo "5. INSTALANDO APLICATIVOS (FLATPAK)"
echo "=========================================="

# Lista de IDs do Flathub baseada na sua lista
FLATPAKS=(
    com.spotify.Client
    org.telegram.desktop
    cc.arduino.IDE2
    io.dbeaver.DBeaverCommunity
    com.visualstudio.code
    org.kde.umbrello
    io.github.shiftey.Desktop
    org.codeblocks.codeblocks
    com.google.Chrome
    uk.org.greenend.chiark.sgtatham.putty
    com.anydesk.Anydesk
    com.google.EarthPro
    com.parsecgaming.parsec
    org.remmina.Remmina
    org.filezillaproject.Filezilla
    org.qbittorrent.qBittorrent
    org.wireshark.Wireshark
    com.hoptodesk.HopToDesk
    org.videolan.VLC
    org.fedoraproject.MediaWriter
    org.inkscape.Inkscape
    fr.handbrake.ghb
    com.google.AndroidStudio
    org.apache.netbeans
    com.sweethome3d.Sweethome3d
    com.jgraph.drawio.desktop
    net.supertuxkart.SuperTuxKart
    com.snes9x.Snes9x
    org.phoenicis.playonlinux
    com.dropbox.Client
    org.supertuxproject.SuperTux
)

# Instalando todos os flatpaks da lista de forma automática e confirmando com '-y'
for app in "${FLATPAKS[@]}"; do
    echo "Instalando via Flatpak: $app..."
    flatpak install flathub "$app" -y
done

echo "=========================================="
echo "INSTALAÇÃO CONCLUÍDA!"
echo "Recomenda-se reiniciar o computador para aplicar as atualizações e poder selecionar o Cinnamon Desktop na tela de login."
echo "=========================================="

# NOTAS DE APLICATIVOS NÃO ENCONTRADOS OU AMBÍGUOS NO FLATHUB:
# - Visu, OpenCode, Filius, Reminduck, Fred TV: Não possuem correspondência exata no Flathub.
# - Adobe Reader: O suporte nativo para Linux foi descontinuado há anos. Recomenda-se usar o Evince ou Okular.
# - ZSNES: Projeto descontinuado; o script instalou o Snes9x no lugar (que é mais atual e seguro).
# - Impressão / Gráficos: São categorias de sistema, não pacotes específicos.