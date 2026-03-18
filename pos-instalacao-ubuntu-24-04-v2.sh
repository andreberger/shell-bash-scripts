#!/bin/bash

# ============================================================================
# Script de Pós-Instalação - Ubuntu 24.04 LTS (Noble Numbat)
# ============================================================================
# Autor: André Kroetz Berger
# E-mail: andre@andre.poa.br
# Site: andre.poa.br
# Data: 18/03/2026
# Descrição: Script completo de pós-instalação para Ubuntu 24.04 LTS
# ============================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_section() {
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
    echo ""
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    print_error "Por favor, execute como root (sudo)"
    exit 1
fi

# ============================================================================
# 1. ATUALIZAÇÃO DO SISTEMA
# ============================================================================

print_section "1. ATUALIZANDO O SISTEMA"

print_message "Atualizando lista de pacotes..."
apt update

print_message "Atualizando todos os pacotes do sistema..."
apt upgrade -y
apt dist-upgrade -y

# ============================================================================
# 2. CONFIGURAR IDIOMA PARA PORTUGUÊS-BR
# ============================================================================

print_section "2. CONFIGURANDO IDIOMA PARA PORTUGUÊS-BR"

print_message "Instalando pacotes de idioma português..."
apt install -y language-pack-pt language-pack-gnome-pt
apt install -y language-pack-pt-base

print_message "Configurando locale para pt_BR.UTF-8..."
update-locale LANG=pt_BR.UTF-8
localectl set-locale LANG=pt_BR.UTF-8
localectl set-keymap br-abnt2
localectl set-x11-keymap br abnt2

# ============================================================================
# 3. INSTALAR MATE DESKTOP COM COMPIZ
# ============================================================================

print_section "3. INSTALANDO MATE DESKTOP E COMPIZ"

print_message "Instalando MATE Desktop Environment..."
apt install -y mate-desktop-environment mate-desktop-environment-extras
apt install -y ubuntu-mate-desktop

print_message "Instalando Compiz e plugins..."
apt install -y compiz compiz-plugins compiz-plugins-extra
apt install -y compizconfig-settings-manager emerald emerald-themes
apt install -y fusion-icon

# ============================================================================
# 4. ADICIONAR REPOSITÓRIOS
# ============================================================================

print_section "4. CONFIGURANDO REPOSITÓRIOS"

print_message "Habilitando repositórios Universe e Multiverse..."
add-apt-repository -y universe
add-apt-repository -y multiverse
apt update

print_message "Configurando Flathub (Flatpak)..."
apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ============================================================================
# 5. CODECS MULTIMÍDIA
# ============================================================================

print_section "5. INSTALANDO CODECS MULTIMÍDIA"

print_message "Instalando codecs de áudio e vídeo..."
apt install -y ubuntu-restricted-extras
apt install -y ffmpeg
apt install -y gstreamer1.0-plugins-base gstreamer1.0-plugins-good
apt install -y gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
apt install -y gstreamer1.0-libav gstreamer1.0-tools
apt install -y libavcodec-extra libdvd-pkg
apt install -y x264 x265 lame

# ============================================================================
# 6. SUPORTE A DVDS CRIPTOGRAFADOS
# ============================================================================

print_section "6. INSTALANDO SUPORTE A DVDS CRIPTOGRAFADOS"

print_message "Instalando libdvdcss..."
dpkg-reconfigure -f noninteractive libdvd-pkg

# ============================================================================
# 7. FERRAMENTAS DE COMPRESSÃO
# ============================================================================

print_section "7. INSTALANDO FERRAMENTAS DE COMPRESSÃO"

print_message "Instalando 7zip e suporte a ZIP..."
apt install -y p7zip-full p7zip-rar unzip zip unrar

# ============================================================================
# 8. JAVA
# ============================================================================

print_section "8. INSTALANDO JAVA"

print_message "Instalando OpenJDK (Java Development Kit)..."
apt install -y default-jdk default-jre
apt install -y openjdk-17-jdk openjdk-17-jre
apt install -y openjdk-21-jdk openjdk-21-jre

# ============================================================================
# 9. SOFTWARES GERAIS
# ============================================================================

print_section "9. INSTALANDO SOFTWARES GERAIS"

print_message "Instalando PuTTY..."
apt install -y putty

print_message "Instalando Vim..."
apt install -y vim vim-gtk3

print_message "Instalando HTOP..."
apt install -y htop

print_message "Instalando Glances..."
apt install -y glances

print_message "Instalando VLC..."
apt install -y vlc

print_message "Instalando Google Chrome..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt update
apt install -y google-chrome-stable

print_message "Instalando TeamViewer..."
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O /tmp/teamviewer.deb
apt install -y /tmp/teamviewer.deb

print_message "Instalando AnyDesk..."
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
apt update
apt install -y anydesk

print_message "Instalando Dropbox..."
apt install -y nautilus-dropbox

print_message "Instalando VirtualBox..."
apt install -y virtualbox virtualbox-ext-pack virtualbox-guest-additions-iso
usermod -a -G vboxusers $SUDO_USER

print_message "Instalando Spotify..."
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | gpg --dearmor | tee /usr/share/keyrings/spotify-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
apt update
apt install -y spotify-client

