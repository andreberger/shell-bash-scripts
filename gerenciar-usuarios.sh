#!/bin/bash

#=============================================================================
# Script de Gerenciamento de Usuários
#=============================================================================
# Descrição: Script interativo para gerenciamento completo de usuários do
#            sistema através de menus organizados. Permite adicionar, listar,
#            remover usuários e gerenciar grupos com validações de segurança.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix (requer privilégios sudo)
#
# ATENÇÃO: Este script requer privilégios de administrador (sudo)
#          para realizar operações de gerenciamento de usuários
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x gerenciar-usuarios.sh
# 2. Execute o script: ./gerenciar-usuarios.sh
# 3. Escolha as opções do menu interativo
# 4. Digite sua senha sudo quando solicitado
#
# FUNCIONALIDADES:
#   • Adicionar usuários com validações
#   • Listar usuários do sistema
#   • Remover usuários com segurança
#   • Gerenciar grupos de usuários
#   • Visualizar informações detalhadas
#   • Logs de operações
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/tmp/user-management-$(date +%Y%m%d_%H%M%S).log"

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
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}    GERENCIAMENTO DE USUÁRIOS DO SISTEMA${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "${CYAN}Data/Hora: $(date '+%d/%m/%Y às %H:%M:%S')${NC}"
    echo -e "${CYAN}Log: $LOG_FILE${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

# Função para verificar se usuário existe
user_exists() {
    local username=$1
    if id "$username" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Função para validar nome de usuário
validate_username() {
    local username=$1
    
    # Verificar se não está vazio
    if [ -z "$username" ]; then
        print_message "$RED" "✗ Nome de usuário não pode estar vazio"
        return 1
    fi
    
    # Verificar caracteres válidos (apenas letras, números, hífen e underscore)
    if ! [[ "$username" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        print_message "$RED" "✗ Nome de usuário inválido. Use apenas letras, números, hífen e underscore"
        print_message "$YELLOW" "  Deve começar com uma letra"
        return 1
    fi
    
    # Verificar comprimento
    if [ ${#username} -gt 32 ]; then
        print_message "$RED" "✗ Nome de usuário muito longo (máximo 32 caracteres)"
        return 1
    fi
    
    return 0
}

# Função para adicionar usuário
add_user() {
    print_header
    echo -e "${YELLOW}=== ADICIONAR USUÁRIO ===${NC}\n"
    
    while true; do
        read -p "Digite o nome do usuário a ser adicionado: " NOVO_USUARIO
        
        if validate_username "$NOVO_USUARIO"; then
            if user_exists "$NOVO_USUARIO"; then
                print_message "$RED" "✗ Usuário '$NOVO_USUARIO' já existe!"
                read -p "Pressione Enter para tentar outro nome..."
                continue
            else
                break
            fi
        else
            read -p "Pressione Enter para tentar novamente..."
        fi
    done
    
    # Opções adicionais
    echo -e "\n${CYAN}Opções adicionais:${NC}"
    read -p "Criar diretório home? (S/n): " CREATE_HOME
    read -p "Definir shell específico? (bash/sh/zsh ou Enter para padrão): " USER_SHELL
    read -p "Adicionar a grupos específicos? (ex: sudo,docker): " USER_GROUPS
    
    # Construir comando useradd
    CMD="sudo useradd"
    
    case $CREATE_HOME in
        [nN]|[nN][aA][oO])
            CMD="$CMD --no-create-home"
            ;;
        *)
            CMD="$CMD --create-home"
            ;;
    esac
    
    if [ -n "$USER_SHELL" ]; then
        case $USER_SHELL in
            bash)
                CMD="$CMD --shell /bin/bash"
                ;;
            sh)
                CMD="$CMD --shell /bin/sh"
                ;;
            zsh)
                CMD="$CMD --shell /bin/zsh"
                ;;
            *)
                print_message "$YELLOW" "⚠ Shell '$USER_SHELL' pode não existir"
                CMD="$CMD --shell $USER_SHELL"
                ;;
        esac
    fi
    
    if [ -n "$USER_GROUPS" ]; then
        CMD="$CMD --groups $USER_GROUPS"
    fi
    
    CMD="$CMD $NOVO_USUARIO"
    
    # Executar comando
    print_message "$YELLOW" "🔄 Executando: $CMD"
    if eval "$CMD" 2>>"$LOG_FILE"; then
        print_message "$GREEN" "✓ Usuário '$NOVO_USUARIO' adicionado com sucesso!"
        
        # Definir senha
        if read -s -p "Definir senha para o usuário? (s/N): " SET_PASSWORD && echo; then
            case $SET_PASSWORD in
                [sS]|[sS][iI][mM])
                    sudo passwd "$NOVO_USUARIO"
                    ;;
            esac
        fi
        
        # Exibir informações do usuário
        echo -e "\n${CYAN}Informações do usuário criado:${NC}"
        id "$NOVO_USUARIO"
        
    else
        print_message "$RED" "✗ Erro ao adicionar usuário '$NOVO_USUARIO'"
    fi
    
    read -p "Pressione Enter para continuar..."
}

