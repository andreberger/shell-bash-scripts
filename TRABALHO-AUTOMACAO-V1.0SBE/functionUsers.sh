#!/bin/bash

#=============================================================================
# Script: functionUsers.sh
# Descrição: Módulo de funções para gerenciamento de usuários do sistema
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
# FUNÇÕES DE SELEÇÃO E VALIDAÇÃO
#=============================================================================

# Função para selecionar usuário do sistema
selectUser() {
    getent passwd | egrep '(/bin/bash|/bin/sh)' | cut -d ':' -f 1,6 | tr ':' ' ' > /tmp/deletausuario.txt
    
    if [[ ! -s /tmp/deletausuario.txt ]]; then
        dialog \
            --title 'ERRO' \
            --msgbox 'Nenhum usuário encontrado no sistema.' \
            6 40
        return 1
    fi
    
    DEL=$(dialog --stdout \
        --title 'SELEÇÃO DE USUÁRIO' \
        --menu 'Selecione o usuário:' \
        15 50 8 \
        $(cat /tmp/deletausuario.txt))
    
    # Verificar se usuário foi selecionado
    if [[ -z "$DEL" ]]; then
        return 1
    fi
    
    return 0
}

# Função para validar nome de usuário
validate_username() {
    local username="$1"
    
    # Verificar se não está vazio
    if [[ -z "$username" ]]; then
        return 1
    fi
    
    # Verificar se já existe
    if id "$username" &>/dev/null; then
        dialog \
            --title 'USUÁRIO EXISTENTE' \
            --msgbox 'Este usuário já existe no sistema.' \
            6 40
        return 1
    fi
    
    # Verificar formato (apenas letras minúsculas, números e underscore)
    if [[ ! "$username" =~ ^[a-z][a-z0-9_-]*$ ]]; then
        dialog \
            --title 'NOME INVÁLIDO' \
            --msgbox 'Nome de usuário deve começar com letra minúscula\ne conter apenas letras, números, _ e -' \
            8 50
        return 1
    fi
    
    return 0
}

# Função para exibir arquivo em caixa de texto
textBox() {
    local file="$1"
    local title="$2"
    
    if [[ -f "$file" && -s "$file" ]]; then
        dialog \
            --title "$title" \
            --textbox "$file" \
            20 70
    else
        dialog \
            --title 'ERRO' \
            --msgbox 'Arquivo não encontrado ou vazio.' \
            6 40
    fi
    
    # Limpar arquivo temporário
    [[ -f "$file" ]] && rm -f "$file"
}

#=============================================================================
# FUNÇÕES DE LISTAGEM E BUSCA
#=============================================================================

# Função para listar usuários do sistema
listarUsuario() {
    local user_count
    getent passwd | egrep '(/bin/bash|/bin/sh)' | cut -d ':' -f1,5 | tr ':' ' - ' > /tmp/listausuario.txt
    user_count=$(wc -l < /tmp/listausuario.txt)
    
    if [[ $user_count -gt 0 ]]; then
        textBox '/tmp/listausuario.txt' "USUÁRIOS DO SISTEMA ($user_count encontrados)"
    else
        dialog \
            --title 'SISTEMA VAZIO' \
            --msgbox 'Nenhum usuário encontrado no sistema.' \
            6 40
    fi
}

# Função para buscar usuário específico
buscarUsuario() {
    local NOMEUSUARIO
    NOMEUSUARIO=$(dialog --stdout \
        --title 'BUSCAR USUÁRIO' \
        --inputbox 'Digite o nome do usuário:' \
        8 50)
    
    # Verificar se nome foi fornecido
    if [[ -z "$NOMEUSUARIO" ]]; then
        return 1
    fi
    
    # Buscar usuário e gerar relatório
    getent passwd | egrep "^$NOMEUSUARIO" | egrep '(/bin/bash|/bin/sh)' | \
    cut -d ':' -f 1,5,6,7 | tr ':' '\t' | \
    awk 'BEGIN{print "USUÁRIO\tNOME\tDIRETÓRIO\tSHELL"} {print}' > /tmp/finduser.txt
    
    if [[ -s /tmp/finduser.txt ]] && [[ $(wc -l < /tmp/finduser.txt) -gt 1 ]]; then
        textBox '/tmp/finduser.txt' "INFORMAÇÕES DO USUÁRIO: $NOMEUSUARIO"
    else
        dialog \
            --title 'USUÁRIO NÃO ENCONTRADO' \
            --msgbox "O usuário '$NOMEUSUARIO' não foi encontrado no sistema\nou não possui shell válido." \
            8 60
    fi
}

