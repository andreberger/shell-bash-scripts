#!/bin/bash

#=============================================================================
# Script: functionBkpMySql.sh
# Descrição: Módulo de funções para backup automatizado de MySQL/MariaDB
#            Parte do sistema SISBKT2G2 v2.0SBE
# Autores: Andre Kroetz Berger, Daniel Meyer, Edivaldo Cezar, Felipe Matias
# Data: 03/10/2025
# Versão: 2.0
# Licença: MIT
# Compatibilidade: Ubuntu 18+, CentOS 7+, Fedora 30+
#=============================================================================

# Configurações do sistema de backup
readonly BKP_LOG="/var/log/backupMySQL.log"
readonly BKP_DIR="/var/backups/mysql"
readonly CONFIG_FILE="/etc/mysql-backup.conf"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
# FUNÇÕES DE CONFIGURAÇÃO E VALIDAÇÃO
#=============================================================================

# Função para verificar se MySQL/MariaDB está disponível
check_mysql_availability() {
    if ! command -v mysql &> /dev/null && ! command -v mariadb &> /dev/null; then
        dialog \
            --title 'MYSQL/MARIADB NÃO ENCONTRADO' \
            --msgbox 'MySQL ou MariaDB não estão instalados no sistema.\n\nInstale um dos dois para usar o sistema de backup.' \
            8 60
        return 1
    fi
    
    # Verificar se o serviço está rodando
    if ! systemctl is-active --quiet mysql && ! systemctl is-active --quiet mariadb; then
        dialog \
            --title 'SERVIÇO INATIVO' \
            --msgbox 'O serviço MySQL/MariaDB não está rodando.\n\nInicie o serviço antes de fazer backup.' \
            8 60
        return 1
    fi
    
    return 0
}

# Função para criar diretório de backup se não existir
setup_backup_directory() {
    if [[ ! -d "$BKP_DIR" ]]; then
        if mkdir -p "$BKP_DIR" 2>/dev/null; then
            chmod 750 "$BKP_DIR"
            log_backup "Diretório de backup criado: $BKP_DIR"
        else
            dialog \
                --title 'ERRO DE PERMISSÃO' \
                --msgbox "Não foi possível criar o diretório de backup:\n$BKP_DIR\n\nVerifique as permissões." \
                8 60
            return 1
        fi
    fi
    return 0
}

# Função para log de operações de backup
log_backup() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$BKP_LOG"
}

# Função para obter credenciais MySQL
get_mysql_credentials() {
    local user pass host port
    
    # Tentar ler configuração existente
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        MYSQL_USER="${MYSQL_USER:-root}"
        MYSQL_HOST="${MYSQL_HOST:-localhost}"
        MYSQL_PORT="${MYSQL_PORT:-3306}"
    else
        # Solicitar credenciais
        MYSQL_USER=$(dialog --stdout \
            --title 'CREDENCIAIS MYSQL' \
            --inputbox 'Digite o usuário MySQL:' \
            8 50 "root")
        
        if [[ $? -ne 0 ]] || [[ -z "$MYSQL_USER" ]]; then
            return 1
        fi
        
        MYSQL_PASS=$(dialog --stdout \
            --title 'SENHA MYSQL' \
            --passwordbox "Digite a senha para o usuário '$MYSQL_USER':" \
            8 50)
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        MYSQL_HOST=$(dialog --stdout \
            --title 'SERVIDOR MYSQL' \
            --inputbox 'Digite o host MySQL:' \
            8 50 "localhost")
        
        if [[ $? -ne 0 ]] || [[ -z "$MYSQL_HOST" ]]; then
            MYSQL_HOST="localhost"
        fi
        
        MYSQL_PORT=$(dialog --stdout \
            --title 'PORTA MYSQL' \
            --inputbox 'Digite a porta MySQL:' \
            8 50 "3306")
        
        if [[ $? -ne 0 ]] || [[ -z "$MYSQL_PORT" ]]; then
            MYSQL_PORT="3306"
        fi
        
        # Salvar configuração
        dialog --yesno "Deseja salvar essas credenciais para uso futuro?\n\n⚠️ A senha será armazenada em texto plano." \
            8 60
        
        if [[ $? -eq 0 ]]; then
            {
                echo "# Configuração de backup MySQL - Gerado automaticamente"
                echo "MYSQL_USER=\"$MYSQL_USER\""
                echo "MYSQL_PASS=\"$MYSQL_PASS\""
                echo "MYSQL_HOST=\"$MYSQL_HOST\""
                echo "MYSQL_PORT=\"$MYSQL_PORT\""
            } > "$CONFIG_FILE"
            chmod 600 "$CONFIG_FILE"
            log_backup "Configuração salva em $CONFIG_FILE"
        fi
    fi
    
    # Testar conexão
    if ! mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -e "SELECT 1;" &>/dev/null; then
        dialog \
            --title 'ERRO DE CONEXÃO' \
            --msgbox 'Não foi possível conectar ao MySQL com as credenciais fornecidas.' \
            7 60
        return 1
    fi
    
    return 0
}

