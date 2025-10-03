#!/bin/bash

#=============================================================================
# Script para Obter Informações de IP
#=============================================================================
# Descrição: Script para obter e exibir informações completas sobre
#            endereços IP locais e públicos, incluindo informações
#            de geolocalização e conectividade.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix (requer curl)
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x retorna-ip.sh
# 2. Execute o script: ./retorna-ip.sh
# 3. Visualize as informações de IP
#
# FUNCIONALIDADES:
#   • IP público atual
#   • IPs locais de todas as interfaces
#   • Informações de geolocalização
#   • Teste de conectividade
#=============================================================================

# Configurações globais
set -e
LOG_FILE="/tmp/ip-info-$(date +%Y%m%d_%H%M%S).log"

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
    echo -e "${BLUE}      INFORMAÇÕES DE ENDEREÇO IP${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "${CYAN}Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')${NC}\n"
}

get_public_ip() {
    print_message "$YELLOW" "🌐 Obtendo IP público..."
    
    # Tentar diferentes serviços
    local services=("ifconfig.me" "ipinfo.io/ip" "icanhazip.com" "ipecho.net/plain")
    
    for service in "${services[@]}"; do
        if PUBLIC_IP=$(curl -s --max-time 10 "$service" 2>/dev/null); then
            if [[ $PUBLIC_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                print_message "$GREEN" "✓ IP Público: $PUBLIC_IP"
                return 0
            fi
        fi
    done
    
    print_message "$RED" "✗ Não foi possível obter o IP público"
    PUBLIC_IP="N/A"
}

get_local_ips() {
    print_message "$YELLOW" "🏠 Obtendo IPs locais..."
    
    # Método 1: usando ip command
    if command -v ip >/dev/null 2>&1; then
        ip addr show | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | while read line; do
            local ip=$(echo $line | awk '{print $2}' | cut -d/ -f1)
            local interface=$(echo $line | awk '{print $NF}')
            echo -e "   ${GREEN}$interface: $ip${NC}"
        done
    # Método 2: usando ifconfig
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | while read line; do
            local ip=$(echo $line | awk '{print $2}')
            echo -e "   ${GREEN}Local: $ip${NC}"
        done
    else
        print_message "$RED" "✗ Comandos ip/ifconfig não encontrados"
    fi
}

get_geo_info() {
    if [ "$PUBLIC_IP" != "N/A" ]; then
        print_message "$YELLOW" "🌍 Obtendo informações geográficas..."
        
        if GEO_INFO=$(curl -s "ipinfo.io/$PUBLIC_IP/json" 2>/dev/null); then
            echo "$GEO_INFO" | while IFS=: read key value; do
                case $key in
                    *country*) echo -e "   ${CYAN}País: $(echo $value | tr -d '\",' | xargs)${NC}" ;;
                    *region*) echo -e "   ${CYAN}Região: $(echo $value | tr -d '\",' | xargs)${NC}" ;;
                    *city*) echo -e "   ${CYAN}Cidade: $(echo $value | tr -d '\",' | xargs)${NC}" ;;
                    *org*) echo -e "   ${CYAN}Provedor: $(echo $value | tr -d '\",' | xargs)${NC}" ;;
                esac
            done
        else
            print_message "$YELLOW" "⚠ Informações geográficas indisponíveis"
        fi
    fi
}

test_connectivity() {
    print_message "$YELLOW" "🔗 Testando conectividade..."
    
    local test_hosts=("8.8.8.8" "1.1.1.1" "google.com")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
            echo -e "   ${GREEN}✓ $host${NC}"
        else
            echo -e "   ${RED}✗ $host${NC}"
        fi
    done
}

# Execução principal
print_header
get_public_ip
get_local_ips
get_geo_info
test_connectivity

print_message "$GREEN" "\n🎉 Análise de IP concluída!"
print_message "$BLUE" "📄 Log salvo em: $LOG_FILE"