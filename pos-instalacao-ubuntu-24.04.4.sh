#!/bin/bash

#=============================================================================
# Script: pos-instalacao-ubuntu-24.04.4.sh
# Descrição: Script completo de pós-instalação para Ubuntu 24.04.4 LTS
#            Configuração automatizada com aplicativos essenciais
# Autor: Andre Berger
# Data: 02/04/2026
# Versão: 1.0
# Licença: MIT
# Compatibilidade: Ubuntu 24.04.4 LTS (Noble Numbat)
#=============================================================================

# Configurações do script
set -e  # Sair se qualquer comando falhar
set -o pipefail  # Detectar erros em pipes
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/pos-instalacao-ubuntu-$(date '+%Y%m%d_%H%M%S').log"
readonly TEMP_DIR="/tmp/ubuntu-setup-$$"

# Variáveis de progresso e tempo
START_TIME=$(date +%s)
TOTAL_STEPS=18
CURRENT_STEP=0
USE_DIALOG=false

# Modo debug (descomente para ativar)
# set -x

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

#=============================================================================
# PASSO A PASSO DE EXECUÇÃO:
#=============================================================================
# 1. Fazer backup de dados importantes antes de executar
#
# 2. Conectar à internet (WiFi ou cabo)
#
# 3. Tornar o script executável:
#    chmod +x pos-instalacao-ubuntu-24.04.4.sh
#
# 4. Executar o script com privilégios sudo:
#    sudo ./pos-instalacao-ubuntu-24.04.4.sh
#
# 5. Seguir as instruções na tela
#
# 6. Reiniciar o sistema após conclusão:
#    sudo reboot
#
# 7. Verificar logs em caso de problemas:
#    cat /tmp/pos-instalacao-ubuntu-*.log
#
# NOTA: Este script foi testado no Ubuntu 24.04.4 LTS
#       A execução leva aproximadamente 20-40 minutos dependendo da internet
#=============================================================================

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para imprimir mensagens coloridas
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "$LOG_FILE"
}

# Função para imprimir cabeçalho de seção
print_section() {
    local title="$1"
    echo
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}  $title${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Função para imprimir cabeçalho principal
print_header() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║              🐧 PÓS-INSTALAÇÃO UBUNTU 24.04.4 LTS (NOBLE NUMBAT)            ║
║                                                                              ║
║                     Configuração Completa e Automatizada                    ║
║                              Versão 1.0 - 2026                              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Função para verificar se está executando como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_message "$RED" "❌ Este script deve ser executado com privilégios sudo!"
        print_message "$CYAN" "💡 Execute: sudo ./pos-instalacao-ubuntu-24.04.4.sh"
        exit 1
    fi
    
    # Instalar dialog logo no início para melhor experiência
    check_dialog
}

# Função para verificar versão do Ubuntu
check_ubuntu_version() {
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        print_message "$RED" "❌ Este script é específico para Ubuntu!"
        print_message "$YELLOW" "Sistema atual: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
        exit 1
    fi
    
    local ubuntu_version
    ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "0")
    
    if [[ $(echo "$ubuntu_version < 24.04" | bc) -eq 1 ]]; then
        print_message "$YELLOW" "⚠️  Este script foi testado no Ubuntu 24.04.4"
        print_message "$YELLOW" "⚠️  Sua versão: Ubuntu $ubuntu_version"
        print_message "$CYAN" "💡 Continuar mesmo assim? (s/N)"
        read -r continue_anyway
        if [[ "$continue_anyway" != "s" && "$continue_anyway" != "S" ]]; then
            exit 1
        fi
    fi
    
    print_message "$GREEN" "✅ Ubuntu $ubuntu_version detectado"
}

# Função para verificar conexão com internet
check_internet() {
    print_message "$BLUE" "🌐 Verificando conexão com a internet..."
    
    if ping -c 1 google.com &> /dev/null || ping -c 1 8.8.8.8 &> /dev/null; then
        print_message "$GREEN" "✅ Conexão com internet OK"
        return 0
    else
        print_message "$RED" "❌ Sem conexão com a internet!"
        print_message "$YELLOW" "⚠️  Conecte-se à internet e execute o script novamente"
        exit 1
    fi
}

