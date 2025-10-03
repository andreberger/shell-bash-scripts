#!/bin/bash

#=============================================================================
# Script de Pós-Instalação para Fedora 42
#=============================================================================
# Descrição: Script automatizado para configuração completa de um sistema
#            Fedora 42 recém-instalado, incluindo instalação de repositórios,
#            codecs multimídia, aplicativos essenciais e ferramentas de 
#            desenvolvimento.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Fedora 42
#
# ATENÇÃO: Este script requer privilégios de administrador (sudo)
#          Certifique-se de ter uma conexão estável com a internet
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Baixe o script para seu sistema Fedora 42
# 2. Torne o script executável: chmod +x pos-instalacao-fedora-42.sh
# 3. Execute o script: ./pos-instalacao-fedora-42.sh
# 4. Digite sua senha quando solicitado
# 5. Aguarde a conclusão (pode levar entre 30-60 minutos)
# 6. Reinicie o sistema após a conclusão
#
# NOTA: Durante a execução, o script pode solicitar confirmações.
#       Para execução totalmente automatizada, use: yes | ./script.sh
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/tmp/pos-instalacao-fedora-$(date +%Y%m%d_%H%M%S).log"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para imprimir mensagens coloridas
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

# Função para imprimir cabeçalho de seção
print_section() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

# Função para verificar se o comando foi executado com sucesso
check_command() {
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✓ $1 executado com sucesso"
    else
        print_message "$RED" "✗ Erro ao executar: $1"
        exit 1
    fi
}

# Função para verificar se o usuário é root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_message "$RED" "Este script não deve ser executado como root!"
        print_message "$YELLOW" "Execute como usuário normal. O sudo será solicitado quando necessário."
        exit 1
    fi
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "Iniciando script de pós-instalação do Fedora 42..."
print_message "$YELLOW" "Log será salvo em: $LOG_FILE"

# Verificar se não está sendo executado como root
check_root

#=============================================================================
# 1. ATUALIZAÇÃO INICIAL DO SISTEMA
#=============================================================================

print_section "1. ATUALIZANDO O SISTEMA"
print_message "$YELLOW" "Atualizando todos os pacotes do sistema..."

sudo dnf upgrade -y --refresh
check_command "Atualização do sistema"

#=============================================================================
# 2. CONFIGURAÇÃO DO FIREWALL
#=============================================================================

print_section "2. CONFIGURANDO FIREWALL"
print_message "$YELLOW" "Verificando status e desabilitando firewall..."

sudo systemctl status firewalld.service || true
sudo systemctl disable firewalld.service
check_command "Configuração do firewall"

#=============================================================================
# 3. CONFIGURAÇÃO DOS REPOSITÓRIOS RPM FUSION
#=============================================================================

print_section "3. CONFIGURANDO REPOSITÓRIOS RPM FUSION"

# RPM Fusion Free
print_message "$YELLOW" "Instalando RPM Fusion Free..."
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora)
check_command "Instalação RPM Fusion Free"

# RPM Fusion Non-Free
print_message "$YELLOW" "Instalando RPM Fusion Non-Free..."
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-nonfree-fedora-$(rpm -E %fedora)
check_command "Instalação RPM Fusion Non-Free"

# Repositórios Tainted
print_message "$YELLOW" "Instalando repositórios Tainted..."
sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
check_command "Instalação repositórios Tainted"

#=============================================================================
# 4. CODECS MULTIMÍDIA
#=============================================================================

print_section "4. INSTALANDO CODECS MULTIMÍDIA"

print_message "$YELLOW" "Configurando FFmpeg..."
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
check_command "Configuração FFmpeg"

print_message "$YELLOW" "Atualizando pacotes multimídia..."
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
check_command "Atualização pacotes multimídia"

print_message "$YELLOW" "Instalando codecs adicionais..."
sudo dnf install -y amrnb amrwb faad2 flac gpac-libs lame libde265 libfc14audiodecoder mencoder x264 x265
check_command "Instalação codecs adicionais"

#=============================================================================
# 5. APLICATIVOS MULTIMÍDIA
#=============================================================================

print_section "5. INSTALANDO APLICATIVOS MULTIMÍDIA"

print_message "$YELLOW" "Instalando aplicativos de áudio e vídeo..."
sudo dnf install -y libdvdcss audacious vlc smplayer audacity gimp HandBrake HandBrake-gui inkscape krita obs-studio openshot
check_command "Instalação aplicativos multimídia"

#=============================================================================
# 6. FONTES DO SISTEMA
#=============================================================================

print_section "6. CONFIGURANDO FONTES"

print_message "$YELLOW" "Instalando utilitários de fonte..."
sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
check_command "Instalação utilitários de fonte"

print_message "$YELLOW" "Instalando fontes Microsoft..."
sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
check_command "Instalação fontes Microsoft"

#=============================================================================
# 7. APLICATIVOS DE COMUNICAÇÃO
#=============================================================================

print_section "7. INSTALANDO APLICATIVOS DE COMUNICAÇÃO"

print_message "$YELLOW" "Instalando Telegram Desktop..."
sudo dnf install -y telegram-desktop
check_command "Instalação Telegram"