#=============================================================================
# FUNÇÕES DE BACKUP
#=============================================================================

# Função principal de backup
backup_mysql() {
    dialog --yesno "SISTEMA DE BACKUP MYSQL\n\nO que deseja fazer?\n\nYES: Executar backup agora\nNO: Agendar backup automático" \
        10 60
    
    if [[ $? -eq 1 ]]; then
        # Agendar backup
        schedule_backup
    else
        # Executar backup imediato
        execute_immediate_backup
    fi
}

# Função para executar backup imediato
execute_immediate_backup() {
    if ! check_mysql_availability; then
        return 1
    fi
    
    if ! setup_backup_directory; then
        return 1
    fi
    
    if ! get_mysql_credentials; then
        return 1
    fi
    
    # Menu de opções de backup
    local backup_type
    backup_type=$(dialog --stdout \
        --title 'TIPO DE BACKUP' \
        --menu 'Selecione o tipo de backup:' \
        12 60 4 \
        1 'Backup completo (todos os bancos)' \
        2 'Backup de banco específico' \
        3 'Backup de tabela específica' \
        4 'Backup apenas da estrutura')
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    case "$backup_type" in
        1) backup_all_databases ;;
        2) backup_specific_database ;;
        3) backup_specific_table ;;
        4) backup_structure_only ;;
    esac
}

# Função para backup completo
backup_all_databases() {
    local timestamp backup_file
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_file="$BKP_DIR/mysql_full_backup_$timestamp.sql"
    
    log_backup "Iniciando backup completo de todos os bancos"
    
    # Mostrar progress
    (
        echo "# Conectando ao MySQL..."
        echo "10"
        sleep 1
        
        echo "# Listando bancos de dados..."
        echo "20"
        sleep 1
        
        echo "# Executando mysqldump..."
        echo "30"
        
        if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
            --all-databases --routines --triggers --events \
            --single-transaction --lock-tables=false > "$backup_file" 2>/dev/null; then
            
            echo "# Compactando backup..."
            echo "70"
            gzip "$backup_file"
            backup_file="${backup_file}.gz"
            
            echo "# Finalizando..."
            echo "90"
            sleep 1
            
            echo "# Backup concluído!"
            echo "100"
        else
            echo "# Erro no backup!"
            echo "100"
            return 1
        fi
    ) | dialog --title 'EXECUTANDO BACKUP' --gauge 'Preparando backup...' 8 60 0
    
    if [[ -f "$backup_file" ]]; then
        local file_size
        file_size=$(du -h "$backup_file" | cut -f1)
        
        dialog \
            --title 'BACKUP CONCLUÍDO' \
            --msgbox "✅ Backup completo realizado com sucesso!\n\nArquivo: $(basename "$backup_file")\nTamanho: $file_size\nLocal: $BKP_DIR" \
            10 70
        
        log_backup "Backup completo concluído: $backup_file ($file_size)"
    else
        dialog \
            --title 'ERRO NO BACKUP' \
            --msgbox 'Erro ao criar o arquivo de backup.\nVerifique o log para mais detalhes.' \
            7 50
        log_backup "ERRO: Falha no backup completo"
    fi
}