#=============================================================================
# FUNÇÕES DE ADIÇÃO DE USUÁRIOS
#=============================================================================

# Função para adicionar novo usuário
adicionarUsuario() {
    local NOME_USUARIO SENHA SENHAR pass
    
    # Solicitar nome do usuário
    while true; do
        NOME_USUARIO=$(dialog --stdout \
            --title 'ADICIONAR USUÁRIO' \
            --inputbox 'Digite o nome do usuário:' \
            8 50)
        
        # Verificar se foi cancelado
        if [[ $? -ne 0 ]] || [[ -z "$NOME_USUARIO" ]]; then
            return 1
        fi
        
        # Validar nome do usuário
        if validate_username "$NOME_USUARIO"; then
            break
        fi
    done
    
    # Solicitar senha
    while true; do
        SENHA=$(dialog --stdout \
            --title 'NOVA SENHA' \
            --passwordbox "Insira a senha para o usuário '$NOME_USUARIO':" \
            8 50)
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        # Verificar se senha não está vazia
        if [[ -z "$SENHA" ]]; then
            dialog \
                --title 'SENHA INVÁLIDA' \
                --msgbox 'A senha não pode estar vazia.' \
                6 40
            continue
        fi
        
        # Verificar tamanho mínimo da senha
        if [[ ${#SENHA} -lt 6 ]]; then
            dialog \
                --title 'SENHA MUITO CURTA' \
                --msgbox 'A senha deve ter pelo menos 6 caracteres.' \
                6 40
            continue
        fi
        
        # Confirmar senha
        SENHAR=$(dialog --stdout \
            --title 'CONFIRMAR SENHA' \
            --passwordbox 'Repita a senha:' \
            8 50)
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        # Verificar se senhas coincidem
        if [[ "$SENHA" == "$SENHAR" ]]; then
            break
        else
            dialog \
                --title 'SENHAS NÃO COINCIDEM' \
                --msgbox 'As senhas informadas não coincidem.\nTente novamente.' \
                7 50
        fi
    done
    
    # Criar usuário
    if useradd -m -s /bin/bash "$NOME_USUARIO" 2>/dev/null; then
        # Definir senha
        echo "$NOME_USUARIO:$SENHA" | chpasswd
        
        # Sucesso
        dialog \
            --title 'USUÁRIO CRIADO' \
            --msgbox "Usuário '$NOME_USUARIO' criado com sucesso!\n\n• Diretório home criado\n• Shell: /bin/bash\n• Senha definida" \
            10 50
        
        # Log da operação
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Usuário criado: $NOME_USUARIO" >> /tmp/sisbkt2g2-users.log
    else
        dialog \
            --title 'ERRO NA CRIAÇÃO' \
            --msgbox "Erro ao criar o usuário '$NOME_USUARIO'.\nVerifique as permissões do sistema." \
            8 50
    fi
}

#=============================================================================
# FUNÇÕES DE ALTERAÇÃO DE USUÁRIOS
#=============================================================================

# Função principal para alterar usuário
alteraUsuario() {
    while true; do
        local ALTER_MENU
        ALTER_MENU=$(dialog --stdout \
            --title 'ALTERAÇÃO DE USUÁRIO' \
            --menu 'Selecione o que deseja alterar:' \
            12 50 5 \
            1 'Nome de login' \
            2 'Descrição/Comentário' \
            3 'Shell padrão' \
            4 'Senha do usuário' \
            0 'Voltar ao menu anterior')
        
        # Verificar se foi cancelado
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        case "$ALTER_MENU" in
            1) alterar_login ;;
            2) alterar_descricao ;;
            3) alterar_shell ;;
            4) alterar_senha ;;
            0) break ;;
        esac
    done
}

