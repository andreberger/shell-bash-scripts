#!/bin/bash

#=============================================================================
# Script de Verificação de Usuários Logados
#=============================================================================
# Descrição: Script para monitorar e verificar usuários logados no sistema,
#            fornecendo informações detalhadas sobre sessões ativas,
#            histórico de login e estatísticas de uso.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x verifica-usuario-logado.sh
# 2. Execute o script: ./verifica-usuario-logado.sh
# 3. Escolha as opções do menu para diferentes tipos de verificação
#
# FUNCIONALIDADES:
#   • Usuários atualmente logados
#   • Histórico de logins
#   • Sessões ativas detalhadas
#   • Monitoramento em tempo real
#=============================================================================

# Configurações globais
set -e
LOG_FILE="/tmp/user-check-$(date +%Y%m%d_%H%M%S).log"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

print_header() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}     VERIFICAÇÃO DE USUÁRIOS LOGADOS${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "${CYAN}Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')${NC}\n"
}

show_current_users() {
    print_message "$YELLOW" "👥 Usuários atualmente logados:"
    
    if command -v w >/dev/null 2>&1; then
        w | while read line; do
            echo -e "   ${GREEN}$line${NC}"
        done
    else
        who | while read line; do
            echo -e "   ${GREEN}$line${NC}"
        done
    fi
    
    echo
    print_message "$CYAN" "📊 Resumo:"
    echo "   Total de sessões ativas: $(who | wc -l)"
    echo "   Usuários únicos: $(who | awk '{print $1}' | sort | uniq | wc -l)"
}

show_login_history() {
    print_message "$YELLOW" "📝 Histórico de logins (últimos 10):"
    
    last -10 | while read line; do
        echo -e "   ${CYAN}$line${NC}"
    done
}

show_failed_logins() {
    print_message "$YELLOW" "🚫 Tentativas de login falhadas:"
    
    if [ -f /var/log/auth.log ]; then
        grep "Failed password" /var/log/auth.log | tail -5 | while read line; do
            echo -e "   ${RED}$line${NC}"
        done
    elif [ -f /var/log/secure ]; then
        grep "Failed password" /var/log/secure | tail -5 | while read line; do
            echo -e "   ${RED}$line${NC}"
        done
    else
        print_message "$YELLOW" "⚠ Logs de autenticação não encontrados"
    fi
}

monitor_realtime() {
    print_message "$YELLOW" "🔄 Monitoramento em tempo real (Ctrl+C para sair)..."
    
    while true; do
        clear
        print_header
        show_current_users
        echo -e "\n${YELLOW}Próxima atualização em 5 segundos...${NC}"
        sleep 5
    done
}

# Menu principal
while true; do
    print_header
    
    echo "1. 👥 Usuários atualmente logados"
    echo "2. 📝 Histórico de logins"
    echo "3. 🚫 Tentativas de login falhadas"
    echo "4. 📊 Estatísticas detalhadas"
    echo "5. 🔄 Monitoramento em tempo real"
    echo "6. 🚪 Sair"
    
    read -p "Escolha uma opção: " OPCAO
    
    case $OPCAO in
        1)
            clear
            print_header
            show_current_users
            ;;
        2)
            clear
            print_header
            show_login_history
            ;;
        3)
            clear
            print_header
            show_failed_logins
            ;;
        4)
            clear
            print_header
            show_current_users
            echo
            show_login_history
            echo
            print_message "$CYAN" "💻 Informações do sistema:"
            echo "   Uptime: $(uptime | awk -F, '{print $1}' | awk '{print $3,$4}')"
            echo "   Load average: $(uptime | awk -F'load average:' '{print $2}')"
            ;;
        5)
            monitor_realtime
            ;;
        6)
            print_message "$GREEN" "👋 Saindo..."
            exit 0
            ;;
        *)
            print_message "$RED" "✗ Opção inválida!"
            ;;
    esac
    
    [ $OPCAO -ne 5 ] && read -p "Pressione Enter para continuar..."
done