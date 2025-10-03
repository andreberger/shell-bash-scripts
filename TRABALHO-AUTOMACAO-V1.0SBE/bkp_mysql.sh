#!/bin/bash

#=============================================================================
# Script: bkp_mysql.sh
# Descrição: Script executável para backup automatizado de MySQL/MariaDB
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
readonly LOG_FILE="/var/log/backupMySQL.log"
readonly BKP_DIR="/var/backups/mysql"
readonly CONFIG_FILE="/etc/mysql-backup.conf"

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
# 1. Configurar credenciais MySQL (primeira execução):
#    Edite o arquivo /etc/mysql-backup.conf ou execute o script
#    que solicitará as credenciais automaticamente
#
# 2. Tornar executável:
#    chmod +x bkp_mysql.sh
#
# 3. Executar manualmente:
#    sudo ./bkp_mysql.sh
#
# 4. Agendar no crontab (exemplo para backup diário às 2h):
#    sudo crontab -e
#    0 2 * * * /caminho/para/bkp_mysql.sh
#
# 5. Verificar logs:
#    tail -f /var/log/backupMySQL.log
#=============================================================================

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para log de operações
log_operation() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Função para verificar dependências
check_dependencies() {
    local missing_deps=()
    local deps=("mysql" "mysqldump" "gzip")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Dependências faltando: ${missing_deps[*]}${NC}"
        log_operation "ERRO: Dependências faltando: ${missing_deps[*]}"
        exit 1
    fi
}

# Função para verificar se MySQL está rodando
check_mysql_service() {
    if ! systemctl is-active --quiet mysql && ! systemctl is-active --quiet mariadb; then
        echo -e "${RED}❌ Serviço MySQL/MariaDB não está rodando${NC}"
        log_operation "ERRO: Serviço MySQL/MariaDB inativo"
        exit 1
    fi
}

# Função para criar diretório de backup
setup_backup_directory() {
    if [[ ! -d "$BKP_DIR" ]]; then
        if mkdir -p "$BKP_DIR" 2>/dev/null; then
            chmod 750 "$BKP_DIR"
            log_operation "Diretório de backup criado: $BKP_DIR"
        else
            echo -e "${RED}❌ Erro ao criar diretório de backup: $BKP_DIR${NC}"
            log_operation "ERRO: Falha ao criar diretório de backup"
            exit 1
        fi
    fi
}

# Função para carregar configurações
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_operation "Configuração carregada de $CONFIG_FILE"
    else
        echo -e "${YELLOW}⚠️  Arquivo de configuração não encontrado: $CONFIG_FILE${NC}"
        echo -e "${CYAN}💡 Crie o arquivo com as seguintes variáveis:${NC}"
        echo -e "${WHITE}MYSQL_USER=\"seu_usuario\"${NC}"
        echo -e "${WHITE}MYSQL_PASS=\"sua_senha\"${NC}"
        echo -e "${WHITE}MYSQL_HOST=\"localhost\"${NC}"
        echo -e "${WHITE}MYSQL_PORT=\"3306\"${NC}"
        log_operation "ERRO: Arquivo de configuração não encontrado"
        exit 1
    fi
    
    # Verificar se todas as variáveis estão definidas
    local required_vars=("MYSQL_USER" "MYSQL_PASS" "MYSQL_HOST" "MYSQL_PORT")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo -e "${RED}❌ Variável $var não definida no arquivo de configuração${NC}"
            log_operation "ERRO: Variável $var não definida"
            exit 1
        fi
    done
}

# Função para testar conexão MySQL
test_mysql_connection() {
    if ! mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -e "SELECT 1;" &>/dev/null; then
        echo -e "${RED}❌ Erro ao conectar ao MySQL com as credenciais fornecidas${NC}"
        log_operation "ERRO: Falha na conexão MySQL"
        exit 1
    fi
    log_operation "Conexão MySQL testada com sucesso"
}

#=============================================================================
# FUNÇÕES DE BACKUP
#=============================================================================

