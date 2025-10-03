#!/bin/bash

#=============================================================================
# Script: telasSistema.sh
# Descrição: Módulo de telas e menus do sistema SISBKT2G2
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
# TELAS DE GERENCIAMENTO DE USUÁRIOS
#=============================================================================

# Menu principal de usuários
tela_menu_user() {
    while true; do
        local user_menu
        user_menu=$(dialog --stdout \
            --title 'GERENCIAMENTO DE USUÁRIOS' \
            --backtitle 'SISBKT2G2 - Sistema de Automação' \
            --menu 'Selecione uma opção:' \
            15 60 8 \
            1 'Listar usuários do sistema' \
            2 'Adicionar novo usuário' \
            3 'Buscar usuário específico' \
            4 'Alterar dados de usuário' \
            5 'Remover usuário' \
            6 'Estatísticas de usuários' \
            7 'Usuários logados' \
            0 'Voltar ao menu principal' \
            2>&1 >/dev/tty)
        
        # Verificar se usuário cancelou
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$user_menu" in
            1) listarUsuario ;;
            2) adicionarUsuario ;;
            3) buscarUsuario ;;
            4) alteraUsuario ;;
            5) deletaUsuario ;;
            6) mostrar_estatisticas_usuarios ;;
            7) show_logged_users ;;
            0) break ;;
        esac
    done
}

# Função para mostrar usuários logados
show_logged_users() {
    local temp_file="/tmp/logged_users.txt"
    
    {
        echo "USUÁRIOS LOGADOS NO SISTEMA"
        echo "============================"
        echo "Data/Hora: $(date)"
        echo
        echo "SESSÕES ATIVAS:"
        echo "---------------"
        who -u
        echo
        echo "ÚLTIMO ACESSO:"
        echo "--------------"
        last -n 15
        echo
        echo "ESTATÍSTICAS:"
        echo "-------------"
        echo "Total de sessões ativas: $(who | wc -l)"
        echo "Usuários únicos logados: $(who | cut -d' ' -f1 | sort -u | wc -l)"
        echo "Uptime do sistema: $(uptime -p)"
    } > "$temp_file"
    
    dialog \
        --title 'USUÁRIOS LOGADOS' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

#=============================================================================
# TELAS DE BACKUP MYSQL
#=============================================================================

# Menu principal de backup
tela_backup_mysql() {
    while true; do
        local backup_menu
        backup_menu=$(dialog --stdout \
            --title 'SISTEMA DE BACKUP MYSQL' \
            --backtitle 'SISBKT2G2 - Sistema de Automação' \
            --menu 'Selecione uma opção:' \
            15 60 7 \
            1 'Executar backup agora' \
            2 'Agendar backup' \
            3 'Ver log de backups' \
            4 'Listar agendamentos' \
            5 'Gerenciar arquivos de backup' \
            6 'Configurar credenciais' \
            0 'Voltar ao menu principal' \
            2>&1 >/dev/tty)
        
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$backup_menu" in
            1) backup_mysql ;;
            2) schedule_backup ;;
            3) ver_log_backup ;;
            4) list_scheduled_backups ;;
            5) manage_backup_files ;;
            6) configure_mysql_credentials ;;
            0) break ;;
        esac
    done
}

# Função para configurar credenciais MySQL
configure_mysql_credentials() {
    dialog \
        --title 'CONFIGURAR CREDENCIAIS' \
        --msgbox 'Esta função permite configurar as credenciais\nde acesso ao MySQL/MariaDB para backup.' \
        8 50
    
    # Remover configuração existente se solicitado
    if [[ -f "/etc/mysql-backup.conf" ]]; then
        dialog --yesno "Configuração existente encontrada.\n\nDeseja reconfigurá-la?" \
            7 50
        
        if [[ $? -eq 0 ]]; then
            rm -f "/etc/mysql-backup.conf"
        else
            return 0
        fi
    fi
    
    # Forçar nova configuração na próxima execução
    get_mysql_credentials
}

#=============================================================================
# TELAS DE MONITORAMENTO
#=============================================================================

