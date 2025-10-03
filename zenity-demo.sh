#!/bin/bash

#=============================================================================
# Script Demonstrativo do Zenity
#=============================================================================
# Descrição: Script completo demonstrando todas as funcionalidades do Zenity,
#            uma ferramenta para criar interfaces gráficas em shell scripts.
#            Inclui exemplos de diálogos, formulários, seletores e mais.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux (requer Zenity)
# Dependências: zenity
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Instale o Zenity se necessário:
#    Ubuntu/Debian: sudo apt install zenity
#    CentOS/RHEL: sudo yum install zenity
#    Fedora: sudo dnf install zenity
# 2. Torne o script executável: chmod +x zenity-demo.sh
# 3. Execute o script: ./zenity-demo.sh
# 4. Navegue pelos exemplos usando o menu
#
# FUNCIONALIDADES DEMONSTRADAS:
#   • Diálogos de informação, erro e aviso
#   • Formulários de entrada de dados
#   • Seletores de arquivos e pastas
#   • Barras de progresso
#   • Listas de seleção
#   • Calendários
#   • Notificações
#=============================================================================

# Configurações globais
LOG_FILE="/tmp/zenity-demo-$(date +%Y%m%d_%H%M%S).log"

# Cores para output no terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

check_zenity() {
    if ! command -v zenity >/dev/null 2>&1; then
        echo -e "${RED}✗ Erro: Zenity não está instalado!${NC}"
        echo -e "${YELLOW}Para instalar:${NC}"
        echo -e "  Ubuntu/Debian: ${CYAN}sudo apt install zenity${NC}"
        echo -e "  CentOS/RHEL: ${CYAN}sudo yum install zenity${NC}"
        echo -e "  Fedora: ${CYAN}sudo dnf install zenity${NC}"
        exit 1
    fi
}

show_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    ZENITY DEMONSTRATION                       ║${NC}"
    echo -e "${BLUE}║                      Script v2.0                              ║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║ ${CYAN}Demonstração completa das funcionalidades do Zenity${BLUE}           ║${NC}"
    echo -e "${BLUE}║ ${CYAN}Interface gráfica para scripts shell${BLUE}                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

#=============================================================================
# DEMONSTRAÇÕES
#=============================================================================

demo_info_dialogs() {
    print_message "$YELLOW" "🔄 Demonstrando diálogos informativos..."
    
    # Diálogo de informação
    zenity --info \
        --title="Informação" \
        --text="Este é um diálogo de informação.\n\nUsado para mostrar mensagens importantes ao usuário." \
        --width=400
    
    # Diálogo de aviso
    zenity --warning \
        --title="Aviso" \
        --text="Este é um diálogo de aviso!\n\nUsado para alertar sobre situações que requerem atenção." \
        --width=400
    
    # Diálogo de erro
    zenity --error \
        --title="Erro" \
        --text="Este é um diálogo de erro!\n\nUsado para reportar problemas ou falhas." \
        --width=400
    
    print_message "$GREEN" "✓ Diálogos informativos demonstrados!"
}

demo_question_dialog() {
    print_message "$YELLOW" "🔄 Demonstrando diálogo de pergunta..."
    
    if zenity --question \
        --title="Pergunta" \
        --text="Você gosta desta demonstração do Zenity?\n\nClique em 'Sim' se estiver gostando!" \
        --width=400; then
        
        zenity --info \
            --title="Resposta" \
            --text="Que bom que você está gostando! 😊\n\nO Zenity é realmente uma ferramenta útil."
    else
        zenity --info \
            --title="Resposta" \
            --text="Tudo bem! Talvez você encontre algo interessante nos próximos exemplos. 🤔"
    fi
    
    print_message "$GREEN" "✓ Diálogo de pergunta demonstrado!"
}

demo_entry_dialog() {
    print_message "$YELLOW" "🔄 Demonstrando entrada de texto..."
    
    # Entrada simples
    NOME=$(zenity --entry \
        --title="Entrada de Dados" \
        --text="Digite seu nome:" \
        --entry-text="Seu nome aqui")
    
    if [ $? -eq 0 ] && [ -n "$NOME" ]; then
        zenity --info \
            --title="Olá!" \
            --text="Olá, $NOME! 👋\n\nPrazer em conhecê-lo!"
        
        # Entrada de senha
        SENHA=$(zenity --password \
            --title="Senha" \
            --text="Digite uma senha fictícia:")
        
        if [ $? -eq 0 ]; then
            zenity --info \
                --title="Senha Recebida" \
                --text="Senha recebida com sucesso!\n\n(Não se preocupe, não foi salva) 🔒"
        fi
    else
        zenity --warning \
            --title="Entrada Cancelada" \
            --text="Entrada de dados foi cancelada."
    fi
    
    print_message "$GREEN" "✓ Entrada de texto demonstrada!"
}

