#!/bin/bash

#=============================================================================
# Script: monitor_exec.sh
# Descrição: Monitor de execução de processos e sistema
#            Parte do sistema SISBKT2G2 v2.0SBE
# Autores: Andre Kroetz Berger, Daniel Meyer, Edivaldo Cezar, Felipe Matias
# Data: 03/10/2025
# Versão: 2.0
# Licença: MIT
# Compatibilidade: Ubuntu 18+, CentOS 7+, Fedora 30+
#=============================================================================

# Configurações do script
set -e  # Sair se qualquer comando falhar
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/monitor_exec.log"
readonly PID_FILE="/var/run/monitor_exec.pid"

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
# 1. Tornar executável:
#    chmod +x monitor_exec.sh
#
# 2. Executar em modo interativo:
#    ./monitor_exec.sh
#
# 3. Executar em modo daemon:
#    ./monitor_exec.sh --daemon
#
# 4. Parar o daemon:
#    ./monitor_exec.sh --stop
#
# 5. Ver status:
#    ./monitor_exec.sh --status
#
# 6. Ver logs:
#    tail -f /var/log/monitor_exec.log
#=============================================================================

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para log de operações
log_message() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] - $message" | tee -a "$LOG_FILE"
}

# Função para mostrar uso do script
show_usage() {
    echo -e "${CYAN}Uso: $0 [OPÇÃO]${NC}"
    echo
    echo -e "${WHITE}Opções:${NC}"
    echo -e "  ${GREEN}--daemon${NC}     Executar como daemon em segundo plano"
    echo -e "  ${GREEN}--stop${NC}       Parar daemon em execução"
    echo -e "  ${GREEN}--status${NC}     Mostrar status do daemon"
    echo -e "  ${GREEN}--help${NC}       Mostrar esta ajuda"
    echo -e "  ${GREEN}sem opção${NC}    Executar em modo interativo"
    echo
    echo -e "${YELLOW}Exemplos:${NC}"
    echo -e "  $0                 # Modo interativo"
    echo -e "  $0 --daemon        # Executar como daemon"
    echo -e "  $0 --stop          # Parar daemon"
    echo
}

# Função para verificar se está rodando como daemon
is_daemon_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        else
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Função para mostrar status do daemon
show_daemon_status() {
    if is_daemon_running; then
        local pid uptime
        pid=$(cat "$PID_FILE")
        uptime=$(ps -o etime= -p "$pid" 2>/dev/null | xargs)
        
        echo -e "${GREEN}✅ Monitor daemon está executando${NC}"
        echo -e "${CYAN}📋 PID: $pid${NC}"
        echo -e "${CYAN}⏱️  Uptime: $uptime${NC}"
        echo -e "${CYAN}📄 Log: $LOG_FILE${NC}"
    else
        echo -e "${RED}❌ Monitor daemon não está executando${NC}"
    fi
}

# Função para parar daemon
stop_daemon() {
    if is_daemon_running; then
        local pid
        pid=$(cat "$PID_FILE")
        
        echo -e "${YELLOW}🛑 Parando monitor daemon (PID: $pid)...${NC}"
        kill "$pid" 2>/dev/null
        
        # Aguardar processo terminar
        local count=0
        while kill -0 "$pid" 2>/dev/null && [[ $count -lt 10 ]]; do
            sleep 1
            ((count++))
        done
        
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${RED}⚠️  Forçando parada do processo...${NC}"
            kill -9 "$pid" 2>/dev/null
        fi
        
        rm -f "$PID_FILE"
        echo -e "${GREEN}✅ Monitor daemon parado${NC}"
        log_message "INFO" "Monitor daemon parado"
    else
        echo -e "${YELLOW}⚠️  Monitor daemon não estava executando${NC}"
    fi
}

#=============================================================================
# FUNÇÕES DE MONITORAMENTO
#=============================================================================

# Função para monitorar CPU
monitor_cpu_usage() {
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
    
    echo "CPU: ${cpu_usage}%"
    
    # Alerta se CPU > 80%
    if (( $(echo "$cpu_usage > 80" | bc -l 2>/dev/null || echo 0) )); then
        log_message "WARN" "Alto uso de CPU: ${cpu_usage}%"
    fi
    
    echo "$cpu_usage"
}

# Função para monitorar memória
monitor_memory_usage() {
    local mem_usage
    mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    
    echo "RAM: ${mem_usage}%"
    
    # Alerta se memória > 85%
    if (( $(echo "$mem_usage > 85" | bc -l 2>/dev/null || echo 0) )); then
        log_message "WARN" "Alto uso de memória: ${mem_usage}%"
    fi
    
    echo "$mem_usage"
}

