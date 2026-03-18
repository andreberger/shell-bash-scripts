#!/bin/bash

# ============================================================================
# Script de Pós-Instalação - openSUSE Tumbleweed
# ============================================================================
# Autor: André Kroetz Berger
# E-mail: andre@andre.poa.br
# Site: andre.poa.br
# Data: 18/03/2026
# Descrição: Script completo de pós-instalação para openSUSE Tumbleweed
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

print_message "Atualizando todos os pacotes do sistema..."
zypper refresh
zypper update -y
zypper dup -y

# ============================================================================
# 2. CONFIGURAR IDIOMA PARA PORTUGUÊS-BR
# ============================================================================

print_section "2. CONFIGURANDO IDIOMA PARA PORTUGUÊS-BR"

print_message "Instalando pacotes de idioma português..."
zypper install -y glibc-locale glibc-i18ndata

print_message "Configurando locale para pt_BR.UTF-8..."
localectl set-locale LANG=pt_BR.UTF-8
localectl set-keymap br-abnt2
localectl set-x11-keymap br abnt2

# ============================================================================
# 3. INSTALAR MATE DESKTOP COM COMPIZ
# ============================================================================

print_section "3. INSTALANDO MATE DESKTOP E COMPIZ"

print_message "Instalando MATE Desktop Environment..."
zypper install -y -t pattern mate mate_basis
zypper install -y mate-desktop

print_message "Instalando Compiz e plugins..."
zypper install -y compiz compiz-plugins-main compiz-plugins-extra
zypper install -y compizconfig-settings-manager emerald emerald-themes
zypper install -y fusion-icon

# ============================================================================
# 4. ADICIONAR REPOSITÓRIOS
# ============================================================================

print_section "4. CONFIGURANDO REPOSITÓRIOS"

print_message "Adicionando repositório Packman (codecs multimídia)..."
zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
zypper refresh

print_message "Configurando Flathub (Flatpak)..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ============================================================================
# 5. CODECS MULTIMÍDIA
# ============================================================================

print_section "5. INSTALANDO CODECS MULTIMÍDIA"

print_message "Instalando codecs de áudio e vídeo..."
zypper install -y --from packman ffmpeg gstreamer-plugins-{good,bad,ugly,libav}
zypper install -y --from packman vlc-codecs
zypper install -y x264 x265 lame
zypper install -y gstreamer-plugins-base gstreamer-plugins-good
zypper install -y libavcodec-full

print_message "Mudando para versões Packman de pacotes multimídia..."
zypper dup -y --from packman --allow-vendor-change

# ============================================================================
# 6. SUPORTE A DVDS CRIPTOGRAFADOS
# ============================================================================

print_section "6. INSTALANDO SUPORTE A DVDS CRIPTOGRAFADOS"

print_message "Instalando libdvdcss..."
zypper install -y libdvdcss2

# ============================================================================
# 7. FERRAMENTAS DE COMPRESSÃO
# ============================================================================

print_section "7. INSTALANDO FERRAMENTAS DE COMPRESSÃO"

print_message "Instalando 7zip e suporte a ZIP..."
zypper install -y p7zip p7zip-full unzip zip unrar

# ============================================================================
# 8. JAVA
# ============================================================================

print_section "8. INSTALANDO JAVA"

print_message "Instalando OpenJDK (Java Development Kit)..."
zypper install -y java-21-openjdk java-21-openjdk-devel
zypper install -y java-17-openjdk java-17-openjdk-devel
zypper install -y java-11-openjdk java-11-openjdk-devel

# ============================================================================
# 9. SOFTWARES GERAIS
# ============================================================================

print_section "9. INSTALANDO SOFTWARES GERAIS"

print_message "Instalando PuTTY..."
zypper install -y putty

print_message "Instalando Vim..."
zypper install -y vim vim-data

print_message "Instalando HTOP..."
zypper install -y htop

print_message "Instalando Glances..."
zypper install -y glances

print_message "Instalando VLC..."
zypper install -y vlc

print_message "Instalando Google Chrome..."
zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
rpm --import https://dl.google.com/linux/linux_signing_key.pub
zypper refresh
zypper install -y google-chrome-stable

print_message "Instalando TeamViewer..."
wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm -O /tmp/teamviewer.rpm
zypper install -y /tmp/teamviewer.rpm

print_message "Instalando AnyDesk..."
cat << EOF > /etc/zypp/repos.d/anydesk.repo
[anydesk]
name=AnyDesk openSUSE
baseurl=http://rpm.anydesk.com/suse/x86_64/
gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
enabled=1
EOF
zypper refresh
zypper install -y anydesk

print_message "Instalando Dropbox..."
zypper install -y nautilus-dropbox

