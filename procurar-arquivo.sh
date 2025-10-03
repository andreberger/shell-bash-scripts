#!/bin/bash

#=============================================================================
# Script de Busca de Arquivos
#=============================================================================
# Descrição: Script para localizar arquivos no sistema de forma eficiente
#            usando diferentes critérios de busca como nome, extensão,
#            tamanho, data de modificação e conteúdo.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x procurar-arquivo.sh
# 2. Execute o script: ./procurar-arquivo.sh
# 3. Escolha o tipo de busca no menu
# 4. Digite os critérios quando solicitado
#
# EXEMPLO DE USO:
#   Buscar arquivos .txt: *.txt
#   Buscar por nome: documento
#   Buscar por conteúdo: "texto específico"
#=============================================================================

# Configurações globais
set -e
LOG_FILE="/tmp/file-search-$(date +%Y%m%d_%H%M%S).log"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Função para imprimir mensagens coloridas
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

# Função para buscar por nome
search_by_name() {
    read -p "Digite o nome ou padrão do arquivo: " PATTERN
    read -p "Digite o diretório de busca (Enter para atual): " SEARCH_DIR
    SEARCH_DIR=${SEARCH_DIR:-.}
    
    print_message "$YELLOW" "🔍 Buscando arquivos com padrão '$PATTERN' em '$SEARCH_DIR'..."
    
    find "$SEARCH_DIR" -type f -name "*$PATTERN*" 2>/dev/null | while read file; do
        echo -e "${GREEN}📄 $file${NC}"
        ls -lh "$file" | awk '{print "   Tamanho: " $5 ", Modificado: " $6 " " $7 " " $8}'
    done
}

# Função para buscar por extensão
search_by_extension() {
    read -p "Digite a extensão (ex: txt, pdf, jpg): " EXT
    read -p "Digite o diretório de busca (Enter para atual): " SEARCH_DIR
    SEARCH_DIR=${SEARCH_DIR:-.}
    
    print_message "$YELLOW" "🔍 Buscando arquivos .$EXT em '$SEARCH_DIR'..."
    
    find "$SEARCH_DIR" -type f -name "*.$EXT" 2>/dev/null | while read file; do
        echo -e "${GREEN}📄 $file${NC}"
        ls -lh "$file" | awk '{print "   Tamanho: " $5 ", Modificado: " $6 " " $7 " " $8}'
    done
}

# Função para buscar por conteúdo
search_by_content() {
    read -p "Digite o texto a buscar: " CONTENT
    read -p "Digite o diretório de busca (Enter para atual): " SEARCH_DIR
    SEARCH_DIR=${SEARCH_DIR:-.}
    
    print_message "$YELLOW" "🔍 Buscando '$CONTENT' em arquivos de '$SEARCH_DIR'..."
    
    grep -r "$CONTENT" "$SEARCH_DIR" 2>/dev/null | while IFS=: read file line; do
        echo -e "${GREEN}📄 $file${NC}"
        echo -e "   ${CYAN}Linha: $line${NC}"
    done
}

# Menu principal
while true; do
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}        SISTEMA DE BUSCA DE ARQUIVOS${NC}"
    echo -e "${BLUE}============================================${NC}\n"
    
    echo "1. 📁 Buscar por nome"
    echo "2. 📋 Buscar por extensão"
    echo "3. 🔍 Buscar por conteúdo"
    echo "4. 📊 Estatísticas do diretório"
    echo "5. 🚪 Sair"
    
    read -p "Escolha uma opção: " OPCAO
    
    case $OPCAO in
        1) search_by_name ;;
        2) search_by_extension ;;
        3) search_by_content ;;
        4)
            read -p "Digite o diretório (Enter para atual): " DIR
            DIR=${DIR:-.}
            print_message "$CYAN" "📊 Estatísticas de $DIR:"
            echo "   Total de arquivos: $(find "$DIR" -type f 2>/dev/null | wc -l)"
            echo "   Total de diretórios: $(find "$DIR" -type d 2>/dev/null | wc -l)"
            echo "   Espaço ocupado: $(du -sh "$DIR" 2>/dev/null | cut -f1)"
            ;;
        5)
            print_message "$GREEN" "👋 Saindo..."
            exit 0
            ;;
        *)
            print_message "$RED" "✗ Opção inválida!"
            ;;
    esac
    
    read -p "Pressione Enter para continuar..."
done