#!/bin/bash

#=============================================================================
# Script de Análise de Conectividade (Ping)
#=============================================================================
# Descrição: Script para análise comparativa de conectividade entre dois
#            endereços de rede, realizando testes de ping e gerando
#            relatórios detalhados sobre latência, perda de pacotes e
#            qualidade da conexão.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix (requer ping e bc)
# Dependências: ping, bc, awk
#
# ATENÇÃO: Certifique-se de ter conectividade com a internet
#          e que os endereços sejam válidos (IP ou hostname)
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x pingar.sh
# 2. Execute o script com parâmetros:
#    ./pingar.sh [endereco1] [endereco2] [quantidade]
#
# EXEMPLOS DE USO:
#   ./pingar.sh google.com cloudflare.com 10
#   ./pingar.sh 8.8.8.8 1.1.1.1 5
#   ./pingar.sh facebook.com twitter.com 20
#
# PARÂMETROS:
#   endereco1  : Primeiro endereço (IP ou hostname)
#   endereco2  : Segundo endereço (IP ou hostname)
#   quantidade : Número de pacotes a enviar (padrão: 4)
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/tmp/ping-analysis-$(date +%Y%m%d_%H%M%S).log"
REPORT_FILE="ping-report-$(date +%Y%m%d_%H%M%S).txt"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Função para imprimir cabeçalho
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}    ANÁLISE DE CONECTIVIDADE DE REDE${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "${CYAN}Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')${NC}"
    echo -e "${CYAN}Log: $LOG_FILE${NC}"
    echo -e "${CYAN}Relatório: $REPORT_FILE${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

# Função para verificar dependências
check_dependencies() {
    local missing_deps=()
    
    if ! command -v ping >/dev/null 2>&1; then
        missing_deps+=("ping")
    fi
    
    if ! command -v bc >/dev/null 2>&1; then
        missing_deps+=("bc")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_message "$RED" "✗ Dependências não encontradas: ${missing_deps[*]}"
        print_message "$YELLOW" "Para instalar:"
        print_message "$YELLOW" "  Ubuntu/Debian: sudo apt install iputils-ping bc"
        print_message "$YELLOW" "  CentOS/RHEL: sudo yum install iputils bc"
        exit 1
    fi
}

# Função para validar endereço
validate_address() {
    local address=$1
    local name=$2
    
    if [ -z "$address" ]; then
        print_message "$RED" "✗ $name não pode estar vazio!"
        return 1
    fi
    
    # Testar conectividade básica
    if ! ping -c 1 -W 5 "$address" >/dev/null 2>&1; then
        print_message "$RED" "✗ Não foi possível alcançar $name: $address"
        return 1
    fi
    
    return 0
}

# Função para realizar ping e salvar resultado
execute_ping() {
    local address=$1
    local count=$2
    local output_file=$3
    local description=$4
    
    print_message "$YELLOW" "🔄 Pingando $description ($address) com $count pacotes..."
    
    if ping -c "$count" "$address" > "$output_file" 2>&1; then
        print_message "$GREEN" "✓ Ping para $description concluído"
        return 0
    else
        print_message "$RED" "✗ Falha no ping para $description"
        return 1
    fi
}

# Função para extrair estatísticas do ping
extract_stats() {
    local file=$1
    local address=$2
    
    # Verificar se arquivo existe e não está vazio
    if [ ! -s "$file" ]; then
        echo "N/A,N/A,N/A,N/A,N/A,N/A"
        return
    fi
    
    # Extrair dados básicos
    local transmitted=$(grep "packets transmitted" "$file" | awk '{print $1}' || echo "0")
    local received=$(grep "packets transmitted" "$file" | awk '{print $4}' || echo "0")
    local loss_percent=$(grep "packet loss" "$file" | awk '{print $6}' | tr -d '%' || echo "100")
    
    # Extrair tempos RTT se disponível
    local rtt_line=$(grep -E "rtt|round-trip" "$file" | tail -1)
    local min_rtt="N/A"
    local avg_rtt="N/A"
    local max_rtt="N/A"
    
    if [ -n "$rtt_line" ]; then
        # Formato: rtt min/avg/max/mdev = X.XXX/Y.YYY/Z.ZZZ/W.WWW ms
        min_rtt=$(echo "$rtt_line" | awk -F'/' '{print $4}' | tr -d ' ')
        avg_rtt=$(echo "$rtt_line" | awk -F'/' '{print $5}' | tr -d ' ')
        max_rtt=$(echo "$rtt_line" | awk -F'/' '{print $6}' | tr -d ' ')
    fi
    
    echo "$transmitted,$received,$loss_percent,$min_rtt,$avg_rtt,$max_rtt"
}

# Função para gerar relatório detalhado
generate_report() {
    local endereco1=$1
    local endereco2=$2
    local quantidade=$3
    local stats1=$4
    local stats2=$5
    
    {
        echo "==============================================="
        echo "        RELATÓRIO DE ANÁLISE DE PING"
        echo "==============================================="
        echo "Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')"
        echo "Endereço 1: $endereco1"
        echo "Endereço 2: $endereco2"
        echo "Pacotes enviados: $quantidade"
        echo
        
        echo "RESULTADOS DETALHADOS:"
        echo "-----------------------------------------------"
        
        IFS=',' read -r t1 r1 l1 min1 avg1 max1 <<< "$stats1"
        IFS=',' read -r t2 r2 l2 min2 avg2 max2 <<< "$stats2"
        
        printf "%-25s %-15s %-15s\n" "Métrica" "$endereco1" "$endereco2"
        echo "-----------------------------------------------"
        printf "%-25s %-15s %-15s\n" "Pacotes Enviados" "$t1" "$t2"
        printf "%-25s %-15s %-15s\n" "Pacotes Recebidos" "$r1" "$r2"
        printf "%-25s %-15s%% %-15s%%\n" "Perda de Pacotes" "$l1" "$l2"
        printf "%-25s %-15s ms %-15s ms\n" "RTT Mínimo" "$min1" "$min2"
        printf "%-25s %-15s ms %-15s ms\n" "RTT Médio" "$avg1" "$avg2"
        printf "%-25s %-15s ms %-15s ms\n" "RTT Máximo" "$max1" "$max2"
        echo
        
        echo "ANÁLISE COMPARATIVA:"
        echo "-----------------------------------------------"
        
        # Comparar perda de pacotes
        if [ "$l1" != "N/A" ] && [ "$l2" != "N/A" ]; then
            if (( $(echo "$l1 < $l2" | bc -l) )); then
                echo "🏆 Menor perda de pacotes: $endereco1 ($l1%)"
            elif (( $(echo "$l2 < $l1" | bc -l) )); then
                echo "🏆 Menor perda de pacotes: $endereco2 ($l2%)"
            else
                echo "🤝 Perda de pacotes igual: $l1%"
            fi
        fi
        
        # Comparar RTT médio
        if [ "$avg1" != "N/A" ] && [ "$avg2" != "N/A" ]; then
            if (( $(echo "$avg1 < $avg2" | bc -l) )); then
                echo "🏆 Menor latência média: $endereco1 (${avg1}ms)"
            elif (( $(echo "$avg2 < $avg1" | bc -l) )); then
                echo "🏆 Menor latência média: $endereco2 (${avg2}ms)"
            else
                echo "🤝 Latência média igual: ${avg1}ms"
            fi
        fi
        
        echo
        echo "==============================================="
        
    } > "$REPORT_FILE"
}

# Função para exibir ajuda
show_help() {
    print_header
    echo -e "${YELLOW}USO:${NC}"
    echo "  $0 [endereco1] [endereco2] [quantidade]"
    echo
    echo -e "${YELLOW}PARÂMETROS:${NC}"
    echo "  endereco1   Primeiro endereço (IP ou hostname)"
    echo "  endereco2   Segundo endereço (IP ou hostname)"
    echo "  quantidade  Número de pacotes a enviar (padrão: 4)"
    echo
    echo -e "${YELLOW}EXEMPLOS:${NC}"
    echo "  $0 google.com cloudflare.com 10"
    echo "  $0 8.8.8.8 1.1.1.1 5"
    echo "  $0 facebook.com twitter.com"
    echo
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_header

# Verificar dependências
check_dependencies

# Verificar parâmetros
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Definir variáveis
ENDERECO1=${1:-""}
ENDERECO2=${2:-""}
QUANTIDADE=${3:-4}

# Validar entrada interativa se necessário
if [ -z "$ENDERECO1" ]; then
    read -p "Digite o primeiro endereço: " ENDERECO1
fi

if [ -z "$ENDERECO2" ]; then
    read -p "Digite o segundo endereço: " ENDERECO2
fi

if [ -z "$QUANTIDADE" ] || ! [[ "$QUANTIDADE" =~ ^[0-9]+$ ]] || [ "$QUANTIDADE" -lt 1 ]; then
    read -p "Digite a quantidade de pacotes (padrão 4): " TEMP_QUANTIDADE
    QUANTIDADE=${TEMP_QUANTIDADE:-4}
fi

# Validar endereços
print_message "$YELLOW" "🔍 Validando endereços..."
validate_address "$ENDERECO1" "Primeiro endereço" || exit 1
validate_address "$ENDERECO2" "Segundo endereço" || exit 1

print_message "$GREEN" "✓ Ambos os endereços são válidos"

# Arquivos temporários
FILE1="/tmp/ping_${ENDERECO1//[^a-zA-Z0-9]/_}.txt"
FILE2="/tmp/ping_${ENDERECO2//[^a-zA-Z0-9]/_}.txt"

# Executar pings
echo -e "\n${BLUE}=== EXECUTANDO TESTES DE CONECTIVIDADE ===${NC}"
execute_ping "$ENDERECO1" "$QUANTIDADE" "$FILE1" "primeiro endereço"
execute_ping "$ENDERECO2" "$QUANTIDADE" "$FILE2" "segundo endereço"

# Extrair estatísticas
print_message "$YELLOW" "📊 Analisando resultados..."
STATS1=$(extract_stats "$FILE1" "$ENDERECO1")
STATS2=$(extract_stats "$FILE2" "$ENDERECO2")

# Gerar relatório
generate_report "$ENDERECO1" "$ENDERECO2" "$QUANTIDADE" "$STATS1" "$STATS2"

# Exibir resultados na tela
echo -e "\n${BLUE}=== RESULTADOS DA ANÁLISE ===${NC}"
cat "$REPORT_FILE"

print_message "$GREEN" "✓ Análise concluída com sucesso!"
print_message "$BLUE" "📄 Relatório completo salvo em: $PWD/$REPORT_FILE"

# Limpeza
rm -f "$FILE1" "$FILE2" 2>/dev/null || true

echo -e "\n${GREEN}🎉 Script finalizado!${NC}"