# Função para backup completo
backup_all_databases() {
    local timestamp backup_file
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_file="$BKP_DIR/mysql_full_backup_$timestamp.sql"
    
    echo -e "${BLUE}📦 Iniciando backup completo de todos os bancos...${NC}"
    log_operation "Iniciando backup completo"
    
    # Executar mysqldump
    if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
        --all-databases --routines --triggers --events \
        --single-transaction --lock-tables=false > "$backup_file" 2>/dev/null; then
        
        echo -e "${GREEN}✅ Dump criado com sucesso${NC}"
        log_operation "Dump MySQL criado: $backup_file"
        
        # Comprimir arquivo
        echo -e "${BLUE}🗜️  Comprimindo arquivo...${NC}"
        if gzip "$backup_file"; then
            backup_file="${backup_file}.gz"
            local file_size
            file_size=$(du -h "$backup_file" | cut -f1)
            
            echo -e "${GREEN}✅ Backup concluído com sucesso!${NC}"
            echo -e "${CYAN}📁 Arquivo: $(basename "$backup_file")${NC}"
            echo -e "${CYAN}📊 Tamanho: $file_size${NC}"
            echo -e "${CYAN}📍 Local: $BKP_DIR${NC}"
            
            log_operation "Backup completo concluído: $backup_file ($file_size)"
            
            # Verificar integridade
            if gzip -t "$backup_file" 2>/dev/null; then
                echo -e "${GREEN}✅ Integridade do arquivo verificada${NC}"
                log_operation "Integridade do backup verificada"
            else
                echo -e "${YELLOW}⚠️  Aviso: Problema na verificação de integridade${NC}"
                log_operation "AVISO: Problema na verificação de integridade"
            fi
            
        else
            echo -e "${RED}❌ Erro ao comprimir arquivo${NC}"
            log_operation "ERRO: Falha na compressão"
            exit 1
        fi
    else
        echo -e "${RED}❌ Erro ao executar mysqldump${NC}"
        log_operation "ERRO: Falha no mysqldump"
        rm -f "$backup_file" 2>/dev/null
        exit 1
    fi
}

# Função para backup de bancos específicos (excluindo sistema)
backup_user_databases() {
    local timestamp backup_file databases
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_file="$BKP_DIR/mysql_user_databases_$timestamp.sql"
    
    # Obter lista de bancos de usuário
    databases=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
        -e "SHOW DATABASES;" 2>/dev/null | grep -v -E '^(Database|information_schema|performance_schema|mysql|sys)$' | tr '\n' ' ')
    
    if [[ -z "$databases" ]]; then
        echo -e "${YELLOW}⚠️  Nenhum banco de usuário encontrado${NC}"
        log_operation "Nenhum banco de usuário para backup"
        return 0
    fi
    
    echo -e "${BLUE}📦 Fazendo backup dos bancos de usuário: $databases${NC}"
    log_operation "Iniciando backup de bancos de usuário: $databases"
    
    # Executar mysqldump para bancos específicos
    if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
        --routines --triggers --events --single-transaction \
        --databases $databases > "$backup_file" 2>/dev/null; then
        
        echo -e "${GREEN}✅ Dump criado com sucesso${NC}"
        log_operation "Dump de bancos de usuário criado: $backup_file"
        
        # Comprimir arquivo
        if gzip "$backup_file"; then
            backup_file="${backup_file}.gz"
            local file_size
            file_size=$(du -h "$backup_file" | cut -f1)
            
            echo -e "${GREEN}✅ Backup de bancos de usuário concluído!${NC}"
            echo -e "${CYAN}📁 Arquivo: $(basename "$backup_file")${NC}"
            echo -e "${CYAN}📊 Tamanho: $file_size${NC}"
            
            log_operation "Backup de bancos de usuário concluído: $backup_file ($file_size)"
        else
            echo -e "${RED}❌ Erro ao comprimir arquivo${NC}"
            log_operation "ERRO: Falha na compressão de bancos de usuário"
        fi
    else
        echo -e "${RED}❌ Erro ao executar mysqldump para bancos de usuário${NC}"
        log_operation "ERRO: Falha no mysqldump de bancos de usuário"
        rm -f "$backup_file" 2>/dev/null
    fi
}