# Função para criar diretório temporário
create_temp_dir() {
    mkdir -p "$TEMP_DIR"
    print_message "$BLUE" "📁 Diretório temporário criado: $TEMP_DIR"
}

# Função para limpeza de arquivos temporários
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        print_message "$BLUE" "🧹 Arquivos temporários removidos"
    fi
}

# Registrar limpeza ao sair
trap cleanup EXIT

# Função para exibir barra de progresso
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r${CYAN}["
    printf "%${completed}s" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] ${WHITE}%d%%${NC}" $percentage
}

# Função para calcular tempo decorrido
get_elapsed_time() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))
    local hours=$((elapsed / 3600))
    local minutes=$(((elapsed % 3600) / 60))
    local seconds=$((elapsed % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%02dh %02dm %02ds" $hours $minutes $seconds
    elif [[ $minutes -gt 0 ]]; then
        printf "%02dm %02ds" $minutes $seconds
    else
        printf "%02ds" $seconds
    fi
}

# Função para atualizar progresso global
update_progress() {
    local step_name="$1"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local elapsed=$(get_elapsed_time)
    
    echo
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}📊 Progresso: ${GREEN}${CURRENT_STEP}/${TOTAL_STEPS}${WHITE} (${CYAN}${percentage}%${WHITE})  ⏱️  Tempo: ${YELLOW}${elapsed}${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

# Função para mostrar progresso de instalação com animação
show_install_progress() {
    local message="$1"
    local pid=$2
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN}[%c]${NC} ${message}..." "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r${GREEN}[✓]${NC} ${message}... ${GREEN}Concluído!${NC}\n"
}

# Função para verificar e instalar dialog
check_dialog() {
    if command -v dialog &> /dev/null; then
        USE_DIALOG=true
        print_message "$GREEN" "✅ Dialog detectado - usando interface avançada"
    else
        print_message "$YELLOW" "⚠️  Instalando dialog para melhor experiência visual..."
        apt-get install -y dialog < /dev/null >> "$LOG_FILE" 2>&1 || true
        if command -v dialog &> /dev/null; then
            USE_DIALOG=true
        fi
    fi
}

# Função para mostrar progresso com dialog
show_dialog_progress() {
    local percentage=$1
    local message="$2"
    
    if [[ "$USE_DIALOG" == "true" ]]; then
        echo "XXX"
        echo "$percentage"
        echo "$message"
        echo "XXX"
    fi
}

#=============================================================================
# SEÇÃO 1: ATUALIZAÇÕES DO SISTEMA
#=============================================================================

update_system() {
    print_section "📦 SEÇÃO 1/15: ATUALIZANDO O SISTEMA"
    update_progress "Atualização do Sistema"
    
    # Configurar para modo não-interativo ANTES de qualquer comando apt
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    export NEEDRESTART_SUSPEND=1
    
    if [[ "$USE_DIALOG" == "true" ]]; then
        (
            echo "10" ; echo "XXX" ; echo "🔧 Removendo locks..." ; echo "XXX"
            rm -f /var/lib/dpkg/lock-frontend 2>/dev/null || true
            rm -f /var/lib/dpkg/lock 2>/dev/null || true
            rm -f /var/cache/apt/archives/lock 2>/dev/null || true
            dpkg --configure -a >> "$LOG_FILE" 2>&1 || true
            
            echo "25" ; echo "XXX" ; echo "🔄 Atualizando lista de pacotes..." ; echo "XXX"
            apt-get update -y < /dev/null >> "$LOG_FILE" 2>&1 || sleep 2 && apt-get update -y < /dev/null >> "$LOG_FILE" 2>&1 || true
            
            echo "45" ; echo "XXX" ; echo "⬆️  Instalando atualizações (upgrade)..." ; echo "XXX"
            DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" \
                -o Dpkg::Options::="--force-confnew" \
                < /dev/null >> "$LOG_FILE" 2>&1 || true
            
            echo "65" ; echo "XXX" ; echo "⬆️  Instalando atualizações (dist-upgrade)..." ; echo "XXX"
            DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" \
                -o Dpkg::Options::="--force-confnew" \
                < /dev/null >> "$LOG_FILE" 2>&1 || true
            
            echo "85" ; echo "XXX" ; echo "⬆️  Instalando atualizações (full-upgrade)..." ; echo "XXX"
            DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" \
                -o Dpkg::Options::="--force-confnew" \
                < /dev/null >> "$LOG_FILE" 2>&1 || true
            
            echo "100" ; echo "XXX" ; echo "✅ Atualização concluída!" ; echo "XXX"
        ) | dialog --title "Atualizando Sistema" --gauge "Iniciando..." 7 70 0
    else
        print_message "$BLUE" "🔧 Removendo locks... [0%]"
        rm -f /var/lib/dpkg/lock-frontend 2>/dev/null || true
        rm -f /var/lib/dpkg/lock 2>/dev/null || true
        rm -f /var/cache/apt/archives/lock 2>/dev/null || true
        dpkg --configure -a >> "$LOG_FILE" 2>&1 || true
        
        print_message "$BLUE" "🔄 Atualizando lista de pacotes... [25%]"
        apt-get update -y < /dev/null >> "$LOG_FILE" 2>&1 || {
            print_message "$YELLOW" "⚠️  Tentando novamente..."
            sleep 2
            apt-get update -y < /dev/null >> "$LOG_FILE" 2>&1 || true
        }
        
        print_message "$BLUE" "⬆️  Instalando atualizações (upgrade)... [45%]"
        DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confnew" \
            < /dev/null >> "$LOG_FILE" 2>&1 || true
        
        print_message "$BLUE" "⬆️  Instalando atualizações (dist-upgrade)... [65%]"
        DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confnew" \
            < /dev/null >> "$LOG_FILE" 2>&1 || true
        
        print_message "$BLUE" "⬆️  Instalando atualizações (full-upgrade)... [85%]"
        DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confnew" \
            < /dev/null >> "$LOG_FILE" 2>&1 || true
        
        print_message "$BLUE" "✅ Finalização... [100%]"
    fi
    
    print_message "$GREEN" "✅ Sistema atualizado com sucesso!"
}

#=============================================================================
# SEÇÃO 2: CONFIGURAÇÃO DE IDIOMA
#=============================================================================

configure_portuguese() {
    print_section "🇧🇷 SEÇÃO 2/15: CONFIGURANDO PORTUGUÊS DO BRASIL"
    update_progress "Configuração Português BR"
    
    print_message "$BLUE" "🌍 Instalando pacotes de idioma português... [25%]"
    apt install -y language-pack-pt language-pack-gnome-pt >> "$LOG_FILE" 2>&1
    apt install -y language-pack-pt-base language-pack-gnome-pt-base >> "$LOG_FILE" 2>&1
    apt install -y hunspell-pt-br aspell-pt-br >> "$LOG_FILE" 2>&1
    apt install -y $(check-language-support -l pt) >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "⚙️  Configurando locale para pt_BR.UTF-8..."
    
    # Gerar locales
    locale-gen pt_BR.UTF-8 >> "$LOG_FILE" 2>&1
    update-locale LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8 LANGUAGE=pt_BR >> "$LOG_FILE" 2>&1
    
    # Configurar para todos os usuários
    cat > /etc/default/locale << EOF
LANG="pt_BR.UTF-8"
LANGUAGE="pt_BR:pt:en"
LC_ALL="pt_BR.UTF-8"
EOF
    
    print_message "$GREEN" "✅ Idioma português do Brasil configurado!"
    print_message "$YELLOW" "⚠️  Faça logout e login novamente para aplicar completamente"
}

#=============================================================================
# SEÇÃO 3: HABILITAÇÃO DE INSTALAÇÃO COM 1 CLICK
#=============================================================================

enable_one_click_install() {
    print_section "🖱️  SEÇÃO 3/15: HABILITANDO INSTALAÇÃO COM 1 CLICK"
    update_progress "Instalação com 1 Click"
    
    print_message "$BLUE" "⚙️  Configurando suporte a apt: URLs..."
    
    # Instalar apturl (necessário para apt: URLs)
    if apt install -y apturl >> "$LOG_FILE" 2>&1; then
        print_message "$GREEN" "✅ apturl instalado"
    else
        print_message "$YELLOW" "⚠️  apturl não disponível, pulando..."
    fi
    
    # Instalar gnome-software-plugin-snap (pode não existir em todas as versões)
    if apt-cache show gnome-software-plugin-snap &> /dev/null; then
        apt install -y gnome-software-plugin-snap >> "$LOG_FILE" 2>&1 || true
        print_message "$GREEN" "✅ Plugin Snap instalado"
    else
        print_message "$YELLOW" "⚠️  Plugin Snap não disponível nesta versão"
    fi
    
    # Instalar sessioninstaller (pode não existir no Ubuntu 24.04)
    if apt-cache show sessioninstaller &> /dev/null; then
        apt install -y sessioninstaller >> "$LOG_FILE" 2>&1 || true
        print_message "$GREEN" "✅ sessioninstaller instalado"
    else
        print_message "$YELLOW" "⚠️  sessioninstaller não disponível nesta versão"
    fi
    
    # Configurar handler de protocolo apt: se apturl estiver instalado
    if command -v apturl &> /dev/null; then
        cat > /usr/share/applications/apturl.desktop << 'EOF'
[Desktop Entry]
Name=APT URL Handler
Comment=Install packages from web browsers
Exec=apturl %u
Type=Application
NoDisplay=true
MimeType=x-scheme-handler/apt;
EOF
        update-desktop-database >> "$LOG_FILE" 2>&1 || true
        print_message "$GREEN" "✅ Handler apt: configurado"
    fi
    
    print_message "$GREEN" "✅ Instalação com 1 click configurada!"
}

#=============================================================================
# SEÇÃO 4: LOJA GNOME SOFTWARE
#=============================================================================

install_gnome_software() {
    print_section "🏬 SEÇÃO 4/15: INSTALANDO LOJA GNOME SOFTWARE"
    update_progress "GNOME Software"
    
    print_message "$BLUE" "📱 Instalando GNOME Software (Loja de Aplicativos)..."
    
    apt install -y gnome-software >> "$LOG_FILE" 2>&1 || true
    
    # Plugins podem não estar disponíveis em todas as versões
    if apt-cache show gnome-software-plugin-flatpak &> /dev/null; then
        apt install -y gnome-software-plugin-flatpak >> "$LOG_FILE" 2>&1 || true
    fi
    
    if apt-cache show gnome-software-plugin-snap &> /dev/null; then
        apt install -y gnome-software-plugin-snap >> "$LOG_FILE" 2>&1 || true
    fi
    
    print_message "$GREEN" "✅ GNOME Software instalado com sucesso!"
    print_message "$CYAN" "💡 Acesse pelo menu de aplicativos: 'Software' ou 'Loja'"
}

#=============================================================================
# SEÇÃO 5: GNOME TWEAKS
#=============================================================================

install_gnome_tweaks() {
    print_section "🎨 SEÇÃO 5/15: INSTALANDO GNOME TWEAKS"
    update_progress "GNOME Tweaks"
    
    print_message "$BLUE" "🔧 Instalando GNOME Tweaks e extensões..."
    
    apt install -y gnome-tweaks >> "$LOG_FILE" 2>&1 || true
    apt install -y gnome-shell-extensions >> "$LOG_FILE" 2>&1 || true
    
    # Extension manager pode ter nome diferente em versões diferentes
    if apt-cache show gnome-shell-extension-manager &> /dev/null; then
        apt install -y gnome-shell-extension-manager >> "$LOG_FILE" 2>&1 || true
    elif apt-cache show gnome-extensions-app &> /dev/null; then
        apt install -y gnome-extensions-app >> "$LOG_FILE" 2>&1 || true
    fi
    
    apt install -y chrome-gnome-shell >> "$LOG_FILE" 2>&1 || true
    
    print_message "$GREEN" "✅ GNOME Tweaks instalado!"
    print_message "$CYAN" "💡 Acesse pelo menu: 'Ajustes' ou 'Tweaks'"
}

#=============================================================================
# SEÇÃO 6: OTIMIZAÇÃO DE BATERIA COM TLP
#=============================================================================

install_tlp() {
    print_section "🔋 SEÇÃO 6/15: OTIMIZANDO BATERIA COM TLP"
    update_progress "TLP - Otimização de Bateria"
    update_progress "TLP - Otimização de Bateria"
    
    print_message "$BLUE" "⚡ Instalando TLP para otimização de energia..."
    
    apt install -y tlp tlp-rdw >> "$LOG_FILE" 2>&1
    
    # Remover conflitos
    systemctl mask systemd-rfkill.service >> "$LOG_FILE" 2>&1
    systemctl mask systemd-rfkill.socket >> "$LOG_FILE" 2>&1
    
    # Iniciar serviço
    systemctl enable tlp >> "$LOG_FILE" 2>&1
    systemctl start tlp >> "$LOG_FILE" 2>&1
    
    # Aplicar configurações
    tlp start >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ TLP instalado e configurado!"
    print_message "$CYAN" "💡 Para verificar status: sudo tlp-stat -s"
    print_message "$CYAN" "💡 Configuração em: /etc/tlp.conf"
}

#=============================================================================
# SEÇÃO 7: FLATPAK E FLATHUB
#=============================================================================

install_flatpak() {
    print_section "📦 SEÇÃO 7/15: CONFIGURANDO FLATPAK E FLATHUB"
    update_progress "Flatpak e Flathub"
    update_progress "Flatpak e Flathub"
    
    print_message "$BLUE" "📦 Instalando Flatpak..."
    apt install -y flatpak >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "🌐 Adicionando repositório Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "🔌 Instalando plugin Flatpak para GNOME Software..."
    apt install -y gnome-software-plugin-flatpak >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Flatpak e Flathub configurados!"
    print_message "$YELLOW" "⚠️  Reinicie o sistema para integração completa"
}

#=============================================================================
# SEÇÃO 8: CODECS MULTIMÍDIA
#=============================================================================

install_codecs() {
    print_section "🎬 SEÇÃO 8/15: INSTALANDO CODECS MULTIMÍDIA"
    update_progress "Codecs Multimídia"
    update_progress "Codecs Multimídia"
    
    print_message "$BLUE" "🎵 Instalando codecs de áudio e vídeo..."
    
    # Aceitar automaticamente a licença do ubuntu-restricted-extras
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
    
    apt install -y ubuntu-restricted-extras >> "$LOG_FILE" 2>&1
    apt install -y libavcodec-extra >> "$LOG_FILE" 2>&1
    apt install -y libdvd-pkg >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "📀 Configurando suporte a DVDs criptografados..."
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure libdvd-pkg >> "$LOG_FILE" 2>&1
    
    # Codecs adicionais
    apt install -y gstreamer1.0-plugins-bad >> "$LOG_FILE" 2>&1
    apt install -y gstreamer1.0-plugins-ugly >> "$LOG_FILE" 2>&1
    apt install -y gstreamer1.0-libav >> "$LOG_FILE" 2>&1
    apt install -y gstreamer1.0-vaapi >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Codecs multimídia instalados!"
    print_message "$GREEN" "✅ Suporte a DVDs criptografados habilitado!"
}

#=============================================================================
# SEÇÃO 9: ORACLE JAVA
#=============================================================================

install_oracle_java() {
    print_section "☕ SEÇÃO 9/15: INSTALANDO ORACLE JAVA"
    
    print_message "$BLUE" "☕ Instalando Oracle Java (OpenJDK)..."
    
    # Instalar OpenJDK (alternativa livre ao Oracle Java)
    apt install -y default-jdk >> "$LOG_FILE" 2>&1
    apt install -y openjdk-21-jdk >> "$LOG_FILE" 2>&1
    
    # Configurar variáveis de ambiente
    local java_home=$(update-alternatives --query java | grep Value | cut -d' ' -f2 | sed 's|/bin/java||')
    
    if [[ -n "$java_home" ]]; then
        cat > /etc/profile.d/java.sh << EOF
export JAVA_HOME=$java_home
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
        chmod +x /etc/profile.d/java.sh
    fi
    
    local java_version=$(java -version 2>&1 | head -n 1)
    
    print_message "$GREEN" "✅ Java instalado com sucesso!"
    print_message "$CYAN" "📋 Versão: $java_version"
    print_message "$CYAN" "📁 JAVA_HOME: $java_home"
}

#=============================================================================
# SEÇÃO 10-17: INSTALAÇÃO DE APLICATIVOS
#=============================================================================

install_google_chrome() {
    print_section "🌐 SEÇÃO 10/15: INSTALANDO GOOGLE CHROME"
    update_progress "Google Chrome"
    
    print_message "$BLUE" "📥 Baixando Google Chrome... [0%]"
    
    cd "$TEMP_DIR"
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome.deb >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "📦 Instalando Google Chrome..."
    apt install -y ./google-chrome.deb >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Google Chrome instalado!"
}

install_vlc() {
    print_section "🎬 SEÇÃO 11/15: INSTALANDO VLC MEDIA PLAYER"
    update_progress "VLC Media Player"
    
    print_message "$BLUE" "📺 Instalando VLC Media Player..."
    apt install -y vlc >> "$LOG_FILE" 2>&1
    apt install -y vlc-plugin-* >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ VLC Media Player instalado!"
}

install_anydesk() {
    print_section "🖥️  SEÇÃO 12/15: INSTALANDO ANYDESK"
    update_progress "AnyDesk"
    
    print_message "$BLUE" "🔑 Adicionando repositório AnyDesk..."
    wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor -o /usr/share/keyrings/anydesk-archive-keyring.gpg >> "$LOG_FILE" 2>&1
    echo "deb [signed-by=/usr/share/keyrings/anydesk-archive-keyring.gpg] http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
    
    apt update >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "📥 Instalando AnyDesk..."
    apt install -y anydesk >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ AnyDesk instalado!"
}

install_thunderbird() {
    print_section "📧 SEÇÃO 13/15: INSTALANDO MOZILLA THUNDERBIRD"
    update_progress "Mozilla Thunderbird"
    
    print_message "$BLUE" "📬 Instalando Mozilla Thunderbird..."
    apt install -y thunderbird >> "$LOG_FILE" 2>&1
    apt install -y thunderbird-locale-pt-br >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Mozilla Thunderbird instalado!"
}

install_warehouse() {
    print_section "🏪 SEÇÃO 14/15: INSTALANDO WAREHOUSE (FLATPAK)"
    update_progress "Warehouse"
    
    print_message "$BLUE" "📦 Instalando Warehouse via Flatpak..."
    flatpak install -y flathub io.github.flattool.Warehouse >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Warehouse instalado!"
    print_message "$CYAN" "💡 Gerenciador de aplicativos Flatpak"
}

install_stacer() {
    print_section "🔧 SEÇÃO 15/15: INSTALANDO FERRAMENTAS DO SISTEMA"
    update_progress "Ferramentas do Sistema"
    
    print_message "$BLUE" "🔧 Instalando Stacer..."
    
    cd "$TEMP_DIR"
    if wget -q --timeout=30 https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb -O stacer.deb >> "$LOG_FILE" 2>&1; then
        apt install -y ./stacer.deb >> "$LOG_FILE" 2>&1 || print_message "$YELLOW" "⚠️  Erro ao instalar Stacer"
        print_message "$GREEN" "✅ Stacer instalado!"
    else
        print_message "$YELLOW" "⚠️  Não foi possível baixar Stacer, pulando..."
    fi
}

install_teamviewer() {
    print_message "$BLUE" "🖥️  Instalando TeamViewer..."
    
    cd "$TEMP_DIR"
    wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O teamviewer.deb >> "$LOG_FILE" 2>&1
    apt install -y ./teamviewer.deb >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ TeamViewer instalado!"
}

install_synaptic() {
    print_message "$BLUE" "📦 Instalando Synaptic Package Manager..."
    apt install -y synaptic >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Synaptic instalado!"
}

#=============================================================================
# SEÇÃO FINAL: LIMPEZA E OTIMIZAÇÃO
#=============================================================================

cleanup_system() {
    print_section "🧹 LIMPEZA E OTIMIZAÇÃO FINAL"
    update_progress "Limpeza Final"
    update_progress "Limpeza Final"
    
    print_message "$BLUE" "🗑️  Removendo pacotes desnecessários..."
    apt autoremove -y >> "$LOG_FILE" 2>&1
    apt autoclean -y >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "🧹 Limpando cache de pacotes..."
    apt clean >> "$LOG_FILE" 2>&1
    
    print_message "$BLUE" "📋 Atualizando base de dados de aplicativos..."
    update-desktop-database >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Sistema limpo e otimizado!"
}

#=============================================================================
# FUNÇÃO PARA EXIBIR RESUMO FINAL
#=============================================================================

show_summary() {
    print_section "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    
    local total_time=$(get_elapsed_time)
    echo -e "${CYAN}⏱️  Tempo total de instalação: ${YELLOW}${total_time}${NC}"
    echo
    cat << "EOF"
    ✓ Sistema totalmente atualizado
    ✓ Idioma configurado para Português BR
    ✓ Instalação com 1 click habilitada
    ✓ GNOME Software instalado
    ✓ GNOME Tweaks configurado
    ✓ TLP otimizando bateria
    ✓ Flatpak e Flathub configurados
    ✓ Codecs multimídia instalados
    ✓ Suporte a DVDs criptografados
    ✓ Java instalado e configurado
    ✓ Todos os aplicativos instalados
EOF
    echo -e "${NC}"
    
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          APLICATIVOS INSTALADOS                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}🌐 Navegadores e Internet:${NC}"
    echo -e "   • Google Chrome"
    echo -e "   • Mozilla Thunderbird (email)"
    echo
    echo -e "${WHITE}🎬 Multimídia:${NC}"
    echo -e "   • VLC Media Player"
    echo -e "   • Codecs completos instalados"
    echo
    echo -e "${WHITE}🖥️  Acesso Remoto:${NC}"
    echo -e "   • AnyDesk"
    echo -e "   • TeamViewer"
    echo
    echo -e "${WHITE}🔧 Ferramentas do Sistema:${NC}"
    echo -e "   • GNOME Tweaks"
    echo -e "   • Warehouse (Flatpak)"
    echo -e "   • Stacer (otimização)"
    echo -e "   • Synaptic (gerenciador de pacotes)"
    echo -e "   • TLP (economia de bateria)"
    echo
    echo -e "${WHITE}☕ Desenvolvimento:${NC}"
    echo -e "   • Oracle Java / OpenJDK"
    echo
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                              PRÓXIMOS PASSOS                                  ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}1.${NC} ${CYAN}Reiniciar o sistema para aplicar todas as configurações:${NC}"
    echo -e "   ${GREEN}sudo reboot${NC}"
    echo
    echo -e "${WHITE}2.${NC} ${CYAN}Após reiniciar, fazer logout e login novamente para aplicar idioma${NC}"
    echo
    echo -e "${WHITE}3.${NC} ${CYAN}Verificar status do TLP (otimização de bateria):${NC}"
    echo -e "   ${GREEN}sudo tlp-stat -s${NC}"
    echo
    echo -e "${WHITE}4.${NC} ${CYAN}Explorar aplicativos Flatpak na Loja GNOME ou com Warehouse${NC}"
    echo
    echo -e "${WHITE}5.${NC} ${CYAN}Personalizar o sistema com GNOME Tweaks${NC}"
    echo
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${CYAN}📋 Log completo da instalação salvo em:${NC}"
    echo -e "   ${WHITE}$LOG_FILE${NC}"
    echo
    echo -e "${CYAN}📚 Para mais informações sobre os aplicativos:${NC}"
    echo -e "   ${WHITE}• Google Chrome: chrome://settings${NC}"
    echo -e "   ${WHITE}• VLC: https://www.videolan.org/vlc/${NC}"
    echo -e "   ${WHITE}• TLP: /etc/tlp.conf${NC}"
    echo
    echo -e "${GREEN}✨ Obrigado por usar este script de pós-instalação!${NC}"
    echo -e "${GREEN}✨ Seu Ubuntu 24.04.4 está pronto para uso!${NC}"
    echo
}