print_message "Instalando HandBrake..."
apt install -y handbrake

print_message "Instalando GIMP..."
apt install -y gimp

print_message "Instalando Inkscape..."
apt install -y inkscape

print_message "Instalando fontes da Microsoft..."
apt install -y ttf-mscorefonts-installer

print_message "Instalando Telegram Desktop..."
apt install -y telegram-desktop

print_message "Instalando Warehouse..."
flatpak install -y flathub io.github.flattool.Warehouse

print_message "Instalando suporte para impressoras HP..."
apt install -y hplip hplip-gui

# ============================================================================
# 10. AMBIENTE DE DESENVOLVIMENTO
# ============================================================================

print_section "10. INSTALANDO AMBIENTE DE DESENVOLVIMENTO"

print_message "Instalando Code::Blocks com GCC..."
apt install -y build-essential
apt install -y gcc g++ make cmake
apt install -y codeblocks codeblocks-contrib

print_message "Instalando Python e pip..."
apt install -y python3 python3-pip python3-dev python3-venv
pip3 install --upgrade pip --break-system-packages

print_message "Instalando pacotes Python específicos..."
pip3 install pyopengl --break-system-packages
pip3 install pyopengl-accelerate --break-system-packages

print_message "Instalando Git..."
apt install -y git git-gui gitk

print_message "Instalando VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
apt update
apt install -y code

print_message "Instalando Eclipse IDE..."
snap install eclipse --classic

print_message "Instalando MySQL Workbench..."
apt install -y mysql-workbench

print_message "Instalando GitHub Desktop..."
wget https://github.com/shiftkey/desktop/releases/download/release-3.3.12-linux1/GitHubDesktop-linux-amd64-3.3.12-linux1.deb -O /tmp/github-desktop.deb
apt install -y /tmp/github-desktop.deb

print_message "Instalando Apache NetBeans..."
snap install netbeans --classic

print_message "Instalando Umbrello..."
apt install -y umbrello

print_message "Instalando DIA..."
apt install -y dia

print_message "Instalando PyCharm Community Edition..."
snap install pycharm-community --classic

print_message "Instalando GVim..."
apt install -y vim-gtk3

# ============================================================================
# 11. GAMES
# ============================================================================

print_section "11. INSTALANDO GAMES"

print_message "Instalando Flycast (Emulador de SEGA Dreamcast)..."
flatpak install -y flathub org.flycast.Flycast

print_message "Instalando Snes9x (Emulador de Super Nintendo)..."
apt install -y snes9x-gtk

print_message "Instalando Extreme Tux Racer..."
apt install -y extremetuxracer

print_message "Instalando SuperTuxKart..."
apt install -y supertuxkart

# ============================================================================
# 12. SERVIDOR (LAMP STACK + MONGODB)
# ============================================================================

print_section "12. INSTALANDO SERVIDOR LAMP + MONGODB"

print_message "Instalando Apache..."
apt install -y apache2
systemctl enable apache2
systemctl start apache2

print_message "Instalando PHP..."
apt install -y php libapache2-mod-php php-mysql php-cli php-common php-mbstring php-gd php-xml php-curl php-json php-zip
systemctl restart apache2

print_message "Instalando MariaDB (MySQL)..."
apt install -y mariadb-server mariadb-client
systemctl enable mariadb
systemctl start mariadb

print_message "Instalando phpMyAdmin..."
apt install -y phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin 2>/dev/null || true
systemctl restart apache2

print_message "Instalando MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
apt update
apt install -y mongodb-org
systemctl enable mongod
systemctl start mongod

# ============================================================================
# 13. CONFIGURAÇÕES FINAIS
# ============================================================================

print_section "13. CONFIGURAÇÕES FINAIS"

print_message "Configurando firewall para serviços web..."
ufw allow 'Apache Full'
ufw allow 80/tcp
ufw allow 443/tcp

print_message "Limpando cache de pacotes..."
apt autoremove -y
apt autoclean

print_message "Atualizando cache de ícones e aplicativos..."
update-desktop-database

print_message "Criando diretório de projetos..."
mkdir -p /home/$SUDO_USER/Projetos
mkdir -p /home/$SUDO_USER/Documentos
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Projetos
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Documentos

# ============================================================================
# FINALIZAÇÃO
# ============================================================================

print_section "INSTALAÇÃO CONCLUÍDA!"

echo ""
print_message "Script de pós-instalação do Ubuntu 24.04 LTS concluído com sucesso!"
print_message ""
print_message "Algumas observações importantes:"
print_message "  - Para configurar o MySQL/MariaDB, execute: sudo mysql_secure_installation"
print_message "  - O phpMyAdmin está disponível em: http://localhost/phpmyadmin"
print_message "  - Para iniciar o Compiz, use: compiz --replace"
print_message "  - GitHub Desktop foi instalado em /tmp"
print_message ""
print_warning "RECOMENDADO: Reinicie o sistema para aplicar todas as mudanças."
print_message ""
read -p "Deseja reiniciar agora? (s/n): " resposta
if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
    print_message "Reiniciando o sistema..."
    reboot
else
    print_message "Lembre-se de reiniciar o sistema mais tarde!"
fi

exit 0