# Menu principal de monitoramento
tela_monitor_server() {
    while true; do
        local monitor_menu
        monitor_menu=$(dialog --stdout \
            --title 'MONITORAMENTO DO SISTEMA' \
            --backtitle 'SISBKT2G2 - Sistema de Automação' \
            --menu 'Selecione o que deseja monitorar:' \
            16 60 9 \
            1 'CPU e Processamento' \
            2 'Memória RAM' \
            3 'Espaço em Disco' \
            4 'Rede e Conectividade' \
            5 'Serviços do Sistema' \
            6 'Relatório Completo' \
            7 'Monitoramento em Tempo Real' \
            8 'Logs do Sistema' \
            9 'Configurar Alertas' \
            0 'Voltar ao menu principal' \
            2>&1 >/dev/tty)
        
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$monitor_menu" in
            1) monitor_cpu ;;
            2) monitor_memory ;;
            3) monitor_disk ;;
            4) monitor_network ;;
            5) monitor_services ;;
            6) system_report ;;
            7) real_time_monitor ;;
            8) check_system_logs ;;
            9) configure_alerts ;;
            0) break ;;
        esac
    done
}

#=============================================================================
# TELAS DE CONFIGURAÇÃO E UTILITÁRIOS
#=============================================================================

# Menu de ferramentas administrativas
tela_ferramentas_admin() {
    while true; do
        local admin_menu
        admin_menu=$(dialog --stdout \
            --title 'FERRAMENTAS ADMINISTRATIVAS' \
            --backtitle 'SISBKT2G2 - Sistema de Automação' \
            --menu 'Selecione uma ferramenta:' \
            14 60 7 \
            1 'Informações do Sistema' \
            2 'Processos em Execução' \
            3 'Conexões de Rede' \
            4 'Espaço em Disco Detalhado' \
            5 'Variáveis de Ambiente' \
            6 'Módulos do Kernel' \
            0 'Voltar ao menu principal' \
            2>&1 >/dev/tty)
        
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$admin_menu" in
            1) show_system_info ;;
            2) show_processes ;;
            3) show_network_connections ;;
            4) show_detailed_disk_usage ;;
            5) show_environment_vars ;;
            6) show_kernel_modules ;;
            0) break ;;
        esac
    done
}

