#!/bin/bash

# ============================================================================
# Script de Pós-Instalação - Fedora 44
# ============================================================================
# Autor: André Kroetz Berger
# E-mail: andre@andre.poa.br
# Site: andre.poa.br
# Data: 11/04/2026
# Descrição: Script completo de pós-instalação para Fedora 44
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
dnf update -y
dnf upgrade -y

# ============================================================================
# 2. CONFIGURAR IDIOMA PARA PORTUGUÊS-BR
# ============================================================================

print_section "2. CONFIGURANDO IDIOMA PARA PORTUGUÊS-BR"

print_message "Instalando pacotes de idioma português..."
dnf install -y langpacks-pt_BR
dnf install -y glibc-langpack-pt
dnf install -y langpacks-core-pt_BR

print_message "Configurando locale para pt_BR.UTF-8..."
localectl set-locale LANG=pt_BR.UTF-8
localectl set-keymap br-abnt2
localectl set-x11-keymap br abnt2

# ============================================================================
# 3. INSTALAR MATE DESKTOP COM COMPIZ
# ============================================================================

print_section "3. INSTALANDO MATE DESKTOP E COMPIZ"

print_message "Instalando MATE Desktop Environment..."
dnf groupinstall -y "MATE Desktop"
dnf install -y @mate-desktop

print_message "Instalando Compiz e plugins..."
dnf install -y compiz compiz-plugins-extra compiz-plugins-main
dnf install -y compizconfig-python emerald emerald-themes
dnf install -y fusion-icon

# ============================================================================
# 4. ADICIONAR REPOSITÓRIOS RPM FUSION E FLATHUB
# ============================================================================

print_section "4. CONFIGURANDO REPOSITÓRIOS"

print_message "Adicionando RPM Fusion Free..."
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

print_message "Adicionando RPM Fusion Non-free..."
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

print_message "Habilitando RPM Fusion Tainted (Free e Non-free)..."
dnf install -y rpmfusion-free-release-tainted
dnf install -y rpmfusion-nonfree-release-tainted

print_message "Atualizando metadados de cache..."
dnf update -y

print_message "Configurando Flathub (Flatpak)..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ============================================================================
# 5. CODECS MULTIMÍDIA
# ============================================================================

print_section "5. INSTALANDO CODECS MULTIMÍDIA"

print_message "Instalando codecs de áudio e vídeo..."
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
dnf install -y lame\* --exclude=lame-devel
dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf groupupdate -y sound-and-video

print_message "Instalando codecs adicionais..."
dnf install -y ffmpeg ffmpeg-libs
dnf install -y gstreamer1-plugin-libav
dnf install -y gstreamer1-plugins-ugly
dnf install -y x264 x265

# ============================================================================
# 6. SUPORTE A DVDS CRIPTOGRAFADOS
# ============================================================================

print_section "6. INSTALANDO SUPORTE A DVDS CRIPTOGRAFADOS"

print_message "Instalando libdvdcss..."
dnf install -y libdvdcss

# ============================================================================
# 7. FERRAMENTAS DE COMPRESSÃO
# ============================================================================

print_section "7. INSTALANDO FERRAMENTAS DE COMPRESSÃO"

print_message "Instalando 7zip e suporte a ZIP..."
dnf install -y p7zip p7zip-plugins unzip zip unrar

# ============================================================================
# 8. JAVA
# ============================================================================

print_section "8. INSTALANDO JAVA"

print_message "Instalando OpenJDK (Java Development Kit)..."
dnf install -y java-latest-openjdk java-latest-openjdk-devel
dnf install -y java-17-openjdk java-17-openjdk-devel
dnf install -y java-21-openjdk java-21-openjdk-devel

# ============================================================================
# 9. SOFTWARES GERAIS
# ============================================================================

print_section "9. INSTALANDO SOFTWARES GERAIS"

print_message "Instalando PuTTY..."
dnf install -y putty

print_message "Instalando Vim..."
dnf install -y vim vim-enhanced

print_message "Instalando HTOP..."
dnf install -y htop

print_message "Instalando Glances..."
dnf install -y glances

print_message "Instalando VLC..."
dnf install -y vlc

print_message "Instalando Google Chrome..."
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
dnf install -y google-chrome-stable

print_message "Instalando TeamViewer..."
wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm -O /tmp/teamviewer.rpm
dnf install -y /tmp/teamviewer.rpm

print_message "Instalando AnyDesk..."
cat << EOF > /etc/yum.repos.d/anydesk.repo
[anydesk]
name=AnyDesk Fedora
baseurl=http://rpm.anydesk.com/fedora/\$basearch/
gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF
dnf install -y anydesk

print_message "Instalando Dropbox..."
dnf install -y nautilus-dropbox

print_message "Instalando VirtualBox..."
dnf install -y VirtualBox kernel-devel kernel-headers dkms
usermod -a -G vboxusers $SUDO_USER

print_message "Instalando Spotify..."
flatpak install -y flathub com.spotify.Client

print_message "Instalando HandBrake..."
dnf install -y handbrake handbrake-gui

print_message "Instalando GIMP..."
dnf install -y gimp

