 #!/bin/bash

# Script de Pós-Instalação Ubuntu 24.04 LTS
# Autor: Sistema de Automação
# Data: $(date)
# Versão: 1.0

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Função para verificar se o comando foi executado com sucesso
check_status() {
    if [ $? -eq 0 ]; then
        log "✓ $1 - Concluído com sucesso"
    else
        error "✗ $1 - Falhou"
        return 1
    fi
}

# Função para pausar entre instalações
pause_execution() {
    sleep 2
}

# Banner inicial
clear
echo -e "${BLUE}"
echo "═══════════════════════════════════════════════════════════════"
echo "  SCRIPT DE PÓS-INSTALAÇÃO UBUNTU 24.04 LTS"
echo "═══════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""

info "Iniciando configuração pós-instalação do Ubuntu 24.04 LTS..."
echo ""

# ═══════════════════════════════════════════════════════════════
# ATUALIZAÇÕES INICIAIS DO SISTEMA
# ═══════════════════════════════════════════════════════════════

log "Iniciando atualizações do sistema..."
sudo apt update && sudo apt upgrade -y
check_status "Atualização inicial do sistema"
pause_execution

# ═══════════════════════════════════════════════════════════════
# INSTALAÇÃO DE FERRAMENTAS BÁSICAS
# ═══════════════════════════════════════════════════════════════

log "Instalando ferramentas básicas do sistema..."

# APT URL
sudo apt install -y apturl apturl-common
check_status "Instalação APT URL"

# GNOME Software
sudo apt install -y gnome-software
check_status "Instalação GNOME Software"

# GNOME Tweaks
sudo apt install -y gnome-tweaks
check_status "Instalação GNOME Tweaks"

# Curl
sudo apt install -y curl
check_status "Instalação Curl"

pause_execution

# ═══════════════════════════════════════════════════════════════
# CONFIGURAÇÕES DO GNOME
# ═══════════════════════════════════════════════════════════════

log "Configurando GNOME Shell Extensions..."

# Configurar dash-to-dock para minimizar
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
check_status "Configuração dash-to-dock"

pause_execution

# ═══════════════════════════════════════════════════════════════
# CONFIGURAÇÃO DE SWAPPINESS
# ═══════════════════════════════════════════════════════════════

log "Configurando swappiness do sistema..."

# Backup do arquivo original
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak

# Adicionar configuração de swappiness
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null
check_status "Configuração da swappiness"

pause_execution

# ═══════════════════════════════════════════════════════════════
# GERENCIAMENTO DE ENERGIA (TLP)
# ═══════════════════════════════════════════════════════════════

log "Instalando e configurando TLP para gerenciamento de energia..."

sudo apt install -y tlp tlp-rdw
check_status "Instalação TLP"

sudo systemctl enable tlp.service
sudo tlp start
check_status "Configuração e inicialização TLP"

pause_execution

# ═══════════════════════════════════════════════════════════════
# CONFIGURAÇÃO FLATPAK
# ═══════════════════════════════════════════════════════════════

log "Configurando Flatpak e repositório Flathub..."

sudo apt install -y flatpak
check_status "Instalação Flatpak"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_status "Adição repositório Flathub"

sudo apt install -y gnome-software-plugin-flatpak
check_status "Plugin Flatpak para GNOME Software"

pause_execution

# ═══════════════════════════════════════════════════════════════
# CODECS E MULTIMÍDIA
# ═══════════════════════════════════════════════════════════════

log "Instalando codecs e ferramentas multimídia..."

sudo apt install -y ubuntu-restricted-extras
check_status "Ubuntu Restricted Extras"

sudo apt install -y libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg
check_status "Configuração libdvd-pkg"

# Players de mídia
sudo apt install -y vlc smplayer
check_status "Instalação VLC e SMPlayer"

pause_execution

# ═══════════════════════════════════════════════════════════════
# APLICATIVOS MULTIMÍDIA E PRODUTIVIDADE
# ═══════════════════════════════════════════════════════════════

log "Instalando aplicativos de produtividade e multimídia..."

# Snap packages
sudo snap install spotify
check_status "Instalação Spotify"

snap install telegram-desktop
check_status "Instalação Telegram"

# Aplicativos de edição
sudo apt install -y audacity blender gimp handbrake inkscape obs-studio openshot-qt
check_status "Ferramentas de edição multimídia"

# Email
sudo apt install -y thunderbird thunderbird-l10n-pt-br
check_status "Instalação Thunderbird"

pause_execution

# ═══════════════════════════════════════════════════════════════
# NAVEGADOR GOOGLE CHROME
# ═══════════════════════════════════════════════════════════════

log "Instalando Google Chrome..."

cd /tmp
wget -O google-chrome-stable.deb 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
sudo apt install -y ./google-chrome-stable.deb
cd $HOME
check_status "Instalação Google Chrome"

pause_execution

# ═══════════════════════════════════════════════════════════════
# AMBIENTE JAVA (JRE E JDK)
# ═══════════════════════════════════════════════════════════════

log "Instalando ambiente Java completo..."

# Java Runtime Environments
sudo apt install -y openjdk-8-jre openjdk-11-jre openjdk-17-jre openjdk-21-jre default-jre
check_status "Instalação Java Runtime Environments"