print_message "$YELLOW" "Instalando Thunderbird..."
sudo dnf install -y thunderbird
check_command "Instalação Thunderbird"

#=============================================================================
# 8. NAVEGADORES WEB
#=============================================================================

print_section "8. INSTALANDO NAVEGADORES"

print_message "$YELLOW" "Instalando Google Chrome..."
sudo dnf install -y 'https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm'
check_command "Instalação Google Chrome"

#=============================================================================
# 9. AMBIENTE JAVA
#=============================================================================

print_section "9. CONFIGURANDO AMBIENTE JAVA"

print_message "$YELLOW" "Instalando OpenJDK..."
sudo dnf install -y java-21-openjdk java-24-openjdk java-latest-openjdk \
                    java-21-openjdk-devel java-24-openjdk-devel java-latest-openjdk-devel
check_command "Instalação OpenJDK"

print_message "$YELLOW" "Configurando repositório Adoptium Temurin..."
sudo dnf install -y adoptium-temurin-java-repository
sudo dnf config-manager setopt adoptium-temurin-java-repository.enabled=1
check_command "Configuração repositório Adoptium"

print_message "$YELLOW" "Instalando Temurin JRE/JDK..."
sudo dnf install -y temurin-8-jre temurin-11-jre temurin-17-jre \
                    temurin-8-jdk temurin-11-jdk temurin-17-jdk
check_command "Instalação Temurin"

#=============================================================================
# 10. VIRTUALIZAÇÃO
#=============================================================================

print_section "10. CONFIGURANDO VIRTUALIZAÇÃO"

print_message "$YELLOW" "Instalando VirtualBox..."
sudo dnf install -y VirtualBox
sudo usermod -a -G vboxusers $USER
check_command "Instalação VirtualBox"

#=============================================================================
# 11. ARMAZENAMENTO EM NUVEM
#=============================================================================

print_section "11. INSTALANDO CLIENTES DE NUVEM"

print_message "$YELLOW" "Instalando Dropbox..."
sudo dnf install -y dropbox
check_command "Instalação Dropbox"

print_message "$YELLOW" "Configurando repositório MEGA..."
sudo rpmkeys --import https://mega.nz/linux/repo/Fedora_42/repodata/repomd.xml.key
sudo dnf install -y https://mega.nz/linux/repo/Fedora_42/x86_64/megasync-Fedora_42.x86_64.rpm
check_command "Instalação MEGA Sync"

#=============================================================================
# 12. UTILITÁRIOS DO SISTEMA
#=============================================================================

print_section "12. INSTALANDO UTILITÁRIOS"

print_message "$YELLOW" "Instalando utilitários adicionais..."
sudo dnf install -y dolphin-plugins guake
check_command "Instalação utilitários"

#=============================================================================
# 13. SPOTIFY
#=============================================================================

print_section "13. CONFIGURANDO SPOTIFY"

print_message "$YELLOW" "Configurando cliente Spotify..."
sudo dnf install -y lpf-spotify-client
sudo usermod -a -G pkg-build $USER
check_command "Configuração Spotify"

print_message "$YELLOW" "Para finalizar a instalação do Spotify, execute após reiniciar:"
print_message "$YELLOW" "lpf update"

#=============================================================================
# 14. VISUAL STUDIO CODE
#=============================================================================

print_section "14. INSTALANDO VISUAL STUDIO CODE"

print_message "$YELLOW" "Configurando repositório Microsoft..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo
check_command "Configuração repositório VS Code"

print_message "$YELLOW" "Instalando Visual Studio Code..."
sudo dnf install -y code code-insiders
check_command "Instalação VS Code"

#=============================================================================
# 15. FLATPAK E APLICATIVOS
#=============================================================================

print_section "15. CONFIGURANDO FLATPAK"

print_message "$YELLOW" "Adicionando repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_command "Configuração Flathub"

print_message "$YELLOW" "Instalando emuladores via Flatpak..."
flatpak install -y flathub org.flycast.Flycast com.snes9x.Snes9x
check_command "Instalação emuladores"

#=============================================================================
# FINALIZAÇÃO
#=============================================================================

print_section "INSTALAÇÃO CONCLUÍDA"

print_message "$GREEN" "✓ Script de pós-instalação executado com sucesso!"
print_message "$YELLOW" "📋 Resumo das instalações:"
echo -e "   • Sistema atualizado"
echo -e "   • Repositórios RPM Fusion configurados"
echo -e "   • Codecs multimídia instalados"
echo -e "   • Aplicativos essenciais instalados"
echo -e "   • Ambiente Java configurado"
echo -e "   • VirtualBox instalado"
echo -e "   • Visual Studio Code instalado"
echo -e "   • Flatpak configurado"

print_message "$BLUE" "📝 Próximos passos:"
echo -e "   1. Reinicie o sistema: sudo reboot"
echo -e "   2. Para finalizar o Spotify: lpf update"
echo -e "   3. Configure suas contas nos aplicativos instalados"

print_message "$YELLOW" "📄 Log completo salvo em: $LOG_FILE"
print_message "$GREEN" "🎉 Seu Fedora 42 está pronto para uso!"