demo_forms() {
    print_message "$YELLOW" "🔄 Demonstrando formulários..."
    
    DADOS=$(zenity --forms \
        --title="Formulário de Cadastro" \
        --text="Preencha o formulário abaixo:" \
        --separator="|" \
        --add-entry="Nome Completo:" \
        --add-entry="Email:" \
        --add-entry="Telefone:" \
        --add-calendar="Data de Nascimento:" \
        --add-combo="Estado Civil:" \
        --combo-values="Solteiro|Casado|Divorciado|Viúvo" \
        --add-combo="Escolaridade:" \
        --combo-values="Fundamental|Médio|Superior|Pós-graduação")
    
    if [ $? -eq 0 ] && [ -n "$DADOS" ]; then
        # Processar dados
        IFS='|' read -r nome email telefone nascimento estado_civil escolaridade <<< "$DADOS"
        
        zenity --text-info \
            --title="Dados Recebidos" \
            --width=500 \
            --height=300 \
            --filename=<(cat << EOF
╔══════════════════════════════════════════════════════════════╗
║                    DADOS DO FORMULÁRIO                      ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║ Nome Completo: $nome
║ Email: $email
║ Telefone: $telefone
║ Data de Nascimento: $nascimento
║ Estado Civil: $estado_civil
║ Escolaridade: $escolaridade
║                                                              ║
║ Data de Preenchimento: $(date '+%d/%m/%Y às %H:%M:%S')
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
)
    else
        zenity --info \
            --title="Formulário Cancelado" \
            --text="O preenchimento do formulário foi cancelado."
    fi
    
    print_message "$GREEN" "✓ Formulários demonstrados!"
}

demo_file_selection() {
    print_message "$YELLOW" "🔄 Demonstrando seleção de arquivos..."
    
    # Seletor de arquivo
    ARQUIVO=$(zenity --file-selection \
        --title="Selecione um arquivo" \
        --file-filter="Arquivos de texto | *.txt *.md" \
        --file-filter="Todos os arquivos | *")
    
    if [ $? -eq 0 ] && [ -n "$ARQUIVO" ]; then
        zenity --info \
            --title="Arquivo Selecionado" \
            --text="Arquivo selecionado:\n$ARQUIVO\n\nTamanho: $(du -sh "$ARQUIVO" 2>/dev/null | cut -f1 || echo "N/A")"
        
        # Seletor de pasta
        PASTA=$(zenity --file-selection \
            --directory \
            --title="Agora selecione uma pasta")
        
        if [ $? -eq 0 ] && [ -n "$PASTA" ]; then
            zenity --info \
                --title="Pasta Selecionada" \
                --text="Pasta selecionada:\n$PASTA\n\nConteúdo: $(ls -1 "$PASTA" 2>/dev/null | wc -l) itens"
        fi
    else
        zenity --info \
            --title="Seleção Cancelada" \
            --text="Seleção de arquivo foi cancelada."
    fi
    
    print_message "$GREEN" "✓ Seleção de arquivos demonstrada!"
}

