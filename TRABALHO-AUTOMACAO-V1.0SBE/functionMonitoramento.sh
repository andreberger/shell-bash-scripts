#!/bin/bash

#=============================================================================
# Script: functionMonitoramento.sh
# Descrição: Módulo de funções para monitoramento do sistema
#            Parte do sistema SISBKT2G2 v2.0SBE
# Autores: Andre Kroetz Berger, Daniel Meyer, Edivaldo Cezar, Felipe Matias
# Data: 03/10/2025
# Versão: 2.0
# Licença: MIT
# Compatibilidade: Ubuntu 18+, CentOS 7+, Fedora 30+
#=============================================================================

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
# FUNÇÕES DE MONITORAMENTO DE SISTEMA
#=============================================================================

# Função para monitorar CPU
monitor_cpu() {
    local temp_file="/tmp/cpu_monitor.txt"
    
    {
        echo "MONITORAMENTO DE CPU"
        echo "===================="
        echo
        echo "Informações do Processador:"
        echo "---------------------------"
        lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|Socket"
        echo
        echo "Uso atual da CPU:"
        echo "-----------------"
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU Usage: " 100-$1 "%"}'
        echo
        echo "Processos que mais consomem CPU:"
        echo "--------------------------------"
        ps aux --sort=-%cpu | head -11
        echo
        echo "Load Average:"
        echo "-------------"
        uptime
    } > "$temp_file"
    
    dialog \
        --title 'MONITORAMENTO - CPU' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para monitorar memória
monitor_memory() {
    local temp_file="/tmp/memory_monitor.txt"
    
    {
        echo "MONITORAMENTO DE MEMÓRIA"
        echo "========================"
        echo
        echo "Uso de Memória:"
        echo "---------------"
        free -h
        echo
        echo "Processos que mais consomem memória:"
        echo "------------------------------------"
        ps aux --sort=-%mem | head -11
        echo
        echo "Informações detalhadas:"
        echo "----------------------"
        cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree"
    } > "$temp_file"
    
    dialog \
        --title 'MONITORAMENTO - MEMÓRIA' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para monitorar disco
monitor_disk() {
    local temp_file="/tmp/disk_monitor.txt"
    
    {
        echo "MONITORAMENTO DE DISCO"
        echo "======================"
        echo
        echo "Uso do espaço em disco:"
        echo "----------------------"
        df -h
        echo
        echo "Inodes utilizados:"
        echo "------------------"
        df -i
        echo
        echo "Diretórios que mais ocupam espaço:"
        echo "----------------------------------"
        du -h / 2>/dev/null | sort -rh | head -10
    } > "$temp_file"
    
    dialog \
        --title 'MONITORAMENTO - DISCO' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para monitorar rede
monitor_network() {
    local temp_file="/tmp/network_monitor.txt"
    
    {
        echo "MONITORAMENTO DE REDE"
        echo "====================="
        echo
        echo "Interfaces de rede:"
        echo "------------------"
        ip addr show
        echo
        echo "Conexões ativas:"
        echo "----------------"
        netstat -tuln | head -20
        echo
        echo "Estatísticas de rede:"
        echo "--------------------"
        cat /proc/net/dev
    } > "$temp_file"
    
    dialog \
        --title 'MONITORAMENTO - REDE' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para monitorar serviços
monitor_services() {
    local temp_file="/tmp/services_monitor.txt"
    
    {
        echo "MONITORAMENTO DE SERVIÇOS"
        echo "========================="
        echo
        echo "Serviços ativos:"
        echo "---------------"
        systemctl list-units --type=service --state=active | head -20
        echo
        echo "Serviços com falha:"
        echo "------------------"
        systemctl list-units --type=service --state=failed
        echo
        echo "Serviços críticos:"
        echo "-----------------"
        for service in sshd apache2 nginx mysql mariadb postgresql; do
            if systemctl is-active --quiet $service 2>/dev/null; then
                echo "✅ $service: ATIVO"
            else
                echo "❌ $service: INATIVO"
            fi
        done
    } > "$temp_file"
    
    dialog \
        --title 'MONITORAMENTO - SERVIÇOS' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para relatório completo do sistema
system_report() {
    local temp_file="/tmp/system_report.txt"
    
    {
        echo "RELATÓRIO COMPLETO DO SISTEMA"
        echo "=============================="
        echo "Gerado em: $(date)"
        echo
        echo "INFORMAÇÕES GERAIS:"
        echo "------------------"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime)"
        echo "Sistema: $(uname -a)"
        echo "Usuários logados: $(who | wc -l)"
        echo
        echo "RECURSOS DO SISTEMA:"
        echo "-------------------"
        echo "CPU: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
        echo "Memória Total: $(free -h | grep Mem | awk '{print $2}')"
        echo "Memória Livre: $(free -h | grep Mem | awk '{print $7}')"
        echo "Disco /: $(df -h / | awk 'NR==2{print $4" livres de "$2}')"
        echo
        echo "ALERTAS:"
        echo "--------"
        
        # Verificar uso de CPU
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
        if (( $(echo "$cpu_usage > 80" | bc -l) )); then
            echo "⚠️  CPU com uso alto: ${cpu_usage}%"
        fi
        
        # Verificar uso de memória
        mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
        if [[ $mem_usage -gt 80 ]]; then
            echo "⚠️  Memória com uso alto: ${mem_usage}%"
        fi
        
        # Verificar uso de disco
        disk_usage=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
        if [[ $disk_usage -gt 80 ]]; then
            echo "⚠️  Disco com uso alto: ${disk_usage}%"
        fi
        
        # Verificar serviços críticos com falha
        failed_services=$(systemctl list-units --type=service --state=failed --no-legend | wc -l)
        if [[ $failed_services -gt 0 ]]; then
            echo "⚠️  Serviços com falha: $failed_services"
        fi
        
        echo
        echo "PROCESSOS TOP (CPU):"
        echo "-------------------"
        ps aux --sort=-%cpu | head -6
        echo
        echo "PROCESSOS TOP (MEMÓRIA):"
        echo "-----------------------"
        ps aux --sort=-%mem | head -6
        
    } > "$temp_file"
    
    dialog \
        --title 'RELATÓRIO DO SISTEMA' \
        --textbox "$temp_file" \
        25 90
    
    rm -f "$temp_file"
}

# Função para monitoramento em tempo real
real_time_monitor() {
    dialog \
        --title 'MONITORAMENTO EM TEMPO REAL' \
        --msgbox 'O monitoramento em tempo real será iniciado.\n\nUse Ctrl+C para sair.\n\nPressione OK para continuar.' \
        8 50
    
    clear
    echo -e "${GREEN}=== MONITORAMENTO EM TEMPO REAL ===${NC}"
    echo -e "${CYAN}Pressione Ctrl+C para sair${NC}"
    echo
    
    while true; do
        clear
        echo -e "${GREEN}=== MONITORAMENTO EM TEMPO REAL ===${NC}"
        echo -e "${CYAN}$(date)${NC}"
        echo
        
        echo -e "${YELLOW}CPU:${NC}"
        top -bn1 | grep "Cpu(s)"
        echo
        
        echo -e "${YELLOW}MEMÓRIA:${NC}"
        free -h | grep -E "Mem|Swap"
        echo
        
        echo -e "${YELLOW}DISCO:${NC}"
        df -h / | grep -v Filesystem
        echo
        
        echo -e "${YELLOW}LOAD AVERAGE:${NC}"
        uptime
        echo
        
        echo -e "${YELLOW}TOP PROCESSOS (CPU):${NC}"
        ps aux --sort=-%cpu | head -6
        
        sleep 5
    done
}

# Função para configurar alertas
configure_alerts() {
    local alert_config="/etc/system-alerts.conf"
    
    local cpu_threshold memory_threshold disk_threshold
    
    cpu_threshold=$(dialog --stdout \
        --title 'CONFIGURAR ALERTAS' \
        --inputbox 'Limite de CPU para alerta (%)' \
        8 40 "80")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    memory_threshold=$(dialog --stdout \
        --title 'CONFIGURAR ALERTAS' \
        --inputbox 'Limite de memória para alerta (%)' \
        8 40 "80")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    disk_threshold=$(dialog --stdout \
        --title 'CONFIGURAR ALERTAS' \
        --inputbox 'Limite de disco para alerta (%)' \
        8 40 "80")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Salvar configuração
    {
        echo "# Configuração de alertas do sistema"
        echo "CPU_THRESHOLD=$cpu_threshold"
        echo "MEMORY_THRESHOLD=$memory_threshold"
        echo "DISK_THRESHOLD=$disk_threshold"
        echo "ALERT_EMAIL=${USER}@localhost"
    } > "$alert_config"
    
    dialog \
        --title 'ALERTAS CONFIGURADOS' \
        --msgbox "Alertas configurados com sucesso!\n\nCPU: ${cpu_threshold}%\nMemória: ${memory_threshold}%\nDisco: ${disk_threshold}%\n\nConfiguração salva em:\n$alert_config" \
        12 60
}

# Função para verificar logs do sistema
check_system_logs() {
    local log_type
    log_type=$(dialog --stdout \
        --title 'LOGS DO SISTEMA' \
        --menu 'Selecione o tipo de log:' \
        12 50 6 \
        1 'Syslog (geral)' \
        2 'Auth (autenticação)' \
        3 'Kern (kernel)' \
        4 'Boot (inicialização)' \
        5 'Apache/Nginx' \
        6 'MySQL/MariaDB')
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local log_file temp_file="/tmp/system_logs.txt"
    
    case "$log_type" in
        1) 
            log_file="/var/log/syslog"
            [[ ! -f "$log_file" ]] && log_file="/var/log/messages"
            ;;
        2) 
            log_file="/var/log/auth.log"
            [[ ! -f "$log_file" ]] && log_file="/var/log/secure"
            ;;
        3) 
            log_file="/var/log/kern.log"
            [[ ! -f "$log_file" ]] && log_file="/var/log/dmesg"
            ;;
        4)
            journalctl -b > "$temp_file"
            log_file="$temp_file"
            ;;
        5)
            for file in /var/log/apache2/error.log /var/log/nginx/error.log /var/log/httpd/error_log; do
                if [[ -f "$file" ]]; then
                    log_file="$file"
                    break
                fi
            done
            ;;
        6)
            for file in /var/log/mysql/error.log /var/log/mariadb/mariadb.log; do
                if [[ -f "$file" ]]; then
                    log_file="$file"
                    break
                fi
            done
            ;;
    esac
    
    if [[ -f "$log_file" ]]; then
        dialog \
            --title "LOG: $(basename "$log_file")" \
            --textbox "$log_file" \
            20 80
    else
        dialog \
            --title 'LOG NÃO ENCONTRADO' \
            --msgbox 'O arquivo de log selecionado não foi encontrado.' \
            6 50
    fi
    
    [[ "$log_file" == "$temp_file" ]] && rm -f "$temp_file"
}

# Função de limpeza
cleanup_temp_files_monitor() {
    rm -f /tmp/cpu_monitor.txt /tmp/memory_monitor.txt /tmp/disk_monitor.txt \
         /tmp/network_monitor.txt /tmp/services_monitor.txt /tmp/system_report.txt \
         /tmp/system_logs.txt 2>/dev/null
}

# Registrar cleanup para ser executado ao sair
trap cleanup_temp_files_monitor EXIT