#!/bin/bash

#=============================================================================
# Script: install.sh
# Descrição: Script de instalação e configuração automática da coleção
# Autor: Andre Berger
# Data: $(date '+%d/%m/%Y')
# Versão: 1.0
# Licença: MIT
#=============================================================================

# Configurações do script
set -e  # Sair se qualquer comando falhar
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/shell-scripts-install-$(date '+%Y%m%d_%H%M%S').log"

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
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para imprimir mensagens coloridas
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "$LOG_FILE"
}

# Função para imprimir cabeçalho
print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                     🐚 SHELL BASH SCRIPTS COLLECTION                        ║"
    echo "║                          Instalador Automático                              ║"
    echo "║                              Versão 1.0                                     ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

# Função para verificar sistema operacional
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VERSION=$(lsb_release -sr)
    else
        OS=$(uname -s)
        VERSION=$(uname -r)
    fi
    
    print_message "$CYAN" "🖥️  Sistema detectado: $OS $VERSION"
}

# Função para verificar dependências
check_dependencies() {
    print_message "$BLUE" "🔍 Verificando dependências..."
    
    local missing_deps=()
    local deps=("curl" "wget" "git" "bc" "awk" "sed" "grep")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_message "$YELLOW" "⚠️  Dependências faltando: ${missing_deps[*]}"
        install_dependencies "${missing_deps[@]}"
    else
        print_message "$GREEN" "✅ Todas as dependências estão instaladas"
    fi
}

# Função para instalar dependências
install_dependencies() {
    local deps=("$@")
    print_message "$BLUE" "📦 Instalando dependências: ${deps[*]}"
    
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y "${deps[@]}"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "${deps[@]}"
    elif command -v yum &> /dev/null; then
        sudo yum install -y "${deps[@]}"
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y "${deps[@]}"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm "${deps[@]}"
    else
        print_message "$RED" "❌ Gerenciador de pacotes não suportado!"
        print_message "$YELLOW" "⚠️  Instale manualmente: ${deps[*]}"
        read -p "Pressione ENTER para continuar..."
    fi
}

# Função para configurar permissões
setup_permissions() {
    print_message "$BLUE" "🔐 Configurando permissões de execução..."
    
    local script_count=0
    while IFS= read -r -d '' script; do
        if [[ -f "$script" && "$script" == *.sh ]]; then
            chmod +x "$script"
            ((script_count++))
        fi
    done < <(find "$SCRIPT_DIR" -name "*.sh" -print0)
    
    print_message "$GREEN" "✅ Configuradas permissões para $script_count scripts"
}

# Função para criar links simbólicos
create_symlinks() {
    print_message "$BLUE" "🔗 Deseja criar links simbólicos em /usr/local/bin? (s/N)"
    read -r create_links
    
    if [[ "$create_links" == "s" || "$create_links" == "S" ]]; then
        print_message "$BLUE" "🔗 Criando links simbólicos..."
        
        local created_links=0
        local main_scripts=(
            "backup-diretorio.sh"
            "gerenciar-usuarios.sh"
            "pingar.sh"
            "retorna-ip.sh"
            "procurar-arquivo.sh"
            "verifica-usuario-logado.sh"
        )
        
        for script in "${main_scripts[@]}"; do
            if [[ -f "$SCRIPT_DIR/$script" ]]; then
                local link_name="${script%.sh}"
                if sudo ln -sf "$SCRIPT_DIR/$script" "/usr/local/bin/$link_name" 2>/dev/null; then
                    print_message "$GREEN" "✅ Link criado: $link_name"
                    ((created_links++))
                else
                    print_message "$YELLOW" "⚠️  Falha ao criar link: $link_name"
                fi
            fi
        done
        
        print_message "$GREEN" "✅ Criados $created_links links simbólicos"
        print_message "$CYAN" "💡 Agora você pode executar os scripts de qualquer lugar!"
    fi
}

# Função para instalar Zenity (interface gráfica)
install_zenity() {
    print_message "$BLUE" "🖥️  Deseja instalar Zenity para interfaces gráficas? (s/N)"
    read -r install_zen
    
    if [[ "$install_zen" == "s" || "$install_zen" == "S" ]]; then
        print_message "$BLUE" "📦 Instalando Zenity..."
        
        if command -v apt &> /dev/null; then
            sudo apt install -y zenity
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zenity
        elif command -v yum &> /dev/null; then
            sudo yum install -y zenity
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y zenity
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zenity
        else
            print_message "$YELLOW" "⚠️  Instale Zenity manualmente para usar interfaces gráficas"
        fi
        
        print_message "$GREEN" "✅ Zenity instalado com sucesso"
    fi
}

# Função para verificar integridade
verify_installation() {
    print_message "$BLUE" "🔍 Verificando integridade da instalação..."
    
    local total_scripts=0
    local executable_scripts=0
    
    while IFS= read -r -d '' script; do
        if [[ -f "$script" && "$script" == *.sh ]]; then
            ((total_scripts++))
            if [[ -x "$script" ]]; then
                ((executable_scripts++))
            fi
        fi
    done < <(find "$SCRIPT_DIR" -name "*.sh" -print0)
    
    print_message "$CYAN" "📊 Scripts encontrados: $total_scripts"
    print_message "$CYAN" "📊 Scripts executáveis: $executable_scripts"
    
    if [[ $executable_scripts -eq $total_scripts ]]; then
        print_message "$GREEN" "✅ Instalação verificada com sucesso!"
    else
        print_message "$YELLOW" "⚠️  Alguns scripts podem não estar executáveis"
    fi
}