# Função para alterar login do usuário
alterar_login() {
    if ! selectUser; then
        return 1
    fi
    
    dialog --yesno "Você está alterando o nome de login do usuário '$DEL'.\n\nEsta operação pode afetar arquivos e processos.\nTem certeza que deseja continuar?" \
        10 60
    
    if [[ $? -eq 0 ]]; then
        local NEWLOG
        NEWLOG=$(dialog --stdout \
            --title 'NOVO NOME DE LOGIN' \
            --inputbox "Digite o novo nome para o usuário '$DEL':" \
            8 50)
        
        if [[ $? -ne 0 ]] || [[ -z "$NEWLOG" ]]; then
            return 1
        fi
        
        # Validar novo nome
        if validate_username "$NEWLOG"; then
            if usermod -l "$NEWLOG" "$DEL" 2>/dev/null; then
                dialog \
                    --title 'LOGIN ALTERADO' \
                    --msgbox "Login alterado com sucesso!\n\nAntigo: $DEL\nNovo: $NEWLOG" \
                    8 50
                
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Login alterado: $DEL -> $NEWLOG" >> /tmp/sisbkt2g2-users.log
            else
                dialog \
                    --title 'ERRO NA ALTERAÇÃO' \
                    --msgbox 'Erro ao alterar o nome de login.\nVerifique se o usuário não está logado.' \
                    8 50
            fi
        fi
    fi
}

# Função para alterar descrição do usuário
alterar_descricao() {
    if ! selectUser; then
        return 1
    fi
    
    # Obter descrição atual
    local current_desc
    current_desc=$(getent passwd "$DEL" | cut -d: -f5)
    
    dialog --yesno "Alterando descrição do usuário '$DEL'.\n\nDescrição atual: '$current_desc'\n\nContinuar?" \
        10 60
    
    if [[ $? -eq 0 ]]; then
        local NEWCOM
        NEWCOM=$(dialog --stdout \
            --title 'NOVA DESCRIÇÃO' \
            --inputbox "Digite a nova descrição para '$DEL':" \
            8 50 "$current_desc")
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        if usermod -c "$NEWCOM" "$DEL" 2>/dev/null; then
            dialog \
                --title 'DESCRIÇÃO ALTERADA' \
                --msgbox "Descrição alterada com sucesso!\n\nUsuário: $DEL\nNova descrição: '$NEWCOM'" \
                9 60
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Descrição alterada: $DEL" >> /tmp/sisbkt2g2-users.log
        else
            dialog \
                --title 'ERRO NA ALTERAÇÃO' \
                --msgbox 'Erro ao alterar a descrição do usuário.' \
                6 50
        fi
    fi
}

