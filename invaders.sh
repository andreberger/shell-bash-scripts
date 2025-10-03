#!/bin/bash

#=============================================================================
# Jogo Space Invaders para Terminal
#=============================================================================
# Descrição: Implementação do clássico jogo Space Invaders para terminal,
#            com controles simples e mecânicas de tiro. Destrua todos os
#            invasores antes que cheguem até você!
#
# Autor: Andre Berger (baseado em Vidar 'koala_man' Holen)
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix (Bash)
#
# CONTROLES:
#   J : Mover nave para esquerda
#   L : Mover nave para direita  
#   K : Atirar
#   Q : Sair do jogo
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x invaders.sh
# 2. Execute o jogo: ./invaders.sh
# 3. Use J/L para mover e K para atirar
# 4. Destrua todos os invasores para vencer!
# 5. Pressione Q para sair
#
# OBJETIVO:
#   • Destrua todos os invasores (24 no total)
#   • Evite que os invasores cheguem até sua nave
#   • Sobreviva o máximo possível!
#=============================================================================

# Verificar se foi solicitada ajuda
if [[ $1 == "--help" || $1 == "-h" ]]; then
    cat << END
╔══════════════════════════════════════════════════════════════╗
║                        SPACE INVADERS                       ║
║                    Terminal Edition v2.0                    ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  🚀 CONTROLES:                                               ║
║     J - Mover nave para ESQUERDA                             ║
║     L - Mover nave para DIREITA                              ║
║     K - ATIRAR                                               ║
║     Q - SAIR do jogo                                         ║
║                                                              ║
║  🎯 OBJETIVO:                                                ║
║     • Destrua todos os 24 invasores                         ║
║     • Evite que cheguem até você                             ║
║     • Sobreviva o máximo possível                            ║
║                                                              ║
║  ⚡ DICAS:                                                   ║
║     • Os invasores se movem em formação                      ║
║     • Eles aceleram quando sobram poucos                     ║
║     • Mire bem - só pode ter um tiro por vez                ║
║                                                              ║
║  🎮 Para jogar: ./invaders.sh                               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Space Invaders Terminal Edition
Baseado na versão original de Vidar 'koala_man' Holen
Melhorado por Andre Berger

END
    exit 0
fi

# Esconder cursor
tput civis

# Configurar diretório temporário
cd /tmp