# Função para limpeza de backups antigos
cleanup_old_backups() {
    local days_to_keep=${BACKUP_RETENTION_DAYS:-30}
    
    echo -e "${BLUE}🧹 Removendo backups com mais de $days_to_keep dias...${NC}"
    log_operation "Iniciando limpeza de backups antigos (>$days_to_keep dias)"
    
    local old_backups
    old_backups=$(find "$BKP_DIR" -name "*.sql.gz" -mtime +$days_to_keep 2>/dev/null)
    
    if [[ -n "$old_backups" ]]; then
        local count
        count=$(echo "$old_backups" | wc -l)
        
        echo "$old_backups" | xargs rm -f
        echo -e "${GREEN}✅ $count backups antigos removidos${NC}"
        log_operation "Limpeza concluída: $count arquivos removidos"
    else
        echo -e "${CYAN}ℹ️  Nenhum backup antigo encontrado${NC}"
        log_operation "Nenhum backup antigo para remover"
    fi
}

# Função para estatísticas de backup
show_backup_stats() {
    echo -e "${CYAN}📊 ESTATÍSTICAS DE BACKUP${NC}"
    echo -e "${CYAN}=========================${NC}"
    
    if [[ -d "$BKP_DIR" ]]; then
        local total_files total_size
        total_files=$(ls -1 "$BKP_DIR"/*.sql.gz 2>/dev/null | wc -l)
        total_size=$(du -sh "$BKP_DIR" 2>/dev/null | cut -f1)
        
        echo -e "${WHITE}📁 Diretório: $BKP_DIR${NC}"
        echo -e "${WHITE}📄 Total de arquivos: $total_files${NC}"
        echo -e "${WHITE}💾 Espaço usado: $total_size${NC}"
        
        if [[ $total_files -gt 0 ]]; then
            echo -e "${WHITE}📅 Backup mais recente:${NC}"
            ls -lt "$BKP_DIR"/*.sql.gz 2>/dev/null | head -1 | awk '{print "   " $6" "$7" "$8" - "$9}'
        fi
        
        log_operation "Estatísticas: $total_files arquivos, $total_size de espaço"
    else
        echo -e "${YELLOW}⚠️  Diretório de backup não encontrado${NC}"
    fi
}

#=============================================================================
# FUNÇÃO PRINCIPAL
#=============================================================================

main() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🐬 BACKUP MYSQL/MARIADB                              ║"
    echo "║                              Script Automatizado v2.0                         ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_operation "=== Início da sessão de backup ==="
    
    # Verificações iniciais
    echo -e "${BLUE}🔍 Verificando dependências...${NC}"
    check_dependencies
    
    echo -e "${BLUE}🔍 Verificando serviço MySQL...${NC}"
    check_mysql_service
    
    echo -e "${BLUE}🔍 Configurando diretório de backup...${NC}"
    setup_backup_directory
    
    echo -e "${BLUE}🔍 Carregando configurações...${NC}"
    load_config
    
    echo -e "${BLUE}🔍 Testando conexão MySQL...${NC}"
    test_mysql_connection
    
    echo -e "${GREEN}✅ Verificações concluídas!${NC}"
    echo
    
    # Determinar tipo de backup
    local backup_type=${BACKUP_TYPE:-"full"}
    
    case "$backup_type" in
        "full")
            backup_all_databases
            ;;
        "user")
            backup_user_databases
            ;;
        "both")
            backup_all_databases
            echo
            backup_user_databases
            ;;
        *)
            echo -e "${YELLOW}⚠️  Tipo de backup desconhecido: $backup_type${NC}"
            echo -e "${CYAN}💡 Executando backup completo como padrão${NC}"
            backup_all_databases
            ;;
    esac
    
    echo
    
    # Limpeza de backups antigos (se habilitada)
    if [[ "${CLEANUP_OLD_BACKUPS:-true}" == "true" ]]; then
        cleanup_old_backups
        echo
    fi
    
    # Mostrar estatísticas
    show_backup_stats
    
    echo
    echo -e "${GREEN}🎉 Processo de backup finalizado com sucesso!${NC}"
    log_operation "=== Fim da sessão de backup ==="
}

#=============================================================================
# TRATAMENTO DE SINAIS
#=============================================================================

# Função para cleanup em caso de interrupção
cleanup_on_exit() {
    log_operation "Backup interrompido pelo usuário ou sistema"
    echo -e "${YELLOW}⚠️  Backup interrompido${NC}"
    exit 1
}

# Registrar handlers para sinais
trap cleanup_on_exit SIGINT SIGTERM

#=============================================================================
# EXECUÇÃO
#=============================================================================

# Verificar se está sendo executado como root (recomendado)
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️  Recomendado executar como root para acesso completo aos diretórios${NC}"
fi

# Executar função principal
main "$@"

# Código de saída
exit 0