demo_lists() {
    print_message "$YELLOW" "🔄 Demonstrando listas de seleção..."
    
    # Lista simples
    OPCAO=$(zenity --list \
        --title="Lista de Opções" \
        --text="Selecione sua linguagem de programação favorita:" \
        --column="Linguagem" \
        --column="Descrição" \
        "Bash" "Shell scripting" \
        "Python" "Linguagem versátil" \
        "JavaScript" "Web development" \
        "C++" "Performance e sistemas" \
        "Java" "Multiplataforma" \
        "Go" "Linguagem moderna" \
        --width=500 \
        --height=400)
    
    if [ $? -eq 0 ] && [ -n "$OPCAO" ]; then
        zenity --info \
            --title="Seleção" \
            --text="Você selecionou: $OPCAO\n\nÓtima escolha! 👍"
        
        # Lista com checklist
        CORES=$(zenity --list \
            --title="Cores Favoritas" \
            --text="Selecione suas cores favoritas (múltipla seleção):" \
            --checklist \
            --column="Seleção" \
            --column="Cor" \
            --column="Código Hex" \
            FALSE "Azul" "#0000FF" \
            FALSE "Verde" "#00FF00" \
            FALSE "Vermelho" "#FF0000" \
            FALSE "Amarelo" "#FFFF00" \
            FALSE "Roxo" "#800080" \
            FALSE "Laranja" "#FFA500" \
            --width=400 \
            --height=350 \
            --separator=",")
        
        if [ $? -eq 0 ] && [ -n "$CORES" ]; then
            zenity --info \
                --title="Cores Selecionadas" \
                --text="Suas cores favoritas:\n$CORES\n\nBela combinação! 🎨"
        fi
    else
        zenity --info \
            --title="Seleção Cancelada" \
            --text="Nenhuma linguagem foi selecionada."
    fi
    
    print_message "$GREEN" "✓ Listas de seleção demonstradas!"
}

demo_progress() {
    print_message "$YELLOW" "🔄 Demonstrando barra de progresso..."
    
    # Barra de progresso com porcentagem
    (
        echo "# Inicializando processo..."
        echo "10"
        sleep 1
        
        echo "# Carregando dados..."
        echo "30"
        sleep 1
        
        echo "# Processando informações..."
        echo "50"
        sleep 1
        
        echo "# Aplicando configurações..."
        echo "70"
        sleep 1
        
        echo "# Finalizando..."
        echo "90"
        sleep 1
        
        echo "# Concluído!"
        echo "100"
        sleep 1
    ) | zenity --progress \
        --title="Progresso da Operação" \
        --text="Aguarde..." \
        --percentage=0 \
        --width=400
    
    if [ $? -eq 0 ]; then
        zenity --info \
            --title="Processo Concluído" \
            --text="O processo foi concluído com sucesso! ✅"
    else
        zenity --warning \
            --title="Processo Cancelado" \
            --text="O processo foi cancelado pelo usuário."
    fi
    
    print_message "$GREEN" "✓ Barra de progresso demonstrada!"
}

demo_calendar() {
    print_message "$YELLOW" "🔄 Demonstrando calendário..."
    
    DATA=$(zenity --calendar \
        --title="Seleção de Data" \
        --text="Selecione uma data importante:" \
        --date-format="%d/%m/%Y")
    
    if [ $? -eq 0 ] && [ -n "$DATA" ]; then
        zenity --info \
            --title="Data Selecionada" \
            --text="Data selecionada: $DATA\n\nEsta data foi salva na memória! 📅"
    else
        zenity --info \
            --title="Seleção Cancelada" \
            --text="Nenhuma data foi selecionada."
    fi
    
    print_message "$GREEN" "✓ Calendário demonstrado!"
}

demo_notifications() {
    print_message "$YELLOW" "🔄 Demonstrando notificações..."
    
    # Notificação simples
    zenity --notification \
        --text="Esta é uma notificação simples!"
    
    sleep 2
    
    # Notificação com ícone
    zenity --notification \
        --window-icon="info" \
        --text="Notificação com ícone de informação"
    
    sleep 2
    
    # Notificação crítica
    zenity --notification \
        --window-icon="error" \
        --text="Notificação crítica - Atenção necessária!"
    
    zenity --info \
        --title="Notificações" \
        --text="Três notificações foram enviadas!\n\nVerifique a área de notificações do seu sistema. 🔔"
    
    print_message "$GREEN" "✓ Notificações demonstradas!"
}