print_message "Instalando Inkscape..."
dnf install -y inkscape

print_message "Instalando fontes da Microsoft..."
dnf install -y curl cabextract xorg-x11-font-utils fontconfig
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

print_message "Instalando Telegram Desktop..."
dnf install -y telegram-desktop

print_message "Instalando Warehouse..."
flatpak install -y flathub io.github.flattool.Warehouse

print_message "Instalando Stacer (Otimizador do Sistema)..."
flatpak install -y flathub com.oguzhaninan.Stacer

print_message "Instalando suporte para impressoras HP..."
dnf install -y hplip hplip-gui

# ============================================================================
# 10. AMBIENTE DE DESENVOLVIMENTO
# ============================================================================

print_section "10. INSTALANDO AMBIENTE DE DESENVOLVIMENTO"

print_message "Instalando Code::Blocks com GCC..."
dnf groupinstall -y "C Development Tools and Libraries"
dnf groupinstall -y "Development Tools"
dnf install -y gcc gcc-c++ make cmake
dnf install -y codeblocks codeblocks-contrib

print_message "Instalando Python e pip..."
dnf install -y python3 python3-pip python3-devel
pip3 install --upgrade pip

print_message "Instalando pacotes Python específicos..."
pip3 install pyopengl
pip3 install pyopengl-accelerate

print_message "Instalando Git..."
dnf install -y git git-gui gitk

print_message "Instalando VS Code..."
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat << EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
dnf install -y code

print_message "Instalando Eclipse IDE..."
dnf install -y eclipse

print_message "Instalando MySQL Workbench..."
dnf install -y mysql-workbench

print_message "Instalando GitHub Desktop..."
# Método 1: Via repositório RPM (Nativo - Recomendado)
print_message "  Adicionando repositório oficial do GitHub Desktop..."
rpm --import https://rpm.packages.shiftkey.dev/gpg.key
cat << EOF > /etc/yum.repos.d/shiftkey-packages.repo
[shiftkey-packages]
name=GitHub Desktop
baseurl=https://rpm.packages.shiftkey.dev/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://rpm.packages.shiftkey.dev/gpg.key
EOF

if dnf install -y github-desktop; then
    print_message "  ✓ GitHub Desktop instalado via repositório RPM"
else
    print_warning "  Falha no método RPM, tentando via Flatpak..."
    flatpak install -y flathub io.github.shiftey.Desktop
    print_message "  ✓ GitHub Desktop instalado via Flatpak"
fi

print_message "Instalando Apache NetBeans..."
flatpak install -y flathub org.apache.netbeans

print_message "Instalando Umbrello..."
dnf install -y umbrello

print_message "Instalando DIA..."
dnf install -y dia

print_message "Instalando PyCharm Community Edition..."
flatpak install -y flathub com.jetbrains.PyCharm-Community

print_message "Instalando GVim..."
dnf install -y vim-X11

# ============================================================================
# 11. GAMES
# ============================================================================

print_section "11. INSTALANDO GAMES"

print_message "Instalando Flycast (Emulador de SEGA Dreamcast)..."
flatpak install -y flathub org.flycast.Flycast

print_message "Instalando Snes9x (Emulador de Super Nintendo)..."
dnf install -y snes9x

print_message "Instalando Extreme Tux Racer..."
dnf install -y extremetuxracer

print_message "Instalando SuperTuxKart..."
dnf install -y supertuxkart

# ============================================================================
# 12. SERVIDOR (LAMP STACK + MONGODB)
# ============================================================================

print_section "12. INSTALANDO SERVIDOR LAMP + MONGODB"

print_message "Instalando Apache..."
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

print_message "Instalando PHP..."
dnf install -y php php-cli php-common php-mysqlnd php-pdo php-gd php-mbstring php-xml php-curl php-json php-zip
systemctl restart httpd

print_message "Instalando MariaDB (MySQL)..."
dnf install -y mariadb-server mariadb
systemctl enable mariadb
systemctl start mariadb

print_message "Instalando phpMyAdmin..."
dnf install -y phpmyadmin
cat << EOF > /etc/httpd/conf.d/phpMyAdmin.conf
Alias /phpmyadmin /usr/share/phpMyAdmin
<Directory /usr/share/phpMyAdmin/>
   AddDefaultCharset UTF-8
   <IfModule mod_authz_core.c>
     Require all granted
   </IfModule>
</Directory>
EOF
systemctl restart httpd

print_message "Instalando MongoDB..."
cat << EOF > /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF
dnf install -y mongodb-org
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
dnf clean all

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
print_message "Script de pós-instalação do Fedora 44 concluído com sucesso!"
print_message ""
print_message "Algumas observações importantes:"
print_message "  - Para configurar o MySQL/MariaDB, execute: sudo mysql_secure_installation"
print_message "  - O phpMyAdmin está disponível em: http://localhost/phpmyadmin"
print_message "  - Para iniciar o Compiz, use: compiz --replace"
print_message "  - GitHub Desktop: Acesse via menu de aplicativos ou 'github-desktop'"
print_message "  - Stacer: Ferramenta de otimização e monitoramento do sistema"
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
