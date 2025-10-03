#!/bin/bash

#=============================================================================
# Script de Backup de Diretório
#=============================================================================
# Descrição: Script para efetuar backup compactado de um diretório específico
#            com nomenclatura baseada na data atual e usuário logado.
#            Verifica se o backup já foi executado no dia para evitar
#            duplicações desnecessárias.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix (Bash)
#
# ATENÇÃO: Certifique-se de ter permissões de leitura no diretório origem
#          e permissões de escrita no diretório de destino
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x backup-diretorio.sh
# 2. Execute o script: ./backup-diretorio.sh
# 3. Digite o caminho completo do diretório quando solicitado
# 4. Aguarde a conclusão do backup
#
# EXEMPLO DE USO:
#   ./backup-diretorio.sh
#   Digite o caminho: /home/usuario/documentos
#   Resultado: 20251003-usuario.tar.gz
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/tmp/backup-log-$(date +%Y%m%d_%H%M%S).log"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Função para verificar se o diretório existe
check_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        print_message "$RED" "✗ Erro: Diretório '$dir' não existe!"
        exit 1
    fi
    
    if [ ! -r "$dir" ]; then
        print_message "$RED" "✗ Erro: Sem permissão de leitura no diretório '$dir'!"
        exit 1
    fi
}

# Função para calcular tamanho do diretório
calculate_size() {
    local dir=$1
    du -sh "$dir" 2>/dev/null | cut -f1 || echo "N/A"
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "=== Script de Backup de Diretório ==="
print_message "$YELLOW" "Log será salvo em: $LOG_FILE"

# Solicitar diretório para backup
while true; do
    read -p "Digite o caminho completo do diretório a ser feito backup: " DIRETORIO
    
    if [ -z "$DIRETORIO" ]; then
        print_message "$YELLOW" "⚠ Por favor, digite um caminho válido."
        continue
    fi
    
    # Expandir ~ para home directory se necessário
    DIRETORIO="${DIRETORIO/#\~/$HOME}"
    
    check_directory "$DIRETORIO"
    break
done

# Variáveis do backup
DATA=$(date +%Y%m%d)
HORA=$(date +%H%M%S)
USUARIO=$(whoami)
NOME_DIR=$(basename "$DIRETORIO")
ARQUIVO_BACKUP="${DATA}-${USUARIO}-${NOME_DIR}.tar.gz"

print_message "$BLUE" "Informações do Backup:"
echo -e "  📁 Diretório origem: $DIRETORIO"
echo -e "  📦 Arquivo destino: $ARQUIVO_BACKUP"
echo -e "  👤 Usuário: $USUARIO"
echo -e "  📅 Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')"

# Calcular tamanho do diretório
TAMANHO=$(calculate_size "$DIRETORIO")
echo -e "  📊 Tamanho estimado: $TAMANHO"

# Verificar se backup já existe
if [ -f "$ARQUIVO_BACKUP" ]; then
    print_message "$YELLOW" "⚠ O arquivo de backup '$ARQUIVO_BACKUP' já existe."
    read -p "Deseja sobrescrever? (s/N): " SOBRESCREVER
    
    case $SOBRESCREVER in
        [sS]|[sS][iI][mM])
            print_message "$YELLOW" "Sobrescrevendo arquivo existente..."
            rm -f "$ARQUIVO_BACKUP"
            ;;
        *)
            print_message "$BLUE" "Backup cancelado pelo usuário."
            exit 0
            ;;
    esac
fi

# Executar backup
print_message "$YELLOW" "🔄 Iniciando backup..."
echo "Backup iniciado em: $(date)" >> "$LOG_FILE"

# Usar tar com progresso visual se possível
if command -v pv >/dev/null 2>&1; then
    print_message "$BLUE" "Usando visualizador de progresso..."
    tar -czf - "$DIRETORIO" 2>>"$LOG_FILE" | pv -s $(du -sb "$DIRETORIO" | cut -f1) > "$ARQUIVO_BACKUP"
else
    print_message "$BLUE" "Criando arquivo compactado..."
    tar -czf "$ARQUIVO_BACKUP" "$DIRETORIO" 2>>"$LOG_FILE"
fi

# Verificar sucesso do backup
if [ $? -eq 0 ] && [ -f "$ARQUIVO_BACKUP" ]; then
    TAMANHO_BACKUP=$(du -sh "$ARQUIVO_BACKUP" | cut -f1)
    print_message "$GREEN" "✓ Backup realizado com sucesso!"
    echo -e "  📦 Arquivo: $ARQUIVO_BACKUP"
    echo -e "  📊 Tamanho do backup: $TAMANHO_BACKUP"
    echo -e "  🕒 Concluído em: $(date '+%d/%m/%Y às %H:%M:%S')"
    
    # Calcular taxa de compressão
    if [ "$TAMANHO" != "N/A" ]; then
        print_message "$BLUE" "💾 Backup criado com sucesso em $PWD/$ARQUIVO_BACKUP"
    fi
    
    echo "Backup concluído em: $(date)" >> "$LOG_FILE"
else
    print_message "$RED" "✗ Erro durante o backup!"
    print_message "$YELLOW" "Verifique o log em: $LOG_FILE"
    exit 1
fi

print_message "$GREEN" "🎉 Processo de backup finalizado!"