# Java Development Kits
sudo apt install -y openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk openjdk-21-jdk default-jdk
check_status "Instalação Java Development Kits"

pause_execution

# ═══════════════════════════════════════════════════════════════
# VISUAL STUDIO CODE
# ═══════════════════════════════════════════════════════════════

log "Instalando Visual Studio Code..."

# Importar chave GPG da Microsoft
cd /tmp
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
cd $HOME
check_status "Importação chave GPG Microsoft"

# Adicionar repositório VS Code
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
check_status "Adição repositório VS Code"

# Atualizar e instalar
sudo apt update
sudo apt install -y code
check_status "Instalação Visual Studio Code"

pause_execution

# ═══════════════════════════════════════════════════════════════
# VIRTUALIZAÇÃO
# ═══════════════════════════════════════════════════════════════

log "Instalando ferramentas de virtualização..."

# VirtualBox
sudo apt install -y virtualbox
sudo usermod -a -G vboxusers $USER
check_status "Instalação VirtualBox"

# Virtual Machine Manager
sudo apt install -y virt-manager
check_status "Instalação Virtual Machine Manager"

pause_execution

# ═══════════════════════════════════════════════════════════════
# SERVIÇOS DE NUVEM
# ═══════════════════════════════════════════════════════════════

log "Instalando clientes de serviços de nuvem..."

# Dropbox
cd /tmp
wget -O dropbox.deb 'https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2024.04.17_amd64.deb'
sudo apt install -y ./dropbox.deb python3-gpg
cd $HOME
check_status "Instalação Dropbox"

# MEGA Sync
cd /tmp
wget -O megasync.deb 'https://mega.nz/linux/repo/xUbuntu_24.04/amd64/megasync-xUbuntu_24.04_amd64.deb'
sudo apt install -y ./megasync.deb
cd $HOME
check_status "Instalação MEGA Sync"

pause_execution

# ═══════════════════════════════════════════════════════════════
# TORRENTS E FERRAMENTAS DE SISTEMA
# ═══════════════════════════════════════════════════════════════

log "Instalando ferramentas adicionais do sistema..."

# Cliente torrent
sudo apt install -y qbittorrent
check_status "Instalação qBittorrent"

# Ferramentas de monitoramento
sudo apt install -y vim glances htop
check_status "Ferramentas de monitoramento e edição"

# Synaptic Package Manager
sudo apt install -y synaptic
check_status "Instalação Synaptic"

pause_execution

# ═══════════════════════════════════════════════════════════════
# ACESSO REMOTO
# ═══════════════════════════════════════════════════════════════

log "Instalando ferramentas de acesso remoto..."

# AnyDesk
cd /tmp
wget -qO- https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/anydesk.gpg
cd $HOME
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
sudo apt update
sudo apt install -y anydesk
check_status "Instalação AnyDesk"

# TeamViewer
cd /tmp
wget -qO- https://linux.teamviewer.com/pubkey/currentkey.asc | gpg --dearmor > teamviewer-keyring.gpg
sudo install -o root -g root -m 644 teamviewer-keyring.gpg /usr/share/keyrings/
wget -c https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo apt install -y ./teamviewer*.deb
cd $HOME
check_status "Instalação TeamViewer"

pause_execution

# ═══════════════════════════════════════════════════════════════
# ATUALIZAÇÃO FINAL E LIMPEZA
# ═══════════════════════════════════════════════════════════════

log "Realizando atualização final e limpeza do sistema..."

sudo apt update && sudo apt upgrade -y
check_status "Atualização final do sistema"

sudo apt autoremove -y
sudo apt autoclean
check_status "Limpeza do sistema"

# ═══════════════════════════════════════════════════════════════
# FINALIZAÇÃO
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  INSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

info "Resumo da instalação:"
echo "✓ Sistema atualizado"
echo "✓ Ferramentas básicas instaladas"
echo "✓ GNOME configurado"
echo "✓ Swappiness otimizada (vm.swappiness=10)"
echo "✓ TLP configurado para economia de energia"
echo "✓ Flatpak e Flathub configurados"
echo "✓ Codecs multimídia instalados"
echo "✓ Aplicativos de produtividade instalados"
echo "✓ Google Chrome instalado"
echo "✓ Ambiente Java completo (JRE e JDK)"
echo "✓ Visual Studio Code instalado"
echo "✓ Ferramentas de virtualização instaladas"
echo "✓ Clientes de nuvem instalados"
echo "✓ Ferramentas de sistema instaladas"
echo "✓ Software de acesso remoto instalado"
echo ""

warning "IMPORTANTE:"
echo "• É recomendado reiniciar o sistema para aplicar todas as configurações"
echo "• Para utilizar o VirtualBox, faça logout e login novamente"
echo "• Configure suas contas nos aplicativos instalados (Dropbox, MEGA, etc.)"
echo "• A configuração de swappiness será aplicada na próxima inicialização"
echo ""

info "Para reiniciar o sistema agora, execute: sudo reboot"
echo ""

log "Script de pós-instalação finalizado!"

# Opcional: prompt para reinicialização
read -p "Deseja reiniciar o sistema agora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    log "Reiniciando o sistema..."
    sudo reboot
else
    info "Lembre-se de reiniciar o sistema posteriormente para aplicar todas as configurações."
fi