# Função para alterar shell do usuário
alterar_shell() {
    if ! selectUser; then
        return 1
    fi
    
    # Obter shell atual
    local current_shell
    current_shell=$(getent passwd "$DEL" | cut -d: -f7)
    
    # Menu de shells disponíveis
    local NEWSHELL
    NEWSHELL=$(dialog --stdout \
        --title 'ALTERAR SHELL' \
        --menu "Selecione o novo shell para '$DEL':\n\nShell atual: $current_shell" \
        15 60 6 \
        '/bin/bash' 'Bash - Shell padrão' \
        '/bin/sh' 'Bourne Shell - Básico' \
        '/bin/zsh' 'Z Shell - Avançado' \
        '/bin/fish' 'Fish Shell - Moderno' \
        '/bin/dash' 'Dash - Rápido' \
        'personalizado' 'Digitar caminho personalizado')
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Se escolheu personalizado, solicitar caminho
    if [[ "$NEWSHELL" == "personalizado" ]]; then
        NEWSHELL=$(dialog --stdout \
            --title 'SHELL PERSONALIZADO' \
            --inputbox "Digite o caminho completo do shell para '$DEL':" \
            8 60 "$current_shell")
        
        if [[ $? -ne 0 ]] || [[ -z "$NEWSHELL" ]]; then
            return 1
        fi
    fi
    
    # Verificar se o shell existe
    if [[ ! -x "$NEWSHELL" ]]; then
        dialog \
            --title 'SHELL INVÁLIDO' \
            --msgbox "O shell '$NEWSHELL' não existe ou não é executável." \
            7 60
        return 1
    fi
    
    # Confirmar alteração
    dialog --yesno "Alterar shell do usuário '$DEL'?\n\nDe: $current_shell\nPara: $NEWSHELL" \
        9 60
    
    if [[ $? -eq 0 ]]; then
        if usermod -s "$NEWSHELL" "$DEL" 2>/dev/null; then
            dialog \
                --title 'SHELL ALTERADO' \
                --msgbox "Shell alterado com sucesso!\n\nUsuário: $DEL\nNovo shell: $NEWSHELL" \
                9 60
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Shell alterado: $DEL -> $NEWSHELL" >> /tmp/sisbkt2g2-users.log
        else
            dialog \
                --title 'ERRO NA ALTERAÇÃO' \
                --msgbox 'Erro ao alterar o shell do usuário.' \
                6 50
        fi
    fi
}