# Função para backup de banco específico
backup_specific_database() {
    # Listar bancos disponíveis
    local databases
    databases=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
        -e "SHOW DATABASES;" 2>/dev/null | grep -v -E '^(Database|information_schema|performance_schema|mysql|sys)$')
    
    if [[ -z "$databases" ]]; then
        dialog \
            --title 'NENHUM BANCO ENCONTRADO' \
            --msgbox 'Nenhum banco de dados de usuário encontrado.' \
            6 50
        return 1
    fi
    
    # Criar menu dinâmico
    local menu_items=()
    while IFS= read -r db; do
        if [[ -n "$db" ]]; then
            menu_items+=("$db" "Banco de dados: $db")
        fi
    done <<< "$databases"
    
    local selected_db
    selected_db=$(dialog --stdout \
        --title 'SELECIONAR BANCO' \
        --menu 'Escolha o banco para backup:' \
        15 60 8 \
        "${menu_items[@]}")
    
    if [[ $? -ne 0 ]] || [[ -z "$selected_db" ]]; then
        return 1
    fi
    
    # Executar backup do banco selecionado
    local timestamp backup_file
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_file="$BKP_DIR/mysql_${selected_db}_$timestamp.sql"
    
    log_backup "Iniciando backup do banco: $selected_db"
    
    if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
        --routines --triggers --events --single-transaction \
        "$selected_db" > "$backup_file" 2>/dev/null; then
        
        gzip "$backup_file"
        backup_file="${backup_file}.gz"
        
        local file_size
        file_size=$(du -h "$backup_file" | cut -f1)
        
        dialog \
            --title 'BACKUP CONCLUÍDO' \
            --msgbox "✅ Backup do banco '$selected_db' realizado!\n\nArquivo: $(basename "$backup_file")\nTamanho: $file_size" \
            9 60
        
        log_backup "Backup do banco '$selected_db' concluído: $backup_file ($file_size)"
    else
        dialog \
            --title 'ERRO NO BACKUP' \
            --msgbox "Erro ao fazer backup do banco '$selected_db'." \
            6 50
        log_backup "ERRO: Falha no backup do banco '$selected_db'"
    fi
}

# Função para agendar backup
schedule_backup() {
    local schedule_type
    schedule_type=$(dialog --stdout \
        --title 'AGENDAMENTO DE BACKUP' \
        --menu 'Como deseja agendar o backup?' \
        10 50 3 \
        1 'Backup único (comando at)' \
        2 'Backup recorrente (crontab)' \
        3 'Ver agendamentos atuais')
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    case "$schedule_type" in
        1) schedule_one_time_backup ;;
        2) schedule_recurring_backup ;;
        3) list_scheduled_backups ;;
    esac
}

# Função para agendamento único
schedule_one_time_backup() {
    local when_backup
    when_backup=$(dialog --stdout \
        --title 'AGENDAMENTO ÚNICO' \
        --inputbox 'Quando executar o backup?\n\nExemplos:\n• now + 1 hour\n• 14:30\n• tomorrow 9:00\n• 2025-10-04 15:30' \
        12 60)
    
    if [[ $? -ne 0 ]] || [[ -z "$when_backup" ]]; then
        return 1
    fi
    
    # Verificar se o script de backup existe
    local backup_script="$SCRIPT_DIR/bkp_mysql.sh"
    if [[ ! -f "$backup_script" ]]; then
        dialog \
            --title 'SCRIPT NÃO ENCONTRADO' \
            --msgbox "Script de backup não encontrado:\n$backup_script" \
            7 60
        return 1
    fi
    
    # Agendar com at
    if echo "$backup_script" | at "$when_backup" 2>/dev/null; then
        dialog \
            --title 'BACKUP AGENDADO' \
            --msgbox "✅ Backup agendado com sucesso!\n\nQuando: $when_backup\nScript: $backup_script" \
            9 60
        log_backup "Backup único agendado para: $when_backup"
    else
        dialog \
            --title 'ERRO NO AGENDAMENTO' \
            --msgbox "Erro ao agendar backup.\n\nVerifique o formato da data/hora." \
            7 50
    fi
}