print_message "Instalando VirtualBox..."
zypper install -y virtualbox virtualbox-qt virtualbox-guest-tools
usermod -a -G vboxusers $SUDO_USER

print_message "Instalando Spotify..."
flatpak install -y flathub com.spotify.Client

print_message "Instalando HandBrake..."
zypper install -y handbrake handbrake-cli

print_message "Instalando GIMP..."
zypper install -y gimp

print_message "Instalando Inkscape..."
zypper install -y inkscape

print_message "Instalando fontes da Microsoft..."
zypper install -y fetchmsttfonts

print_message "Instalando Telegram Desktop..."
zypper install -y telegram-desktop

print_message "Instalando Warehouse..."
flatpak install -y flathub io.github.flattool.Warehouse

print_message "Instalando suporte para impressoras HP..."
zypper install -y hplip hplip-hpijs

# ============================================================================
# 10. AMBIENTE DE DESENVOLVIMENTO
# ============================================================================

print_section "10. INSTALANDO AMBIENTE DE DESENVOLVIMENTO"

print_message "Instalando Code::Blocks com GCC..."
zypper install -y -t pattern devel_basis devel_C_C++
zypper install -y gcc gcc-c++ make cmake
zypper install -y codeblocks codeblocks-contrib

print_message "Instalando Python e pip..."
zypper install -y python3 python3-pip python3-devel
pip3 install --upgrade pip

print_message "Instalando pacotes Python específicos..."
pip3 install pyopengl
pip3 install pyopengl-accelerate

print_message "Instalando Git..."
zypper install -y git git-gui gitk

print_message "Instalando VS Code..."
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat << EOF > /etc/zypp/repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
zypper refresh
zypper install -y code

print_message "Instalando Eclipse IDE..."
zypper install -y eclipse

print_message "Instalando MySQL Workbench..."
zypper install -y mysql-workbench

print_message "Instalando GitHub Desktop..."
wget https://github.com/shiftkey/desktop/releases/download/release-3.3.12-linux1/GitHubDesktop-linux-amd64-3.3.12-linux1.rpm -O /tmp/github-desktop.rpm
zypper install -y /tmp/github-desktop.rpm

print_message "Instalando Apache NetBeans..."
flatpak install -y flathub org.apache.netbeans

print_message "Instalando Umbrello..."
zypper install -y umbrello

print_message "Instalando DIA..."
zypper install -y dia

print_message "Instalando PyCharm Community Edition..."
flatpak install -y flathub com.jetbrains.PyCharm-Community

print_message "Instalando GVim..."
zypper install -y vim-data gvim

# ============================================================================
# 11. GAMES
# ============================================================================

print_section "11. INSTALANDO GAMES"

print_message "Instalando Flycast (Emulador de SEGA Dreamcast)..."
flatpak install -y flathub org.flycast.Flycast

print_message "Instalando Snes9x (Emulador de Super Nintendo)..."
zypper install -y snes9x

print_message "Instalando Extreme Tux Racer..."
zypper install -y extremetuxracer

print_message "Instalando SuperTuxKart..."
zypper install -y supertuxkart

# ============================================================================
# 12. SERVIDOR (LAMP STACK + MONGODB)
# ============================================================================

print_section "12. INSTALANDO SERVIDOR LAMP + MONGODB"

print_message "Instalando Apache..."
zypper install -y apache2
systemctl enable apache2
systemctl start apache2

print_message "Instalando PHP..."
zypper install -y php8 php8-mysql php8-gd php8-mbstring php8-curl php8-json php8-zip apache2-mod_php8
systemctl restart apache2

print_message "Instalando MariaDB (MySQL)..."
zypper install -y mariadb mariadb-client mariadb-tools
systemctl enable mariadb
systemctl start mariadb

print_message "Instalando phpMyAdmin..."
zypper install -y phpMyAdmin
cat << EOF > /etc/apache2/conf.d/phpMyAdmin.conf
Alias /phpmyadmin /srv/www/htdocs/phpMyAdmin
<Directory /srv/www/htdocs/phpMyAdmin/>
   DirectoryIndex index.php
   AllowOverride All
   Require all granted
</Directory>
EOF
systemctl restart apache2

print_message "Instalando MongoDB..."
cat << EOF > /etc/zypp/repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/zypper/suse/15/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF
zypper refresh
zypper install -y mongodb-org
systemctl enable mongod
systemctl start mongod

# ============================================================================
# 13. CONFIGURAÇÕES FINAIS
# ============================================================================

print_section "13. CONFIGURAÇÕES FINAIS"

print_message "Configurando firewall para serviços web..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

print_message "Limpando cache de pacotes..."
zypper clean -a

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
print_message "Script de pós-instalação do openSUSE Tumbleweed concluído com sucesso!"
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
