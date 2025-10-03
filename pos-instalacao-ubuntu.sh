#!/bin/bash

#=============================================================================
# Script de Pós-Instalação para Ubuntu 24.04.3 LTS
#=============================================================================
# Descrição: Script automatizado para configuração completa de um sistema
#            Ubuntu 24.04.3 LTS recém-instalado, incluindo instalação de
#            aplicativos essenciais, codecs multimídia, ferramentas de
#            produtividade e otimizações do sistema.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Ubuntu 24.04.3 LTS (Noble Numbat)
# Testado em: Ubuntu 24.04.3 LTS
#
# ATENÇÃO: Este script requer privilégios de administrador (sudo)
#          Certifique-se de ter uma conexão estável com a internet
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Baixe o script para seu sistema Ubuntu 24.04.3 LTS
# 2. Torne o script executável: chmod +x pos-instalacao-ubuntu.sh
# 3. Execute o script: ./pos-instalacao-ubuntu.sh
# 4. Digite sua senha quando solicitado
# 5. Aguarde a conclusão (pode levar entre 20-40 minutos)
# 6. Reinicie o sistema após a conclusão
#
# NOTA: Durante a execução, o script pode solicitar confirmações.
#       Para execução totalmente automatizada, use: yes | ./script.sh
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/tmp/pos-instalacao-ubuntu-$(date +%Y%m%d_%H%M%S).log"

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