# Função para listar usuários
list_users() {
    print_header
    echo -e "${YELLOW}=== LISTA DE USUÁRIOS ===${NC}\n"
    
    echo -e "${CYAN}Escolha o tipo de listagem:${NC}"
    echo "1. Todos os usuários"
    echo "2. Apenas usuários do sistema (UID < 1000)"
    echo "3. Apenas usuários normais (UID >= 1000)"
    echo "4. Usuários logados atualmente"
    read -p "Opção: " LIST_OPTION
    
    case $LIST_OPTION in
        1)
            echo -e "\n${CYAN}Todos os usuários do sistema:${NC}"
            cut -d: -f1,3,5 /etc/passwd | column -t -s':'
            ;;
        2)
            echo -e "\n${CYAN}Usuários do sistema (UID < 1000):${NC}"
            awk -F: '$3 < 1000 {print $1, $3, $5}' /etc/passwd | column -t
            ;;
        3)
            echo -e "\n${CYAN}Usuários normais (UID >= 1000):${NC}"
            awk -F: '$3 >= 1000 {print $1, $3, $5}' /etc/passwd | column -t
            ;;
        4)
            echo -e "\n${CYAN}Usuários logados atualmente:${NC}"
            who | awk '{print $1}' | sort | uniq
            ;;
        *)
            print_message "$RED" "✗ Opção inválida"
            ;;
    esac
    
    echo -e "\n${CYAN}Total de usuários no sistema: $(wc -l < /etc/passwd)${NC}"
    read -p "Pressione Enter para continuar..."
}

# Função para remover usuário
remove_user() {
    print_header
    echo -e "${YELLOW}=== REMOVER USUÁRIO ===${NC}\n"
    
    # Listar usuários normais primeiro
    echo -e "${CYAN}Usuários disponíveis para remoção (UID >= 1000):${NC}"
    awk -F: '$3 >= 1000 {print $1}' /etc/passwd | column
    
    echo
    read -p "Digite o nome do usuário a ser removido: " USUARIO_REMOVER
    
    if [ -z "$USUARIO_REMOVER" ]; then
        print_message "$RED" "✗ Nome de usuário não pode estar vazio"
        read -p "Pressione Enter para continuar..."
        return
    fi
    
    if ! user_exists "$USUARIO_REMOVER"; then
        print_message "$RED" "✗ Usuário '$USUARIO_REMOVER' não existe!"
        read -p "Pressione Enter para continuar..."
        return
    fi
    
    # Verificar se é usuário do sistema
    USER_UID=$(id -u "$USUARIO_REMOVER")
    if [ "$USER_UID" -lt 1000 ] && [ "$USER_UID" -ne 0 ]; then
        print_message "$RED" "⚠ ATENÇÃO: '$USUARIO_REMOVER' é um usuário do sistema!"
        read -p "Tem certeza que deseja continuar? (digite 'CONFIRMAR'): " CONFIRM_SYSTEM
        if [ "$CONFIRM_SYSTEM" != "CONFIRMAR" ]; then
            print_message "$YELLOW" "Operação cancelada"
            read -p "Pressione Enter para continuar..."
            return
        fi
    fi
    
    # Verificar se usuário está logado
    if who | grep -q "^$USUARIO_REMOVER "; then
        print_message "$YELLOW" "⚠ Usuário '$USUARIO_REMOVER' está logado atualmente!"
        read -p "Deseja forçar logout? (s/N): " FORCE_LOGOUT
        case $FORCE_LOGOUT in
            [sS]|[sS][iI][mM])
                sudo pkill -u "$USUARIO_REMOVER" 2>/dev/null || true
                ;;
        esac
    fi
    
    # Opções de remoção
    echo -e "\n${CYAN}Opções de remoção:${NC}"
    read -p "Remover diretório home? (S/n): " REMOVE_HOME
    read -p "Remover emails do usuário? (S/n): " REMOVE_MAIL
    
    # Confirmação final
    echo -e "\n${RED}ATENÇÃO: Esta operação é irreversível!${NC}"
    read -p "Confirma a remoção do usuário '$USUARIO_REMOVER'? (digite 'SIM'): " CONFIRMACAO
    
    if [ "$CONFIRMACAO" = "SIM" ]; then
        CMD="sudo userdel"
        
        case $REMOVE_HOME in
            [nN]|[nN][aA][oO])
                ;;
            *)
                CMD="$CMD --remove"
                ;;
        esac
        
        case $REMOVE_MAIL in
            [nN]|[nN][aA][oO])
                ;;
            *)
                CMD="$CMD --remove-all-files"
                ;;
        esac
        
        CMD="$CMD $USUARIO_REMOVER"
        
        print_message "$YELLOW" "🔄 Executando: $CMD"
        if eval "$CMD" 2>>"$LOG_FILE"; then
            print_message "$GREEN" "✓ Usuário '$USUARIO_REMOVER' removido com sucesso!"
        else
            print_message "$RED" "✗ Erro ao remover usuário '$USUARIO_REMOVER'"
        fi
    else
        print_message "$YELLOW" "Operação cancelada"
    fi
    
    read -p "Pressione Enter para continuar..."
}

