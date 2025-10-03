#!/bin/bash

#=============================================================================
# Script de Formulário com Zenity
#=============================================================================
# Descrição: Script para criar formulários interativos usando Zenity,
#            permitindo adicionar informações de contatos através de
#            uma interface gráfica amigável. Os dados são salvos em
#            arquivo CSV para fácil manipulação.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux (com Zenity instalado)
# Dependências: zenity
#
# ATENÇÃO: Certifique-se de ter o Zenity instalado no sistema
#          Ubuntu/Debian: sudo apt install zenity
#          CentOS/RHEL: sudo yum install zenity
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Verifique se o Zenity está instalado: zenity --version
# 2. Torne o script executável: chmod +x forms.sh
# 3. Execute o script: ./forms.sh
# 4. Preencha o formulário que será exibido
# 5. Os dados serão salvos no arquivo addr.csv
#
# FUNCIONALIDADES:
#   • Interface gráfica para entrada de dados
#   • Validação de entrada
#   • Salvamento em formato CSV
#   • Notificações visuais de status
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/tmp/forms-log-$(date +%Y%m%d_%H%M%S).log"
CSV_FILE="addr.csv"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para imprimir mensagens coloridas (para terminal)
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

# Função para verificar dependências
check_dependencies() {
    if ! command -v zenity >/dev/null 2>&1; then
        print_message "$RED" "✗ Erro: Zenity não está instalado!"
        print_message "$YELLOW" "Para instalar:"
        print_message "$YELLOW" "  Ubuntu/Debian: sudo apt install zenity"
        print_message "$YELLOW" "  CentOS/RHEL: sudo yum install zenity"
        print_message "$YELLOW" "  Fedora: sudo dnf install zenity"
        exit 1
    fi
}

# Função para inicializar arquivo CSV se não existir
initialize_csv() {
    if [ ! -f "$CSV_FILE" ]; then
        echo "Nome,Sobrenome,Email,Aniversário" > "$CSV_FILE"
        print_message "$BLUE" "📄 Arquivo CSV criado: $CSV_FILE"
    fi
}

# Função para validar email (básico)
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Função para exibir estatísticas do arquivo
show_statistics() {
    if [ -f "$CSV_FILE" ]; then
        local total_contacts=$(($(wc -l < "$CSV_FILE") - 1))
        print_message "$BLUE" "📊 Total de contatos salvos: $total_contacts"
    fi
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "=== Script de Formulário de Contatos ==="
print_message "$YELLOW" "Log será salvo em: $LOG_FILE"

# Verificar dependências
check_dependencies

# Inicializar arquivo CSV
initialize_csv

# Exibir informações iniciais
show_statistics

# Exibir formulário principal
print_message "$YELLOW" "🔄 Abrindo formulário de contato..."

FORM_DATA=$(zenity --forms \
    --title="Adicionar Amigo/Contato" \
    --text="Digite as informações do seu amigo/contato." \
    --separator="," \
    --add-entry="Nome:" \
    --add-entry="Sobrenome:" \
    --add-entry="Email:" \
    --add-calendar="Data de Aniversário:" \
    2>/dev/null)

# Capturar código de saída do Zenity
EXIT_CODE=$?

case $EXIT_CODE in
    0)
        # Usuário clicou OK - processar dados
        if [ -n "$FORM_DATA" ]; then
            # Separar os dados
            IFS=',' read -r NOME SOBRENOME EMAIL ANIVERSARIO <<< "$FORM_DATA"
            
            # Validações básicas
            if [ -z "$NOME" ] || [ -z "$SOBRENOME" ]; then
                zenity --error \
                    --title="Erro de Validação" \
                    --text="Nome e Sobrenome são obrigatórios!"
                print_message "$RED" "✗ Erro: Campos obrigatórios não preenchidos"
                exit 1
            fi
            
            # Validar email se fornecido
            if [ -n "$EMAIL" ] && ! validate_email "$EMAIL"; then
                zenity --error \
                    --title="Erro de Validação" \
                    --text="Email inválido: $EMAIL"
                print_message "$RED" "✗ Erro: Email inválido"
                exit 1
            fi
            
            # Salvar no arquivo CSV
            echo "$FORM_DATA" >> "$CSV_FILE"
            
            # Mensagem de sucesso
            zenity --info \
                --title="Sucesso" \
                --text="Contato '$NOME $SOBRENOME' adicionado com sucesso!"
            
            zenity --notification \
                --window-icon="info" \
                --text="Contato salvo com sucesso em $CSV_FILE"
            
            print_message "$GREEN" "✓ Contato adicionado: $NOME $SOBRENOME"
            show_statistics
            
        else
            zenity --warning \
                --title="Formulário Vazio" \
                --text="Nenhum dado foi inserido no formulário."
            print_message "$YELLOW" "⚠ Formulário estava vazio"
        fi
        ;;
    1)
        # Usuário clicou Cancelar
        zenity --info \
            --title="Operação Cancelada" \
            --text="Nenhum contato foi adicionado."
        
        zenity --notification \
            --window-icon="info" \
            --text="Operação cancelada pelo usuário"
        
        print_message "$YELLOW" "⚠ Operação cancelada pelo usuário"
        ;;
    -1)
        # Erro inesperado
        zenity --error \
            --title="Erro Inesperado" \
            --text="Ocorreu um erro inesperado durante a operação."
        
        zenity --notification \
            --window-icon="error" \
            --text="Erro inesperado no formulário"
        
        print_message "$RED" "✗ Erro inesperado ocorreu"
        exit 1
        ;;
esac

# Opção para visualizar arquivo CSV
if [ -f "$CSV_FILE" ] && [ $EXIT_CODE -eq 0 ]; then
    if zenity --question \
        --title="Visualizar Contatos" \
        --text="Deseja visualizar a lista de contatos salvos?"; then
        
        if command -v column >/dev/null 2>&1; then
            # Exibir formatado se column estiver disponível
            FORMATTED_DATA=$(column -t -s',' "$CSV_FILE")
            zenity --text-info \
                --title="Lista de Contatos" \
                --width=600 \
                --height=400 \
                --filename=<(echo "$FORMATTED_DATA")
        else
            # Exibir arquivo direto
            zenity --text-info \
                --title="Lista de Contatos" \
                --width=600 \
                --height=400 \
                --filename="$CSV_FILE"
        fi
    fi
fi

print_message "$GREEN" "🎉 Script finalizado com sucesso!"
print_message "$BLUE" "📄 Dados salvos em: $PWD/$CSV_FILE"