# Funções auxiliares
e=echo
c=clear
r=return
E="$e -ne "
A=$E\\033[

# Funções de posicionamento e cor
m() { $A$2\;$1\H; }
f() { $A\1\;3$2\m; }

# Configurar trap para saída
trap cleanup SIGINT

# Função de limpeza
cleanup() {
    tput cnorm  # Mostrar cursor novamente
    $c
    echo -e "\033[1;36m"
    echo "┌─────────────────────────────────────┐"
    echo "│           JOGO FINALIZADO           │"
    echo "│                                     │"
    echo "│      Obrigado por jogar!            │"
    echo "│   Space Invaders Terminal v2.0     │"
    echo "└─────────────────────────────────────┘"
    echo -e "\033[0m"
    
    # Remover arquivos temporários
    rm -f "$G" "$L" "$M" "$N" "$F" 2>/dev/null
    kill $B 2>/dev/null
    exit 0
}

# Funções do jogo
g() {
    $e ${K[$(($2*8+$1))]}
}

s() {
    K[$(($2*8+$1))]=$3
}

# Função de tiro
u() {
    [ $T = 0 ] && $r 0
    m $S $((--T))
    $E "$(f 3)."
    x=$((S-Y))
    y=$((T-Z))
    [ $((y%3)) = 0 -a $((x%6)) -lt 4 ] || $r 0
    : $((y/=3)) $((x/=6))
    [ "$(g $x $y)" = 1 -a $x -le $o -a $x -ge $n -a $y -le $q -a $y -ge 0 ] || $r 0
    
    # Verificar vitória
    if [ $Q = 1 ]; then
        tput cnorm
        $c
        echo -e "\033[1;32m"
        echo "██╗   ██╗██╗████████╗ ██████╗ ██████╗ ██╗ █████╗ ██╗"
        echo "██║   ██║██║╚══██╔══╝██╔═══██╗██╔══██╗██║██╔══██╗██║"
        echo "██║   ██║██║   ██║   ██║   ██║██████╔╝██║███████║██║"
        echo "╚██╗ ██╔╝██║   ██║   ██║   ██║██╔══██╗██║██╔══██║╚═╝"
        echo " ╚████╔╝ ██║   ██║   ╚██████╔╝██║  ██║██║██║  ██║██╗"
        echo "  ╚═══╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝"
        echo -e "\033[0m"
        echo
        echo -e "\033[1;36mParabéns! Você destruiu todos os invasores!\\033[0m"
        echo -e "\033[1;33mPontuação: $((24 - Q)) invasores destruídos\\033[0m"
        cleanup
    fi
    
    s $x $y 0 
    : $((Q--))
    T=0
    $r 1
}

# Movimento dos invasores
a() {
    w n +
    w o - 
    h 
}

w() {
    D=0
    for (( I=0; I<=q; I++ )); do
        [ "$(g $(($1)) $I)" = 1 ] && D=1
    done
    [ $D = 0 ] && : $(($1$2=1)) 
}

h() {
    for (( I=q; I>=0; I--)); do
        for (( J=n; J<=o; J++)); do
            [ "$(g $J $I)" = 1 ] && q=$I && $r
        done
    done
}

# Função para capturar teclas
j() { 
    while read -n 1 S >/dev/null 2>&1; do
        $e $S > $M
    done
}

# Mostrar tela inicial
show_intro() {
    $c
    echo -e "\033[1;36m"
    echo "███████╗██████╗  █████╗  ██████╗███████╗"
    echo "██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo "███████╗██████╔╝███████║██║     █████╗  "
    echo "╚════██║██╔═══╝ ██╔══██║██║     ██╔══╝  "
    echo "███████║██║     ██║  ██║╚██████╗███████╗"
    echo "╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝"
    echo
    echo "██╗███╗   ██╗██╗   ██╗ █████╗ ██████╗ ███████╗██████╗ ███████╗"
    echo "██║████╗  ██║██║   ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝"
    echo "██║██╔██╗ ██║██║   ██║███████║██║  ██║█████╗  ██████╔╝███████╗"
    echo "██║██║╚██╗██║╚██╗ ██╔╝██╔══██║██║  ██║██╔══╝  ██╔══██╗╚════██║"
    echo "██║██║ ╚████║ ╚████╔╝ ██║  ██║██████╔╝███████╗██║  ██║███████║"
    echo "╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝"
    echo -e "\033[0m"
    echo
    echo -e "\033[1;33m                    Terminal Edition v2.0\\033[0m"
    echo
    echo -e "\033[1;32m🎮 CONTROLES:\\033[0m"
    echo -e "   \033[36mJ\033[0m - Mover para esquerda"
    echo -e "   \033[36mL\033[0m - Mover para direita"
    echo -e "   \033[36mK\033[0m - Atirar"
    echo -e "   \033[36mQ\033[0m - Sair"
    echo
    echo -e "\033[1;31m🎯 MISSÃO: Destrua todos os 24 invasores!\\033[0m"
    echo
    echo -e "\033[1;37mPressione qualquer tecla para começar...\\033[0m"
    read -n 1 -s
}

# Arquivos temporários
G=$(mktemp)
L=$(mktemp)
M=$(mktemp)
N=$(mktemp)

# Variáveis do jogo
X=40        # Posição da nave
n=0         # Limite esquerdo dos invasores
o=7         # Limite direito dos invasores
q=2         # Linha inferior dos invasores
T=0         # Posição do tiro (0 = sem tiro)
Y=2         # Posição horizontal dos invasores
Z=2         # Posição vertical dos invasores
U=2         # Direção do movimento dos invasores
W=0         # Contador de frames
Q=24        # Número de invasores restantes

# Inicializar invasores (8x3 = 24 invasores)
for (( i=0; i<24; i++ )); do 
    K[$i]=1
done

# Mostrar tela inicial
show_intro

# Iniciar captura de teclas em background
j 0<&0 &
B=$!

# Loop principal do jogo
until [ "$z" ]; do
    : $((W++)) 
    
    # Verificar entrada do usuário
    if [ -f $M ]; then
        i=$(<$M)
        rm -f $M
        case "$i" in
            q|Q) z="Quit" ;;
            j|J) X=$(($X-3)) ;;
            l|L) X=$(($X+3)) ;;
            k|K) [ $T = 0 ] && S=$((X+1)) && T=22 ;;
        esac
    fi
    
    # Limitar movimento da nave
    [ $X -lt 1 ] && X=1
    [ $X -gt 76 ] && X=76
    
    # Preparar frame
    rm -f $N  
    exec > $N
    
    # Desenhar invasores
    for (( J=0; J<=q; J++ )); do 
        for (( I=n; I<=o; I++ )); do 
            if [ "$(g $I $J)" = 1 ]; then
                m $((I*6+Y)) $((J*3+Z))
                $e "$(f 4)👾"
            fi
        done
    done
    
    # Desenhar nave
    m $X 23
    $e "$(f 2)🚀"
    
    # Processar tiro
    [ $T != 0 ] && u  
    
    # Mover invasores
    a
    
    # Mostrar frame
    m 0 0
    exec > $(tty)
    $c
    cat $N
    
    # Status do jogo
    echo -e "\033[1;33mInvasores restantes: $Q | Posição: $X | Controles: J/L mover, K atirar, Q sair\\033[0m"
    
    sleep .1
    
    # Movimento dos invasores
    if [ $((W%2)) = 0 ]; then
        : $((Y+=U))
        if [ $((Y+n*6)) -lt 2 -o $((Y+o*6)) -gt 75 ]; then
            : $((U=-U)) $((Z+=2))
            if [ $((Z+q*3)) -ge 20 ]; then
                tput cnorm
                $c
                echo -e "\033[1;31m"
                echo "██████╗ ███████╗██████╗ ██████╗  ██████╗ ████████╗ █████╗ ██╗"
                echo "██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔══██╗██║"
                echo "██║  ██║█████╗  ██████╔╝██████╔╝██║   ██║   ██║   ███████║██║"
                echo "██║  ██║██╔══╝  ██╔══██╗██╔══██╗██║   ██║   ██║   ██╔══██║╚═╝"
                echo "██████╔╝███████╗██║  ██║██║  ██║╚██████╔╝   ██║   ██║  ██║██╗"
                echo "╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝"
                echo -e "\033[0m"
                echo
                echo -e "\033[1;33mOs invasores chegaram até você!\\033[0m"
                echo -e "\033[1;36mInvasores destruídos: $((24 - Q))\\033[0m"
                cleanup
            fi
        fi
    fi
done

# Fim do jogo
cleanup