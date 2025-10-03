#!/bin/bash

#=============================================================================
# Script: SISBKT2G2.sh
# Descrição: Sistema de Controle de Automação para o TUX v2.0SBE
#            Sistema empresarial completo para automação de tarefas
# Autores: Andre Kroetz Berger, Daniel Meyer, Edivaldo Cezar, Felipe Matias
# Data: 03/10/2025
# Versão: 2.0
# Licença: MIT
# Compatibilidade: Ubuntu 18+, CentOS 7+, Fedora 30+
#=============================================================================

# Configurações do script
set -e  # Sair se qualquer comando falhar
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/sisbkt2g2-$(date '+%Y%m%d_%H%M%S').log"

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
# 1. Instalar dependências:
#    sudo apt install dialog mysql-client htop iftop        # Ubuntu/Debian
#    sudo dnf install dialog mysql htop iftop               # Fedora
#    sudo yum install dialog mysql htop iftop               # CentOS/RHEL
#
# 2. Tornar executável:
#    chmod +x SISBKT2G2.sh
#
# 3. Executar como root:
#    sudo ./SISBKT2G2.sh
#
# 4. Navegar pelo menu usando as setas e ENTER
#
# 5. Para sair: selecionar opção "Sair" ou pressionar ESC
#=============================================================================

#=============================================================================
# VERIFICAÇÕES E VALIDAÇÕES
#=============================================================================

# Função para log de operações
log_operation() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Função para verificar dependências
check_dependencies() {
    local missing_deps=()
    local deps=("dialog" "mysql" "htop" "iftop")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Dependências faltando: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}💡 Instale com:${NC}"
        echo -e "${CYAN}Ubuntu/Debian: sudo apt install ${missing_deps[*]}${NC}"
        echo -e "${CYAN}Fedora: sudo dnf install ${missing_deps[*]}${NC}"
        echo -e "${CYAN}CentOS/RHEL: sudo yum install ${missing_deps[*]}${NC}"
        exit 1
    fi
}

# Verificar se está sendo executado como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        dialog \
            --title 'AVISO DE SEGURANÇA!' \
            --msgbox 'Este sistema deve ser executado como root para funcionar corretamente.\n\nExecute: sudo ./SISBKT2G2.sh' \
            8 50
        exit 1
    fi
}

#=============================================================================
# FUNÇÕES DO SISTEMA
#=============================================================================

# Carregar módulos do sistema
load_modules() {
    local modules_dir="$SCRIPT_DIR"
    
    # Verificar se os módulos existem
    local modules=("functionUsers.sh" "functionBkpMySql.sh" "functionMonitoramento.sh" "telasSistema.sh")
    
    for module in "${modules[@]}"; do
        if [[ -f "$modules_dir/$module" ]]; then
            source "$modules_dir/$module"
            log_operation "Módulo carregado: $module"
        else
            dialog \
                --title 'ERRO DE SISTEMA' \
                --msgbox "Módulo não encontrado: $module\n\nVerifique se todos os arquivos estão no diretório correto." \
                8 60
            exit 1
        fi
    done
}

# Função principal do menu
show_main_menu() {
    while true; do
        local resposta
        resposta=$(dialog --stdout \
            --title 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v2.0SBE' \
            --backtitle 'SISBKT2G2 - Sistema Empresarial de Automação' \
            --menu 'BEM-VINDO(A) AO NOSSO SISTEMA! O QUE DESEJA FAZER?' \
            15 70 5 \
            1 'Manutenção de Usuários' \
            2 'Backup MySQL' \
            3 'Monitoramento do Sistema' \
            4 'Configurações Avançadas' \
            0 'Sair do Sistema' \
            2>&1 >/dev/tty)
        
        # Verificar se usuário cancelou
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$resposta" in
            1) 
                log_operation "Acesso ao módulo: Manutenção de Usuários"
                tela_menu_user
                ;;
            2) 
                log_operation "Acesso ao módulo: Backup MySQL"
                tela_backup_mysql
                ;;
            3) 
                log_operation "Acesso ao módulo: Monitoramento"
                tela_monitor_server
                ;;
            4)
                log_operation "Acesso ao módulo: Configurações Avançadas"
                show_advanced_menu
                ;;
            0) 
                log_operation "Sistema encerrado pelo usuário"
                break
                ;;
        esac
    done
}

# Menu de configurações avançadas
show_advanced_menu() {
    while true; do
        local resposta
        resposta=$(dialog --stdout \
            --title 'CONFIGURAÇÕES AVANÇADAS' \
            --backtitle 'SISBKT2G2 - Configurações do Sistema' \
            --menu 'Selecione uma opção avançada:' \
            12 60 4 \
            1 'Ver Logs do Sistema' \
            2 'Limpeza de Arquivos Temporários' \
            3 'Verificar Integridade do Sistema' \
            0 'Voltar ao Menu Principal' \
            2>&1 >/dev/tty)
        
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$resposta" in
            1) view_system_logs ;;
            2) cleanup_temp_files ;;
            3) check_system_integrity ;;
            0) break ;;
        esac
    done
}