# Função para limpar arquivos temporários
cleanup_temp() {
    print_message "$YELLOW" "Limpando arquivos temporários..."
    cd "$HOME"
    sudo rm -f /tmp/*.deb /tmp/teamviewer-keyring.gpg 2>/dev/null || true
    check_command "Limpeza de arquivos temporários"
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "Iniciando script de pós-instalação do Ubuntu 24.04.3 LTS..."
print_message "$YELLOW" "Log será salvo em: $LOG_FILE"

# Verificar se não está sendo executado como root
check_root

#=============================================================================
# 1. ATUALIZAÇÃO INICIAL DO SISTEMA
#=============================================================================

print_section "1. ATUALIZANDO O SISTEMA"
print_message "$YELLOW" "Atualizando lista de pacotes e sistema..."

sudo apt update && sudo apt upgrade -y
check_command "Atualização do sistema"

#=============================================================================
# 2. UTILITÁRIOS BÁSICOS DO SISTEMA
#=============================================================================

print_section "2. INSTALANDO UTILITÁRIOS BÁSICOS"
print_message "$YELLOW" "Instalando ferramentas essenciais do sistema..."

sudo apt install -y apturl apturl-common gnome-software gnome-tweaks tlp tlp-rdw
check_command "Instalação utilitários básicos"

#=============================================================================
# 3. OTIMIZAÇÃO DE ENERGIA (TLP)
#=============================================================================

print_section "3. CONFIGURANDO OTIMIZAÇÃO DE ENERGIA"
print_message "$YELLOW" "Habilitando e iniciando serviço TLP..."

sudo systemctl enable tlp.service && sudo tlp start
check_command "Configuração TLP"

#=============================================================================
# 4. FLATPAK E REPOSITÓRIOS
#=============================================================================

print_section "4. CONFIGURANDO FLATPAK"

print_message "$YELLOW" "Instalando Flatpak..."
sudo apt install -y flatpak
check_command "Instalação Flatpak"

print_message "$YELLOW" "Adicionando repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_command "Configuração Flathub"

print_message "$YELLOW" "Instalando plugin Flatpak para GNOME Software..."
sudo apt install -y gnome-software-plugin-flatpak
check_command "Instalação plugin Flatpak"

#=============================================================================
# 5. CODECS E EXTRAS RESTRITOS
#=============================================================================

print_section "5. INSTALANDO CODECS MULTIMÍDIA"

print_message "$YELLOW" "Instalando codecs extras do Ubuntu..."
sudo apt install -y ubuntu-restricted-extras
check_command "Instalação codecs restritos"

print_message "$YELLOW" "Configurando suporte a DVD..."
sudo apt install -y libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg
check_command "Configuração suporte DVD"

#=============================================================================
# 6. APLICATIVOS MULTIMÍDIA
#=============================================================================

print_section "6. INSTALANDO APLICATIVOS MULTIMÍDIA"
print_message "$YELLOW" "Instalando players de áudio/vídeo e editores..."

sudo apt install -y audacious libqt6svg6 vlc smplayer audacity handbrake
check_command "Instalação aplicativos multimídia"

#=============================================================================
# 7. NAVEGADOR GOOGLE CHROME
#=============================================================================

print_section "7. INSTALANDO GOOGLE CHROME"
print_message "$YELLOW" "Baixando e instalando Google Chrome..."

cd /tmp
wget -O google-chrome-stable.deb 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
sudo apt install -y ./google-chrome-stable.deb
check_command "Instalação Google Chrome"

#=============================================================================
# 8. ANYDESK (ACESSO REMOTO)
#=============================================================================

print_section "8. INSTALANDO ANYDESK"

print_message "$YELLOW" "Configurando repositório AnyDesk..."
cd /tmp
wget -qO- https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/anydesk.gpg
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
check_command "Configuração repositório AnyDesk"

print_message "$YELLOW" "Instalando AnyDesk..."
sudo apt update && sudo apt install -y anydesk
check_command "Instalação AnyDesk"

#=============================================================================
# 9. TEAMVIEWER (ACESSO REMOTO)
#=============================================================================

print_section "9. INSTALANDO TEAMVIEWER"

print_message "$YELLOW" "Configurando chaves TeamViewer..."
cd /tmp
wget -qO- https://linux.teamviewer.com/pubkey/currentkey.asc | gpg --dearmor > teamviewer-keyring.gpg
sudo install -o root -g root -m 644 teamviewer-keyring.gpg /usr/share/keyrings/
check_command "Configuração chaves TeamViewer"

print_message "$YELLOW" "Baixando e instalando TeamViewer..."
wget -c https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo apt install -y ./teamviewer*.deb
check_command "Instalação TeamViewer"

#=============================================================================
# 10. APLICATIVOS ADICIONAIS VIA APT
#=============================================================================

print_section "10. INSTALANDO APLICATIVOS ADICIONAIS"

print_message "$YELLOW" "Instalando aplicativos complementares..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    neofetch \
    tree \
    unrar \
    p7zip-full \
    gparted \
    synaptic \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
check_command "Instalação aplicativos complementares"

#=============================================================================
# 11. SNAP PACKAGES ESSENCIAIS
#=============================================================================

print_section "11. INSTALANDO APLICATIVOS VIA SNAP"

print_message "$YELLOW" "Instalando aplicativos essenciais via Snap..."
sudo snap install code --classic
sudo snap install discord
sudo snap install telegram-desktop
sudo snap install libreoffice
check_command "Instalação aplicativos Snap"

#=============================================================================
# 12. CONFIGURAÇÕES FINAIS DO SISTEMA
#=============================================================================

print_section "12. CONFIGURAÇÕES FINAIS"

print_message "$YELLOW" "Atualizando cache de fontes..."
sudo fc-cache -fv
check_command "Atualização cache de fontes"

print_message "$YELLOW" "Atualizando base de dados do sistema..."
sudo updatedb 2>/dev/null || true
check_command "Atualização base de dados"

print_message "$YELLOW" "Removendo pacotes órfãos..."
sudo apt autoremove -y
sudo apt autoclean
check_command "Limpeza do sistema"

#=============================================================================
# 13. LIMPEZA FINAL
#=============================================================================

print_section "13. LIMPEZA DE ARQUIVOS TEMPORÁRIOS"
cleanup_temp

#=============================================================================
# FINALIZAÇÃO
#=============================================================================

print_section "INSTALAÇÃO CONCLUÍDA"

print_message "$GREEN" "✓ Script de pós-instalação executado com sucesso!"
print_message "$YELLOW" "📋 Resumo das instalações:"
echo -e "   • Sistema atualizado e otimizado"
echo -e "   • TLP configurado para economia de energia"
echo -e "   • Flatpak e Flathub configurados"
echo -e "   • Codecs multimídia instalados"
echo -e "   • Aplicativos multimídia instalados"
echo -e "   • Google Chrome instalado"
echo -e "   • AnyDesk e TeamViewer configurados"
echo -e "   • Aplicativos complementares instalados"
echo -e "   • Visual Studio Code, Discord, Telegram instalados"
echo -e "   • LibreOffice atualizado via Snap"

print_message "$BLUE" "📝 Próximos passos:"
echo -e "   1. Reinicie o sistema: sudo reboot"
echo -e "   2. Configure suas contas nos aplicativos instalados"
echo -e "   3. Explore o GNOME Software para mais aplicativos Flatpak"
echo -e "   4. Configure o TLP conforme suas necessidades"

print_message "$YELLOW" "📄 Log completo salvo em: $LOG_FILE"
print_message "$GREEN" "🎉 Seu Ubuntu 24.04.3 LTS está pronto para uso!"

# Retornar ao diretório home
cd "$HOME"