# Função para monitorar disco
monitor_disk_usage() {
    local disk_usage
    disk_usage=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
    
    echo "Disco: ${disk_usage}%"
    
    # Alerta se disco > 90%
    if [[ $disk_usage -gt 90 ]]; then
        log_message "WARN" "Alto uso de disco: ${disk_usage}%"
    fi
    
    echo "$disk_usage"
}

# Função para monitorar load average
monitor_load_average() {
    local load_avg
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    
    echo "Load: $load_avg"
    
    # Alerta se load > número de CPUs * 2
    local cpu_count
    cpu_count=$(nproc)
    local threshold=$((cpu_count * 2))
    
    if (( $(echo "$load_avg > $threshold" | bc -l 2>/dev/null || echo 0) )); then
        log_message "WARN" "Load average alto: $load_avg (threshold: $threshold)"
    fi
    
    echo "$load_avg"
}

# Função para monitorar processos críticos
monitor_critical_processes() {
    local critical_procs=("sshd" "systemd" "init")
    local down_procs=()
    
    for proc in "${critical_procs[@]}"; do
        if ! pgrep "$proc" > /dev/null; then
            down_procs+=("$proc")
        fi
    done
    
    if [[ ${#down_procs[@]} -gt 0 ]]; then
        log_message "ERROR" "Processos críticos inativos: ${down_procs[*]}"
        echo "⚠️ Processos críticos inativos: ${down_procs[*]}"
    fi
}

# Função para coletar estatísticas completas
collect_system_stats() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local cpu_usage mem_usage disk_usage load_avg
    cpu_usage=$(monitor_cpu_usage)
    mem_usage=$(monitor_memory_usage)
    disk_usage=$(monitor_disk_usage)
    load_avg=$(monitor_load_average)
    
    # Log das estatísticas
    log_message "STATS" "CPU:${cpu_usage}% MEM:${mem_usage}% DISK:${disk_usage}% LOAD:${load_avg}"
    
    # Verificar processos críticos
    monitor_critical_processes
    
    # Retornar dados para exibição
    echo "$timestamp|$cpu_usage|$mem_usage|$disk_usage|$load_avg"
}

#=============================================================================
# MODOS DE EXECUÇÃO
#=============================================================================

# Função para modo daemon
run_daemon() {
    echo -e "${BLUE}🚀 Iniciando monitor em modo daemon...${NC}"
    
    # Verificar se já está rodando
    if is_daemon_running; then
        echo -e "${YELLOW}⚠️  Monitor daemon já está executando${NC}"
        show_daemon_status
        exit 1
    fi
    
    # Executar em background
    nohup bash -c "
        echo \$\$ > '$PID_FILE'
        
        log_message() {
            echo \"\$(date '+%Y-%m-%d %H:%M:%S') [\$1] - \$2\" >> '$LOG_FILE'
        }
        
        log_message 'INFO' 'Monitor daemon iniciado (PID: \$\$)'
        
        while true; do
            # Coletar estatísticas
            cpu_usage=\$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100-\$1}')
            mem_usage=\$(free | grep Mem | awk '{printf \"%.1f\", \$3/\$2 * 100.0}')
            disk_usage=\$(df / | awk 'NR==2{print \$5}' | sed 's/%//')
            load_avg=\$(uptime | awk -F'load average:' '{print \$2}' | awk '{print \$1}' | sed 's/,//')
            
            # Log estatísticas
            log_message 'STATS' \"CPU:\${cpu_usage}% MEM:\${mem_usage}% DISK:\${disk_usage}% LOAD:\${load_avg}\"
            
            # Verificar alertas
            if (( \$(echo \"\$cpu_usage > 80\" | bc -l 2>/dev/null || echo 0) )); then
                log_message 'WARN' \"Alto uso de CPU: \${cpu_usage}%\"
            fi
            
            if (( \$(echo \"\$mem_usage > 85\" | bc -l 2>/dev/null || echo 0) )); then
                log_message 'WARN' \"Alto uso de memória: \${mem_usage}%\"
            fi
            
            if [[ \$disk_usage -gt 90 ]]; then
                log_message 'WARN' \"Alto uso de disco: \${disk_usage}%\"
            fi
            
            sleep 60  # Coletar dados a cada minuto
        done
    " > /dev/null 2>&1 &
    
    sleep 2
    
    if is_daemon_running; then
        echo -e "${GREEN}✅ Monitor daemon iniciado com sucesso${NC}"
        show_daemon_status
        log_message "INFO" "Monitor daemon iniciado via CLI"
    else
        echo -e "${RED}❌ Erro ao iniciar monitor daemon${NC}"
        exit 1
    fi
}

# Função para modo interativo
run_interactive() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          📊 MONITOR DE EXECUÇÃO                               ║"
    echo "║                               Modo Interativo                                 ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}Pressione Ctrl+C para sair${NC}"
    echo
    
    log_message "INFO" "Monitor interativo iniciado"
    
    # Loop principal
    local count=1
    while true; do
        clear
        echo -e "${PURPLE}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}                          📊 MONITOR DE EXECUÇÃO - $(date)${NC}"
        echo -e "${PURPLE}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo
        
        # Coletar dados
        echo -e "${BLUE}🔄 Coletando dados do sistema...${NC}"
        local stats cpu mem disk load
        stats=$(collect_system_stats)
        IFS='|' read -r timestamp cpu mem disk load <<< "$stats"
        
        echo
        echo -e "${GREEN}📈 RECURSOS DO SISTEMA:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        
        # Barra de CPU
        echo -e "${CYAN}💻 CPU Usage: ${WHITE}${cpu}%${NC}"
        print_progress_bar "$cpu" 100
        echo
        
        # Barra de Memória
        echo -e "${CYAN}🧠 Memory Usage: ${WHITE}${mem}%${NC}"
        print_progress_bar "$mem" 100
        echo
        
        # Barra de Disco
        echo -e "${CYAN}💾 Disk Usage: ${WHITE}${disk}%${NC}"
        print_progress_bar "$disk" 100
        echo
        
        # Load Average
        echo -e "${CYAN}⚖️  Load Average: ${WHITE}${load}${NC}"
        echo
        
        # Processos top
        echo -e "${GREEN}🔝 TOP PROCESSOS (CPU):${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        ps aux --sort=-%cpu | head -6 | awk 'NR==1{print $0} NR>1{printf "%-12s %5s %5s %s\n", $1, $3, $4, $11}'
        echo
        
        # Informações do sistema
        echo -e "${GREEN}ℹ️  INFORMAÇÕES DO SISTEMA:${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}Hostname: ${WHITE}$(hostname)${NC}"
        echo -e "${CYAN}Uptime: ${WHITE}$(uptime -p)${NC}"
        echo -e "${CYAN}Usuários logados: ${WHITE}$(who | wc -l)${NC}"
        echo -e "${CYAN}Atualização #: ${WHITE}$count${NC}"
        
        echo
        echo -e "${YELLOW}Próxima atualização em 5 segundos... (Ctrl+C para sair)${NC}"
        
        sleep 5
        ((count++))
    done
}

# Função para desenhar barra de progresso
print_progress_bar() {
    local value=$1
    local max=$2
    local width=50
    
    # Calcular porcentagem e caracteres preenchidos
    local percentage=$((value * 100 / max))
    local filled=$((value * width / max))
    
    # Determinar cor baseada na porcentagem
    local color
    if [[ $percentage -lt 50 ]]; then
        color="$GREEN"
    elif [[ $percentage -lt 75 ]]; then
        color="$YELLOW"
    else
        color="$RED"
    fi
    
    # Construir barra
    printf "  ["
    printf "%s" "$color"
    printf "%-${filled}s" | tr ' ' '█'
    printf "%s" "$NC"
    printf "%-$((width - filled))s" | tr ' ' '░'
    printf "] %3d%%\n" "$percentage"
}

#=============================================================================
# TRATAMENTO DE SINAIS
#=============================================================================

# Função para cleanup ao sair
cleanup_on_exit() {
    echo
    echo -e "${YELLOW}🛑 Monitor interrompido pelo usuário${NC}"
    log_message "INFO" "Monitor interativo finalizado"
    exit 0
}

# Registrar handler para SIGINT (Ctrl+C)
trap cleanup_on_exit SIGINT

#=============================================================================
# FUNÇÃO PRINCIPAL
#=============================================================================

main() {
    # Verificar argumentos
    case "${1:-}" in
        --daemon)
            run_daemon
            ;;
        --stop)
            stop_daemon
            ;;
        --status)
            show_daemon_status
            ;;
        --help|-h)
            show_usage
            ;;
        "")
            run_interactive
            ;;
        *)
            echo -e "${RED}❌ Opção inválida: $1${NC}"
            echo
            show_usage
            exit 1
            ;;
    esac
}

#=============================================================================
# EXECUÇÃO
#=============================================================================

# Verificar se bc está disponível (para cálculos decimais)
if ! command -v bc &> /dev/null; then
    echo -e "${YELLOW}⚠️  Pacote 'bc' não encontrado. Alguns cálculos podem não funcionar.${NC}"
fi

# Executar função principal
main "$@"

# Código de saída
exit 0