# Função para visualizar logs
view_system_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        dialog \
            --title 'LOGS DO SISTEMA' \
            --textbox "$LOG_FILE" \
            20 80
    else
        dialog \
            --title 'LOGS DO SISTEMA' \
            --msgbox 'Nenhum log encontrado para esta sessão.' \
            6 40
    fi
}

# Função para limpeza de arquivos temporários
cleanup_temp_files() {
    local temp_files_count
    temp_files_count=$(find /tmp -name "sisbkt2g2-*" -type f | wc -l)
    
    if [[ $temp_files_count -gt 0 ]]; then
        dialog \
            --title 'LIMPEZA DE ARQUIVOS' \
            --yesno "Encontrados $temp_files_count arquivos temporários.\n\nDeseja removê-los?" \
            8 50
        
        if [[ $? -eq 0 ]]; then
            find /tmp -name "sisbkt2g2-*" -type f -delete
            log_operation "Limpeza de arquivos temporários executada"
            dialog \
                --title 'LIMPEZA CONCLUÍDA' \
                --msgbox 'Arquivos temporários removidos com sucesso!' \
                6 40
        fi
    else
        dialog \
            --title 'LIMPEZA DE ARQUIVOS' \
            --msgbox 'Nenhum arquivo temporário encontrado.' \
            6 40
    fi
}

# Função para verificar integridade do sistema
check_system_integrity() {
    local status_msg=""
    
    # Verificar módulos
    local modules=("functionUsers.sh" "functionBkpMySql.sh" "functionMonitoramento.sh" "telasSistema.sh")
    local missing_modules=()
    
    for module in "${modules[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$module" ]]; then
            missing_modules+=("$module")
        fi
    done
    
    if [[ ${#missing_modules[@]} -eq 0 ]]; then
        status_msg="✅ Todos os módulos estão presentes\n"
    else
        status_msg="❌ Módulos faltando: ${missing_modules[*]}\n"
    fi
    
    # Verificar dependências
    local deps=("dialog" "mysql" "htop" "iftop")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        status_msg+="✅ Todas as dependências estão instaladas\n"
    else
        status_msg+="❌ Dependências faltando: ${missing_deps[*]}\n"
    fi
    
    # Verificar permissões
    if [[ $EUID -eq 0 ]]; then
        status_msg+="✅ Executando com privilégios de root\n"
    else
        status_msg+="❌ Sem privilégios de root\n"
    fi
    
    # Verificar espaço em disco
    local disk_usage
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [[ $disk_usage -lt 90 ]]; then
        status_msg+="✅ Espaço em disco OK ($disk_usage%)\n"
    else
        status_msg+="⚠️  Espaço em disco baixo ($disk_usage%)\n"
    fi
    
    dialog \
        --title 'VERIFICAÇÃO DE INTEGRIDADE' \
        --msgbox "$status_msg" \
        12 60
}

# Função para exibir informações sobre o sistema
show_about() {
    dialog \
        --title 'SOBRE O SISTEMA' \
        --msgbox 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v2.0SBE\n\nDesenvolvido por:\n• Andre Kroetz Berger\n• Daniel Meyer\n• Edivaldo Cezar\n• Felipe Matias\n\nVersão: 2.0\nData: 03/10/2025\nLicença: MIT' \
        14 60
}

#=============================================================================
# FUNÇÃO PRINCIPAL
#=============================================================================

main() {
    # Verificar dependências
    check_dependencies
    
    # Verificar se está executando como root
    check_root
    
    # Carregar módulos do sistema
    load_modules
    
    # Log de início do sistema
    log_operation "Sistema SISBKT2G2 v2.0 iniciado"
    
    # Exibir tela de boas-vindas
    dialog \
        --title 'BEM-VINDO!' \
        --msgbox 'Sistema de Controle de Automação para o TUX v2.0SBE\n\nSistema carregado com sucesso!\nTodos os módulos estão funcionais.' \
        8 60
    
    # Executar menu principal
    show_main_menu
    
    # Tela de despedida
    dialog \
        --title 'SISTEMA ENCERRADO' \
        --msgbox 'Obrigado por usar o SISBKT2G2!\n\nLog da sessão salvo em:\n'"$LOG_FILE" \
        8 50
    
    clear
    echo -e "${GREEN}✅ Sistema SISBKT2G2 encerrado com sucesso!${NC}"
    echo -e "${CYAN}📋 Log da sessão: $LOG_FILE${NC}"
}

#=============================================================================
# EXECUÇÃO
#=============================================================================

# Executar função principal
main "$@"

# Código de saída
exit 0