demo_text_info() {
    print_message "$YELLOW" "🔄 Demonstrando visualização de texto..."
    
    # Criar arquivo temporário com informações
    TEMP_FILE=$(mktemp)
    cat << 'EOF' > "$TEMP_FILE"
════════════════════════════════════════════════════════════════
                        ZENITY INFORMATION
════════════════════════════════════════════════════════════════

O QUE É O ZENITY?
────────────────────────────────────────────────────────────────
O Zenity é uma ferramenta que permite criar interfaces gráficas
simples para scripts shell. Ele faz parte do projeto GNOME e
fornece uma maneira fácil de adicionar elementos visuais aos
seus scripts.

PRINCIPAIS CARACTERÍSTICAS:
────────────────────────────────────────────────────────────────
• ✅ Diálogos de informação, erro e aviso
• ✅ Formulários de entrada de dados
• ✅ Seletores de arquivos e pastas
• ✅ Barras de progresso animadas
• ✅ Listas de seleção múltipla
• ✅ Calendários interativos
• ✅ Notificações do sistema
• ✅ Visualização de texto
• ✅ E muito mais!

VANTAGENS DO ZENITY:
────────────────────────────────────────────────────────────────
1. 🎯 Simplicidade: Fácil de usar e integrar
2. 🚀 Rapidez: Interface rápida e responsiva
3. 🔧 Flexibilidade: Muitas opções de customização
4. 🌐 Compatibilidade: Funciona em vários ambientes Linux
5. 📱 Modernidade: Interface consistente com o desktop

EXEMPLOS DE USO:
────────────────────────────────────────────────────────────────
• Scripts de instalação interativos
• Formulários de configuração
• Interfaces para backup/restore
• Assistentes de configuração
• Ferramentas de administração
• Aplicações desktop simples

SINTAXE BÁSICA:
────────────────────────────────────────────────────────────────
zenity --info --text="Mensagem"
zenity --question --text="Pergunta?"
zenity --entry --text="Digite algo:"
zenity --file-selection --title="Selecione arquivo"

Para mais informações, consulte: man zenity

════════════════════════════════════════════════════════════════
                   Este é um exemplo do Zenity!
                    Script criado por Andre Berger
════════════════════════════════════════════════════════════════
EOF
    
    zenity --text-info \
        --title="Informações sobre o Zenity" \
        --filename="$TEMP_FILE" \
        --width=700 \
        --height=500 \
        --font="monospace 10"
    
    rm -f "$TEMP_FILE"
    
    print_message "$GREEN" "✓ Visualização de texto demonstrada!"
}

#=============================================================================
# MENU PRINCIPAL
#=============================================================================

main_menu() {
    while true; do
        show_header
        
        OPCAO=$(zenity --list \
            --title="Menu de Demonstrações do Zenity" \
            --text="Selecione qual demonstração você gostaria de ver:" \
            --column="ID" \
            --column="Demonstração" \
            --column="Descrição" \
            --width=600 \
            --height=400 \
            "1" "Diálogos Informativos" "Info, Aviso e Erro" \
            "2" "Diálogo de Pergunta" "Confirmações e decisões" \
            "3" "Entrada de Texto" "Campos de texto e senha" \
            "4" "Formulários" "Formulários complexos" \
            "5" "Seleção de Arquivos" "Arquivos e pastas" \
            "6" "Listas de Seleção" "Listas simples e múltiplas" \
            "7" "Barra de Progresso" "Indicadores de progresso" \
            "8" "Calendário" "Seletor de datas" \
            "9" "Notificações" "Alertas do sistema" \
            "10" "Visualização de Texto" "Exibição de arquivos" \
            "11" "Demonstração Completa" "Executar todas as demos" \
            "0" "Sair" "Encerrar demonstração")
        
        case $OPCAO in
            1) demo_info_dialogs ;;
            2) demo_question_dialog ;;
            3) demo_entry_dialog ;;
            4) demo_forms ;;
            5) demo_file_selection ;;
            6) demo_lists ;;
            7) demo_progress ;;
            8) demo_calendar ;;
            9) demo_notifications ;;
            10) demo_text_info ;;
            11)
                print_message "$CYAN" "🔄 Executando demonstração completa..."
                demo_info_dialogs
                demo_question_dialog
                demo_entry_dialog
                demo_forms
                demo_file_selection
                demo_lists
                demo_progress
                demo_calendar
                demo_notifications
                demo_text_info
                print_message "$GREEN" "✅ Demonstração completa finalizada!"
                ;;
            0)
                zenity --question \
                    --title="Confirmar Saída" \
                    --text="Tem certeza que deseja sair da demonstração?"
                if [ $? -eq 0 ]; then
                    zenity --info \
                        --title="Tchau!" \
                        --text="Obrigado por usar a demonstração do Zenity!\n\nEsperamos que tenha sido útil! 👋"
                    print_message "$GREEN" "👋 Demonstração finalizada pelo usuário"
                    exit 0
                fi
                ;;
            *)
                zenity --error \
                    --title="Erro" \
                    --text="Opção inválida ou operação cancelada."
                ;;
        esac
    done
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "Iniciando demonstração do Zenity..."
check_zenity
echo "Demonstração iniciada em: $(date)" >> "$LOG_FILE"

main_menu