# Função para agendamento recorrente
schedule_recurring_backup() {
    local cron_schedule
    cron_schedule=$(dialog --stdout \
        --title 'BACKUP RECORRENTE' \
        --menu 'Escolha a frequência do backup:' \
        12 60 5 \
        '0 2 * * *' 'Diário às 02:00' \
        '0 2 * * 0' 'Semanal (domingo às 02:00)' \
        '0 2 1 * *' 'Mensal (dia 1 às 02:00)' \
        '0 2 1 1,7 *' 'Semestral (jan/jul às 02:00)' \
        'personalizado' 'Definir horário personalizado')
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    if [[ "$cron_schedule" == "personalizado" ]]; then
        cron_schedule=$(dialog --stdout \
            --title 'CRON PERSONALIZADO' \
            --inputbox 'Digite a expressão cron:\n\nFormato: min hora dia mês dia_semana\nExemplo: 30 14 * * 1-5 (14:30, seg-sex)' \
            10 60)
        
        if [[ $? -ne 0 ]] || [[ -z "$cron_schedule" ]]; then
            return 1
        fi
    fi
    
    # Verificar se o script de backup existe
    local backup_script="$SCRIPT_DIR/bkp_mysql.sh"
    if [[ ! -f "$backup_script" ]]; then
        dialog \
            --title 'SCRIPT NÃO ENCONTRADO' \
            --msgbox "Script de backup não encontrado:\n$backup_script" \
            7 60
        return 1
    fi
    
    # Adicionar ao crontab
    (crontab -l 2>/dev/null; echo "$cron_schedule $backup_script") | crontab -
    
    if [[ $? -eq 0 ]]; then
        dialog \
            --title 'BACKUP AGENDADO' \
            --msgbox "✅ Backup recorrente configurado!\n\nFrequência: $cron_schedule\nScript: $backup_script" \
            9 70
        log_backup "Backup recorrente configurado: $cron_schedule"
    else
        dialog \
            --title 'ERRO NO AGENDAMENTO' \
            --msgbox 'Erro ao configurar backup recorrente.' \
            6 50
    fi
}

#=============================================================================
# FUNÇÕES DE VISUALIZAÇÃO E RELATÓRIOS
#=============================================================================

# Função para ver log de backup
ver_log_backup() {
    if [[ -f "$BKP_LOG" && -s "$BKP_LOG" ]]; then
        dialog \
            --title 'LOG DE BACKUP MYSQL' \
            --textbox "$BKP_LOG" \
            20 80
    else
        dialog \
            --title 'LOG VAZIO' \
            --msgbox 'Nenhum log de backup encontrado ou arquivo vazio.' \
            6 50
    fi
}