# Função para exibir menu de testes
show_test_menu() {
    print_message "$BLUE" "🧪 Deseja testar alguns scripts? (s/N)"
    read -r run_tests
    
    if [[ "$run_tests" == "s" || "$run_tests" == "S" ]]; then
        echo
        echo -e "${YELLOW}╔═══════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║            MENU DE TESTES             ║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════╝${NC}"
        echo -e "${WHITE}1.${NC} Testar retorna-ip.sh"
        echo -e "${WHITE}2.${NC} Testar verifica-usuario-logado.sh"
        echo -e "${WHITE}3.${NC} Demonstração Zenity (se instalado)"
        echo -e "${WHITE}4.${NC} Jogar Tetris"
        echo -e "${WHITE}5.${NC} Pular testes"
        echo
        
        read -p "Escolha uma opção (1-5): " test_choice
        
        case $test_choice in
            1)
                print_message "$BLUE" "🌐 Executando teste de IP..."
                if [[ -x "$SCRIPT_DIR/retorna-ip.sh" ]]; then
                    "$SCRIPT_DIR/retorna-ip.sh"
                else
                    print_message "$RED" "❌ Script não encontrado ou não executável"
                fi
                ;;
            2)
                print_message "$BLUE" "👥 Verificando usuários logados..."
                if [[ -x "$SCRIPT_DIR/verifica-usuario-logado.sh" ]]; then
                    "$SCRIPT_DIR/verifica-usuario-logado.sh"
                else
                    print_message "$RED" "❌ Script não encontrado ou não executável"
                fi
                ;;
            3)
                if command -v zenity &> /dev/null; then
                    print_message "$BLUE" "🖥️  Executando demonstração Zenity..."
                    if [[ -x "$SCRIPT_DIR/zenity-demo.sh" ]]; then
                        "$SCRIPT_DIR/zenity-demo.sh"
                    else
                        print_message "$RED" "❌ Script não encontrado ou não executável"
                    fi
                else
                    print_message "$YELLOW" "⚠️  Zenity não está instalado"
                fi
                ;;
            4)
                print_message "$BLUE" "🎮 Iniciando Tetris..."
                if [[ -x "$SCRIPT_DIR/tetris.sh" ]]; then
                    "$SCRIPT_DIR/tetris.sh"
                else
                    print_message "$RED" "❌ Script não encontrado ou não executável"
                fi
                ;;
            5)
                print_message "$CYAN" "⏭️  Pulando testes..."
                ;;
            *)
                print_message "$YELLOW" "⚠️  Opção inválida"
                ;;
        esac
    fi
}

# Função para exibir informações finais
show_final_info() {
    echo
    print_message "$GREEN" "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                              PRÓXIMOS PASSOS                                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}📖 Documentação completa:${NC} cat README.md"
    echo -e "${WHITE}📂 Listar todos os scripts:${NC} ls -la *.sh"
    echo -e "${WHITE}🎮 Jogar Tetris:${NC} ./tetris.sh"
    echo -e "${WHITE}🎮 Jogar Space Invaders:${NC} ./invaders.sh"
    echo -e "${WHITE}💾 Fazer backup:${NC} ./backup-diretorio.sh"
    echo -e "${WHITE}👥 Gerenciar usuários:${NC} sudo ./gerenciar-usuarios.sh"
    echo -e "${WHITE}🌐 Testar conectividade:${NC} ./pingar.sh google.com cloudflare.com 5"
    echo -e "${WHITE}🔍 Buscar arquivos:${NC} ./procurar-arquivo.sh"
    echo -e "${WHITE}📊 Ver IP e rede:${NC} ./retorna-ip.sh"
    echo
    echo -e "${YELLOW}📋 Log da instalação salvo em:${NC} $LOG_FILE"
    echo
}

#=============================================================================
# FUNÇÃO PRINCIPAL
#=============================================================================

main() {
    print_header
    
    print_message "$BLUE" "🚀 Iniciando instalação da Shell Bash Scripts Collection..."
    echo
    
    # Detectar sistema operacional
    detect_os
    echo
    
    # Verificar e instalar dependências
    check_dependencies
    echo
    
    # Configurar permissões
    setup_permissions
    echo
    
    # Criar links simbólicos (opcional)
    create_symlinks
    echo
    
    # Instalar Zenity (opcional)
    install_zenity
    echo
    
    # Verificar instalação
    verify_installation
    echo
    
    # Menu de testes
    show_test_menu
    echo
    
    # Informações finais
    show_final_info
}

#=============================================================================
# EXECUÇÃO
#=============================================================================

# Verificar se o script está sendo executado como root desnecessariamente
if [[ $EUID -eq 0 ]] && [[ "$1" != "--allow-root" ]]; then
    print_message "$YELLOW" "⚠️  Este script não precisa ser executado como root."
    print_message "$CYAN" "💡 Execute: ./install.sh"
    print_message "$CYAN" "💡 Ou se necessário: ./install.sh --allow-root"
    exit 1
fi

# Executar função principal
main "$@"

# Código de saída
print_message "$GREEN" "✅ Instalação finalizada com sucesso!"
exit 0