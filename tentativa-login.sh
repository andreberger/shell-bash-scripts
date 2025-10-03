#!/bin/bash

#=============================================================================
# Script de Análise de Tentativas de Login
#=============================================================================
# Descrição: Script para analisar e monitorar tentativas de login no sistema,
#            identificando padrões suspeitos, ataques de força bruta e
#            gerando relatórios de segurança.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x tentativa-login.sh
# 2. Execute como root: sudo ./tentativa-login.sh
# 3. Analise os relatórios gerados
#
# FUNCIONALIDADES:
#   • Análise de logs de autenticação
#   • Detecção de ataques de força bruta
#   • Relatórios de IPs suspeitos
#   • Estatísticas de segurança
#=============================================================================

# Configurações globais
set -e
LOG_FILE="/tmp/login-analysis-$(date +%Y%m%d_%H%M%S).log"
REPORT_FILE="login-security-report-$(date +%Y%m%d_%H%M%S).txt"

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
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}    ANÁLISE DE TENTATIVAS DE LOGIN${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "${CYAN}Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')${NC}\n"
}

find_auth_logs() {
    local auth_logs=()
    
    # Possíveis localizações dos logs
    local possible_logs=(
        "/var/log/auth.log"
        "/var/log/secure"
        "/var/log/messages"
        "/var/log/syslog"
    )
    
    for log in "${possible_logs[@]}"; do
        if [ -f "$log" ]; then
            auth_logs+=("$log")
        fi
    done
    
    echo "${auth_logs[@]}"
}

analyze_failed_logins() {
    print_message "$YELLOW" "🔍 Analisando tentativas de login falhadas..."
    
    local auth_logs=($(find_auth_logs))
    
    if [ ${#auth_logs[@]} -eq 0 ]; then
        print_message "$RED" "✗ Nenhum log de autenticação encontrado!"
        return 1
    fi
    
    {
        echo "RELATÓRIO DE ANÁLISE DE LOGIN"
        echo "============================="
        echo "Data: $(date '+%d/%m/%Y às %H:%M:%S')"
        echo
        
        for log in "${auth_logs[@]}"; do
            echo "Analisando: $log"
            echo "---------------------------"
            
            # Tentativas SSH falhadas
            if grep -q "Failed password\|Invalid user" "$log" 2>/dev/null; then
                echo "\nTentativas SSH falhadas (últimas 20):"
                grep "Failed password\|Invalid user" "$log" | tail -20
                
                echo "\nIPs com mais tentativas falhadas:"
                grep "Failed password\|Invalid user" "$log" | \
                    awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -10
                
                echo "\nUsuários mais atacados:"
                grep "Failed password" "$log" | \
                    awk '{for(i=1;i<=NF;i++) if($i=="user") print $(i+1)}' | \
                    sort | uniq -c | sort -nr | head -10
                    
            else
                echo "Nenhuma tentativa falhada encontrada em $log"
            fi
            
            echo
        done
        
        echo "============================="
        echo "Relatório gerado em: $(date)"
        
    } > "$REPORT_FILE"
    
    print_message "$GREEN" "✓ Análise concluída!"
    print_message "$BLUE" "📄 Relatório salvo em: $PWD/$REPORT_FILE"
}

show_current_connections() {
    print_message "$YELLOW" "🔗 Conexões SSH ativas:"
    
    if command -v ss >/dev/null 2>&1; then
        ss -tn state established '( dport = :22 or sport = :22 )' | while read line; do
            echo -e "   ${GREEN}$line${NC}"
        done
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tn | grep :22 | grep ESTABLISHED | while read line; do
            echo -e "   ${GREEN}$line${NC}"
        done
    else
        print_message "$YELLOW" "⚠ Comandos ss/netstat não encontrados"
    fi
}

check_suspicious_activity() {
    print_message "$YELLOW" "🚨 Verificando atividade suspeita..."
    
    local auth_logs=($(find_auth_logs))
    local suspicious_found=false
    
    for log in "${auth_logs[@]}"; do
        # Verificar múltiplas tentativas do mesmo IP
        local suspicious_ips=$(grep "Failed password" "$log" 2>/dev/null | \
            awk '{print $(NF-3)}' | sort | uniq -c | awk '$1 > 10 {print $2}' || true)
        
        if [ -n "$suspicious_ips" ]; then
            print_message "$RED" "⚠ IPs suspeitos (>10 tentativas):"
            echo "$suspicious_ips" | while read ip; do
                echo -e "   ${RED}🚫 $ip${NC}"
            done
            suspicious_found=true
        fi
    done
    
    if [ "$suspicious_found" = false ]; then
        print_message "$GREEN" "✓ Nenhuma atividade suspeita detectada"
    fi
}

# Menu principal
while true; do
    print_header
    
    echo "1. 🔍 Analisar tentativas de login falhadas"
    echo "2. 🔗 Mostrar conexões SSH ativas"
    echo "3. 🚨 Verificar atividade suspeita"
    echo "4. 📊 Relatório completo"
    echo "5. 🚪 Sair"
    
    read -p "Escolha uma opção: " OPCAO
    
    case $OPCAO in
        1)
            clear
            print_header
            analyze_failed_logins
            ;;
        2)
            clear
            print_header
            show_current_connections
            ;;
        3)
            clear
            print_header
            check_suspicious_activity
            ;;
        4)
            clear
            print_header
            analyze_failed_logins
            echo
            show_current_connections
            echo
            check_suspicious_activity
            echo
            print_message "$BLUE" "📄 Relatório completo disponível em: $PWD/$REPORT_FILE"
            ;;
        5)
            print_message "$GREEN" "👋 Saindo..."
            exit 0
            ;;
        *)
            print_message "$RED" "✗ Opção inválida!"
            ;;
    esac
    
    read -p "Pressione Enter para continuar..."
done