# Função para alterar senha do usuário
alterar_senha() {
    if ! selectUser; then
        return 1
    fi
    
    dialog --yesno "Alterando senha do usuário '$DEL'.\n\nContinuar?" \
        8 50
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local SENHA SENHAR
    
    # Solicitar nova senha
    while true; do
        SENHA=$(dialog --stdout \
            --title 'NOVA SENHA' \
            --passwordbox "Digite a nova senha para '$DEL':" \
            8 50)
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        # Verificar se senha não está vazia
        if [[ -z "$SENHA" ]]; then
            dialog \
                --title 'SENHA INVÁLIDA' \
                --msgbox 'A senha não pode estar vazia.' \
                6 40
            continue
        fi
        
        # Verificar tamanho mínimo
        if [[ ${#SENHA} -lt 6 ]]; then
            dialog \
                --title 'SENHA MUITO CURTA' \
                --msgbox 'A senha deve ter pelo menos 6 caracteres.' \
                6 40
            continue
        fi
        
        # Confirmar senha
        SENHAR=$(dialog --stdout \
            --title 'CONFIRMAR SENHA' \
            --passwordbox 'Repita a nova senha:' \
            8 50)
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        # Verificar se senhas coincidem
        if [[ "$SENHA" == "$SENHAR" ]]; then
            break
        else
            dialog \
                --title 'SENHAS NÃO COINCIDEM' \
                --msgbox 'As senhas informadas não coincidem.\nTente novamente.' \
                7 50
        fi
    done
    
    # Alterar senha
    if echo "$DEL:$SENHA" | chpasswd 2>/dev/null; then
        dialog \
            --title 'SENHA ALTERADA' \
            --msgbox "A senha do usuário '$DEL' foi alterada com sucesso!" \
            7 50
        
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Senha alterada: $DEL" >> /tmp/sisbkt2g2-users.log
    else
        dialog \
            --title 'ERRO NA ALTERAÇÃO' \
            --msgbox 'Erro ao alterar a senha do usuário.' \
            6 50
    fi
}

#=============================================================================
# FUNÇÕES DE REMOÇÃO DE USUÁRIOS
#=============================================================================

# Função para deletar usuário
deletaUsuario() {
    if ! selectUser; then
        return 1
    fi
    
    # Verificar se usuário está logado
    if who | grep -q "^$DEL "; then
        dialog \
            --title 'USUÁRIO ATIVO' \
            --msgbox "O usuário '$DEL' está atualmente logado no sistema.\n\nNão é possível removê-lo neste momento." \
            8 60
        return 1
    fi
    
    # Confirmação inicial
    dialog --yesno "⚠️  ATENÇÃO: OPERAÇÃO IRREVERSÍVEL ⚠️\n\nVocê está excluindo o usuário '$DEL'.\n\nEsta ação não pode ser desfeita.\nTem certeza que deseja continuar?" \
        11 60
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Perguntar sobre o diretório home
    dialog --yesno "Deseja também remover o diretório home do usuário?\n\nDiretório: $(getent passwd "$DEL" | cut -d: -f6)\n\n⚠️  Todos os arquivos serão perdidos!" \
        10 60
    
    local remove_home=$?
    
    # Executar remoção
    if [[ $remove_home -eq 0 ]]; then
        # Remover com diretório home
        if userdel -r "$DEL" 2>/dev/null; then
            # Tentar remover grupo se existir
            groupdel "$DEL" 2>/dev/null
            
            dialog \
                --title 'USUÁRIO REMOVIDO' \
                --msgbox "✅ Usuário '$DEL' removido com sucesso!\n\n• Conta de usuário excluída\n• Diretório home removido\n• Grupo removido (se existia)" \
                10 60
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Usuário removido (com home): $DEL" >> /tmp/sisbkt2g2-users.log
        else
            dialog \
                --title 'ERRO NA REMOÇÃO' \
                --msgbox "Erro ao remover o usuário '$DEL'.\n\nO usuário pode estar sendo usado por processos ativos." \
                8 60
        fi
    else
        # Remover apenas a conta
        if userdel "$DEL" 2>/dev/null; then
            # Tentar remover grupo se existir
            groupdel "$DEL" 2>/dev/null
            
            dialog \
                --title 'USUÁRIO REMOVIDO' \
                --msgbox "✅ Usuário '$DEL' removido com sucesso!\n\n• Conta de usuário excluída\n• Diretório home preservado\n• Grupo removido (se existia)" \
                10 60
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Usuário removido (sem home): $DEL" >> /tmp/sisbkt2g2-users.log
        else
            dialog \
                --title 'ERRO NA REMOÇÃO' \
                --msgbox "Erro ao remover o usuário '$DEL'.\n\nVerifique se o usuário não está sendo usado por processos." \
                8 60
        fi
    fi
}

#=============================================================================
# FUNÇÕES DE ESTATÍSTICAS E RELATÓRIOS
#=============================================================================

# Função para exibir estatísticas de usuários
mostrar_estatisticas_usuarios() {
    local total_users normal_users system_users logged_users
    
    # Contar usuários
    total_users=$(getent passwd | wc -l)
    normal_users=$(getent passwd | egrep '(/bin/bash|/bin/sh)' | wc -l)
    system_users=$((total_users - normal_users))
    logged_users=$(who | cut -d' ' -f1 | sort -u | wc -l)
    
    # Criar relatório
    {
        echo "ESTATÍSTICAS DE USUÁRIOS DO SISTEMA"
        echo "===================================="
        echo
        echo "Total de usuários: $total_users"
        echo "Usuários normais: $normal_users"
        echo "Usuários do sistema: $system_users"
        echo "Usuários logados: $logged_users"
        echo
        echo "USUÁRIOS LOGADOS ATUALMENTE:"
        echo "----------------------------"
        if [[ $logged_users -gt 0 ]]; then
            who | awk '{print $1 " - " $3 " " $4 " (" $2 ")"}'
        else
            echo "Nenhum usuário logado"
        fi
        echo
        echo "ÚLTIMOS LOGINS:"
        echo "---------------"
        last -n 10 | head -10
    } > /tmp/user_stats.txt
    
    textBox '/tmp/user_stats.txt' 'ESTATÍSTICAS DE USUÁRIOS'
}

# Limpar arquivos temporários ao sair
cleanup_temp_files_users() {
    rm -f /tmp/deletausuario.txt /tmp/listausuario.txt /tmp/finduser.txt /tmp/user_stats.txt 2>/dev/null
}

# Registrar cleanup para ser executado ao sair
trap cleanup_temp_files_users EXIT