# Função para listar agendamentos
list_scheduled_backups() {
    local temp_file="/tmp/scheduled_backups.txt"
    
    {
        echo "BACKUPS AGENDADOS NO SISTEMA"
        echo "============================"
        echo
        echo "CRONTAB (Backups Recorrentes):"
        echo "------------------------------"
        if crontab -l 2>/dev/null | grep -i backup; then
            crontab -l | grep -i backup
        else
            echo "Nenhum backup recorrente configurado"
        fi
        echo
        echo "AT (Backups Únicos):"
        echo "--------------------"
        if at -l 2>/dev/null | wc -l | grep -q '^0$'; then
            echo "Nenhum backup único agendado"
        else
            at -l
        fi
        echo
        echo "ARQUIVOS DE BACKUP EXISTENTES:"
        echo "------------------------------"
        if [[ -d "$BKP_DIR" ]] && [[ $(ls -1 "$BKP_DIR" 2>/dev/null | wc -l) -gt 0 ]]; then
            ls -lh "$BKP_DIR"
        else
            echo "Nenhum arquivo de backup encontrado"
        fi
    } > "$temp_file"
    
    dialog \
        --title 'AGENDAMENTOS E BACKUPS' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para gerenciar arquivos de backup
manage_backup_files() {
    if [[ ! -d "$BKP_DIR" ]]; then
        dialog \
            --title 'DIRETÓRIO NÃO ENCONTRADO' \
            --msgbox "Diretório de backup não existe:\n$BKP_DIR" \
            7 60
        return 1
    fi
    
    local backup_count
    backup_count=$(ls -1 "$BKP_DIR" 2>/dev/null | wc -l)
    
    if [[ $backup_count -eq 0 ]]; then
        dialog \
            --title 'NENHUM BACKUP' \
            --msgbox 'Nenhum arquivo de backup encontrado.' \
            6 40
        return 1
    fi
    
    local action
    action=$(dialog --stdout \
        --title 'GERENCIAR BACKUPS' \
        --menu "Encontrados $backup_count arquivos de backup:" \
        10 60 4 \
        1 'Listar todos os backups' \
        2 'Remover backups antigos' \
        3 'Calcular espaço usado' \
        4 'Restaurar backup')
    
    case "$action" in
        1) list_backup_files ;;
        2) cleanup_old_backups ;;
        3) calculate_backup_space ;;
        4) restore_backup ;;
    esac
}

# Função para listar arquivos de backup
list_backup_files() {
    local temp_file="/tmp/backup_list.txt"
    
    {
        echo "ARQUIVOS DE BACKUP MYSQL"
        echo "========================"
        echo
        ls -lht "$BKP_DIR"
    } > "$temp_file"
    
    dialog \
        --title 'ARQUIVOS DE BACKUP' \
        --textbox "$temp_file" \
        20 80
    
    rm -f "$temp_file"
}

# Função para limpeza de backups antigos
cleanup_old_backups() {
    local days_to_keep
    days_to_keep=$(dialog --stdout \
        --title 'LIMPEZA DE BACKUPS' \
        --inputbox 'Manter backups dos últimos quantos dias?' \
        8 50 "30")
    
    if [[ $? -ne 0 ]] || [[ ! "$days_to_keep" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    local old_backups
    old_backups=$(find "$BKP_DIR" -name "*.sql.gz" -mtime +$days_to_keep 2>/dev/null)
    
    if [[ -z "$old_backups" ]]; then
        dialog \
            --title 'NENHUM BACKUP ANTIGO' \
            --msgbox "Nenhum backup com mais de $days_to_keep dias encontrado." \
            6 60
        return 0
    fi
    
    local count
    count=$(echo "$old_backups" | wc -l)
    
    dialog --yesno "Encontrados $count backups com mais de $days_to_keep dias.\n\nDeseja removê-los?" \
        8 60
    
    if [[ $? -eq 0 ]]; then
        echo "$old_backups" | xargs rm -f
        dialog \
            --title 'LIMPEZA CONCLUÍDA' \
            --msgbox "$count arquivos de backup antigos foram removidos." \
            6 60
        log_backup "Limpeza executada: $count arquivos removidos (>$days_to_keep dias)"
    fi
}

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para calcular espaço usado pelos backups
calculate_backup_space() {
    local total_size file_count
    total_size=$(du -sh "$BKP_DIR" 2>/dev/null | cut -f1)
    file_count=$(ls -1 "$BKP_DIR" 2>/dev/null | wc -l)
    
    dialog \
        --title 'ESPAÇO DE BACKUP' \
        --msgbox "Estatísticas do diretório de backup:\n\nLocalização: $BKP_DIR\nArquivos: $file_count\nEspaço total: $total_size" \
        9 60
}

# Função de limpeza de arquivos temporários
cleanup_temp_files_backup() {
    rm -f /tmp/agendarBKP.txt /tmp/agendarBKP2.txt /tmp/scheduled_backups.txt /tmp/backup_list.txt 2>/dev/null
}

# Registrar cleanup para ser executado ao sair
trap cleanup_temp_files_backup EXIT