# Função para mostrar informações do sistema
show_system_info() {
    local temp_file="/tmp/system_info.txt"
    
    {
        echo "INFORMAÇÕES DETALHADAS DO SISTEMA"
        echo "=================================="
        echo
        echo "SISTEMA OPERACIONAL:"
        echo "-------------------"
        if [[ -f /etc/os-release ]]; then
            cat /etc/os-release
        else
            uname -a
        fi
        echo
        echo "HARDWARE:"
        echo "---------"
        echo "Processador:"
        lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core"
        echo
        echo "Memória:"
        cat /proc/meminfo | grep -E "MemTotal|SwapTotal"
        echo
        echo "KERNEL:"
        echo "-------"
        uname -a
        echo
        echo "UPTIME:"
        echo "-------"
        uptime
        echo
        echo "TIMEZONE:"
        echo "---------"
        timedatectl 2>/dev/null || date
    } > "$temp_file"
    
    dialog \
        --title 'INFORMAÇÕES DO SISTEMA' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para mostrar processos
show_processes() {
    local temp_file="/tmp/processes.txt"
    
    {
        echo "PROCESSOS EM EXECUÇÃO"
        echo "====================="
        echo
        echo "RESUMO:"
        echo "-------"
        ps aux | head -1
        echo "Total de processos: $(ps aux | wc -l)"
        echo
        echo "TOP 15 PROCESSOS (CPU):"
        echo "----------------------"
        ps aux --sort=-%cpu | head -16
        echo
        echo "TOP 15 PROCESSOS (MEMÓRIA):"
        echo "--------------------------"
        ps aux --sort=-%mem | head -16
    } > "$temp_file"
    
    dialog \
        --title 'PROCESSOS DO SISTEMA' \
        --textbox "$temp_file" \
        20 100
    
    rm -f "$temp_file"
}

# Função para mostrar conexões de rede
show_network_connections() {
    local temp_file="/tmp/network_conn.txt"
    
    {
        echo "CONEXÕES DE REDE"
        echo "================"
        echo
        echo "INTERFACES ATIVAS:"
        echo "-----------------"
        ip addr show | grep -E "^[0-9]|inet "
        echo
        echo "CONEXÕES TCP:"
        echo "-------------"
        netstat -tn | head -20
        echo
        echo "PORTAS EM ESCUTA:"
        echo "-----------------"
        netstat -tln | head -20
        echo
        echo "ESTATÍSTICAS DE REDE:"
        echo "--------------------"
        ss -s
    } > "$temp_file"
    
    dialog \
        --title 'CONEXÕES DE REDE' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para uso detalhado de disco
show_detailed_disk_usage() {
    local temp_file="/tmp/disk_detail.txt"
    
    {
        echo "USO DETALHADO DE DISCO"
        echo "======================"
        echo
        echo "SISTEMAS DE ARQUIVOS:"
        echo "--------------------"
        df -h
        echo
        echo "INODES:"
        echo "-------"
        df -i
        echo
        echo "MAIORES DIRETÓRIOS (TOP 20):"
        echo "----------------------------"
        echo "Calculando... pode demorar alguns segundos"
        du -h /var /home /opt /usr 2>/dev/null | sort -rh | head -20
    } > "$temp_file"
    
    dialog \
        --title 'USO DETALHADO DE DISCO' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para mostrar variáveis de ambiente
show_environment_vars() {
    local temp_file="/tmp/env_vars.txt"
    
    {
        echo "VARIÁVEIS DE AMBIENTE"
        echo "====================="
        echo
        env | sort
    } > "$temp_file"
    
    dialog \
        --title 'VARIÁVEIS DE AMBIENTE' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para mostrar módulos do kernel
show_kernel_modules() {
    local temp_file="/tmp/kernel_modules.txt"
    
    {
        echo "MÓDULOS DO KERNEL"
        echo "=================="
        echo
        echo "MÓDULOS CARREGADOS:"
        echo "------------------"
        lsmod | head -30
        echo
        echo "INFORMAÇÕES DO KERNEL:"
        echo "---------------------"
        uname -a
        echo
        echo "VERSÃO DO KERNEL:"
        echo "----------------"
        cat /proc/version
    } > "$temp_file"
    
    dialog \
        --title 'MÓDULOS DO KERNEL' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

#=============================================================================
# TELAS DE AJUDA E INFORMAÇÕES
#=============================================================================

# Tela de ajuda
tela_ajuda() {
    dialog \
        --title 'AJUDA DO SISTEMA' \
        --msgbox 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v2.0SBE\n\nEste sistema oferece:\n\n• Gerenciamento completo de usuários\n• Sistema de backup automatizado MySQL\n• Monitoramento abrangente do sistema\n• Ferramentas administrativas avançadas\n\nUse as setas para navegar pelos menus\nPressione ENTER para selecionar\nPressione ESC para voltar\n\nPara mais informações, consulte a documentação.' \
        16 70
}

# Tela sobre o sistema
tela_sobre() {
    dialog \
        --title 'SOBRE O SISTEMA' \
        --msgbox 'SISBKT2G2 - Sistema de Automação v2.0\n\nDesenvolvido por:\n• Andre Kroetz Berger\n• Daniel Meyer\n• Edivaldo Cezar\n• Felipe Matias\n\nData: 03/10/2025\nVersão: 2.0 SBE\nLicença: MIT\n\nCompatível com:\n• Ubuntu 18+\n• CentOS 7+\n• Fedora 30+\n\nPara suporte técnico, consulte a documentação\nou entre em contato com a equipe de desenvolvimento.' \
        18 70
}

#=============================================================================
# FUNÇÕES DE LIMPEZA
#=============================================================================

# Função de limpeza para telas
cleanup_temp_files_telas() {
    rm -f /tmp/logged_users.txt /tmp/system_info.txt /tmp/processes.txt \
         /tmp/network_conn.txt /tmp/disk_detail.txt /tmp/env_vars.txt \
         /tmp/kernel_modules.txt 2>/dev/null
}

# Registrar cleanup para ser executado ao sair
trap cleanup_temp_files_telas EXIT