#=============================================================================
# FUNÇÃO PRINCIPAL
#=============================================================================

main() {
    print_header
    
    print_message "$BLUE" "🚀 Iniciando script de pós-instalação Ubuntu 24.04.4..."
    echo
    
    # Verificações iniciais
    check_root
    check_ubuntu_version
    check_internet
    create_temp_dir
    
    echo
    print_message "$YELLOW" "⚠️  ATENÇÃO: Este processo irá instalar vários pacotes e aplicativos"
    print_message "$YELLOW" "⚠️  Tempo estimado: 20-40 minutos (dependendo da velocidade da internet)"
    print_message "$YELLOW" "⚠️  Certifique-se de ter uma conexão estável"
    echo
    print_message "$CYAN" "💡 Deseja continuar? (s/N)"
    read -r continue_install
    
    if [[ "$continue_install" != "s" && "$continue_install" != "S" ]]; then
        print_message "$YELLOW" "⚠️  Instalação cancelada pelo usuário"
        exit 0
    fi
    
    echo
    print_message "$GREEN" "✅ Iniciando instalação..."
    echo
    
    # Executar todas as seções
    update_system
    configure_portuguese
    enable_one_click_install
    install_gnome_software
    install_gnome_tweaks
    install_tlp
    install_flatpak
    install_codecs
    install_oracle_java
    install_google_chrome
    install_vlc
    install_anydesk
    install_thunderbird
    install_warehouse
    install_stacer
    install_teamviewer
    install_synaptic
    cleanup_system
    
    # Exibir resumo final
    show_summary
}

#=============================================================================
# TRATAMENTO DE ERROS
#=============================================================================

error_handler() {
    local line_number=$1
    local last_command=$2
    local exit_code=$3
    
    print_message "$RED" "❌ Erro crítico detectado!"
    print_message "$RED" "   Linha: $line_number"
    print_message "$RED" "   Código de saída: $exit_code"
    print_message "$YELLOW" ""
    print_message "$YELLOW" "📋 DIAGNÓSTICO:"
    print_message "$YELLOW" "   • Verifique o log detalhado: $LOG_FILE"
    print_message "$YELLOW" "   • Execute: tail -n 50 $LOG_FILE"
    print_message "$YELLOW" ""
    print_message "$CYAN" "💡 SOLUÇÃO:"
    print_message "$CYAN" "   1. Verifique sua conexão com a internet"
    print_message "$CYAN" "   2. Execute: sudo apt update"
    print_message "$CYAN" "   3. Execute o script novamente"
    print_message "$CYAN" "   4. Se o problema persistir, execute com debug:"
    print_message "$CYAN" "      Edite o script e descomente a linha: set -x"
    
    exit 1
}

trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

#=============================================================================
# EXECUÇÃO
#=============================================================================

# Executar função principal
main "$@"

# Código de saída
exit 0