# Função para gerenciar grupos
manage_groups() {
    print_header
    echo -e "${YELLOW}=== GERENCIAR GRUPOS ===${NC}\n"
    
    echo "1. Listar grupos"
    echo "2. Adicionar usuário a grupo"
    echo "3. Remover usuário de grupo"
    echo "4. Criar novo grupo"
    echo "5. Voltar ao menu principal"
    read -p "Escolha uma opção: " GROUP_OPTION
    
    case $GROUP_OPTION in
        1)
            echo -e "\n${CYAN}Grupos do sistema:${NC}"
            cut -d: -f1 /etc/group | column
            ;;
        2)
            read -p "Nome do usuário: " USERNAME
            read -p "Nome do grupo: " GROUPNAME
            if user_exists "$USERNAME" && getent group "$GROUPNAME" >/dev/null; then
                sudo usermod -a -G "$GROUPNAME" "$USERNAME"
                print_message "$GREEN" "✓ Usuário '$USERNAME' adicionado ao grupo '$GROUPNAME'"
            else
                print_message "$RED" "✗ Usuário ou grupo não existe"
            fi
            ;;
        3)
            read -p "Nome do usuário: " USERNAME
            read -p "Nome do grupo: " GROUPNAME
            if user_exists "$USERNAME"; then
                sudo gpasswd -d "$USERNAME" "$GROUPNAME" 2>/dev/null
                print_message "$GREEN" "✓ Usuário '$USERNAME' removido do grupo '$GROUPNAME'"
            else
                print_message "$RED" "✗ Usuário não existe"
            fi
            ;;
        4)
            read -p "Nome do novo grupo: " NEWGROUP
            sudo groupadd "$NEWGROUP"
            print_message "$GREEN" "✓ Grupo '$NEWGROUP' criado com sucesso"
            ;;
        5)
            return
            ;;
        *)
            print_message "$RED" "✗ Opção inválida"
            ;;
    esac
    
    read -p "Pressione Enter para continuar..."
}

#=============================================================================
# MENU PRINCIPAL
#=============================================================================

main_menu() {
    while true; do
        print_header
        echo -e "${CYAN}MENU PRINCIPAL${NC}"
        echo -e "${BLUE}============================================${NC}"
        echo "1. 👤 Adicionar Usuário"
        echo "2. 📋 Listar Usuários"
        echo "3. 🗑️  Remover Usuário"
        echo "4. 👥 Gerenciar Grupos"
        echo "5. 📊 Estatísticas do Sistema"
        echo "6. 🚪 Sair"
        echo -e "${BLUE}============================================${NC}"
        read -p "Escolha uma opção (1-6): " OPCAO

        case $OPCAO in
            1)
                add_user
                ;;
            2)
                list_users
                ;;
            3)
                remove_user
                ;;
            4)
                manage_groups
                ;;
            5)
                print_header
                echo -e "${YELLOW}=== ESTATÍSTICAS DO SISTEMA ===${NC}\n"
                echo -e "${CYAN}Total de usuários:${NC} $(wc -l < /etc/passwd)"
                echo -e "${CYAN}Total de grupos:${NC} $(wc -l < /etc/group)"
                echo -e "${CYAN}Usuários logados:${NC} $(who | wc -l)"
                echo -e "${CYAN}Último login:${NC} $(last -1 | head -1)"
                read -p "Pressione Enter para continuar..."
                ;;
            6)
                print_message "$GREEN" "👋 Saindo do sistema de gerenciamento..."
                echo "Script finalizado em: $(date)" >> "$LOG_FILE"
                exit 0
                ;;
            *)
                print_message "$RED" "✗ Opção inválida. Escolha entre 1-6."
                read -p "Pressione Enter para tentar novamente..."
                ;;
        esac
    done
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

# Verificar se tem privilégios sudo
if ! sudo -n true 2>/dev/null; then
    print_message "$YELLOW" "Este script requer privilégios sudo. Você será solicitado a inserir sua senha."
    sudo -v
fi

echo "Script iniciado em: $(date)" >> "$LOG_FILE"
main_menu