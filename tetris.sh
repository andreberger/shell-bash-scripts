#!/bin/bash

#=============================================================================
# Jogo Tetris para Terminal
#=============================================================================
# Descrição: Implementação completa do clássico jogo Tetris para terminal,
#            com controles por teclado, sistema de pontuação e níveis
#            progressivos de dificuldade.
#
# Autor: Andre Berger (baseado em xhchen)
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: Linux/Unix (Bash)
#
# CONTROLES:
#   ↑ ou W    : Rotacionar peça
#   ↓ ou S    : Acelerar queda
#   ← ou A    : Mover para esquerda
#   → ou D    : Mover para direita
#   Espaço    : Derrubar peça instantaneamente
#   Q ou ESC  : Sair do jogo
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x tetris.sh
# 2. Execute o jogo: ./tetris.sh
# 3. Use as teclas de controle para jogar
# 4. Pressione Q ou ESC para sair
#
# OBJETIVO:
#   • Complete linhas horizontais para ganhar pontos
#   • Evite que as peças cheguem ao topo
#   • Cada nível aumenta a velocidade
#=============================================================================

# Definições de cores
cRed=1 
cGreen=2 
cYellow=3 
cBlue=4 
cFuchsia=5 
cCyan=6 
cWhite=7 
colorTable=($cRed $cGreen $cYellow $cBlue $cFuchsia $cCyan $cWhite) 

# Tamanho e posição da área de jogo
iLeft=3 
iTop=2 
((iTrayLeft = iLeft + 2)) 
((iTrayTop = iTop + 1)) 
((iTrayWidth = 10)) 
((iTrayHeight = 15)) 

# Cores da interface
cBorder=$cGreen 
cScore=$cFuchsia 
cScoreValue=$cCyan 

# Sinais de controle
sigRotate=25 
sigLeft=26 
sigRight=27 
sigDown=28 
sigAllDown=29 
sigExit=30 

# Definição das peças (formas)
# Cada peça tem diferentes rotações possíveis
box0=(0 0 0 1 1 0 1 1)  # Quadrado
box1=(0 2 1 2 2 2 3 2 1 0 1 1 1 2 1 3)  # Linha
box2=(0 0 0 1 1 1 1 2 0 1 1 0 1 1 2 0)  # Z
box3=(0 1 0 2 1 0 1 1 0 0 1 0 1 1 2 1)  # S
box4=(0 1 0 2 1 1 2 1 1 0 1 1 1 2 2 2 0 1 1 1 2 0 2 1 0 0 1 0 1 1 1 2)  # T
box5=(0 1 1 1 2 1 2 2 1 0 1 1 1 2 2 0 0 0 0 1 1 1 2 1 0 2 1 0 1 1 1 2)  # L
box6=(0 1 1 1 1 2 2 1 1 0 1 1 1 2 2 1 0 1 1 0 1 1 2 1 0 1 1 0 1 1 1 2)  # J

box=(${box0[@]} ${box1[@]} ${box2[@]} ${box3[@]} ${box4[@]} ${box5[@]} ${box6[@]}) 
countBox=(1 2 2 2 4 4 4)  # Número de rotações para cada tipo
offsetBox=(0 1 3 5 7 11 15)  # Offset no array para cada tipo

# Configurações de pontuação
iScoreEachLevel=50

# Variáveis do jogo
sig=0 
iScore=0 
iLevel=0 
boxNew=()
cBoxNew=0
iBoxNewType=0
iBoxNewRotate=0
boxCur=()
cBoxCur=0
iBoxCurType=0
iBoxCurRotate=0
boxCurX=-1
boxCurY=-1
iMap=() 

# Inicializar mapa vazio
for ((i = 0; i < iTrayHeight * iTrayWidth; i++)); do 
    iMap[$i]=-1
done 

# Função principal para captura de teclas
RunAsKeyReceiver() { 
    local pidDisplayer key aKey sig cESC sTTY 
    pidDisplayer=$1 
    aKey=(0 0 0) 
    cESC=$(echo -ne "\033")
    cSpace=$(echo -ne "\040")
    sTTY=$(stty -g)
    
    trap "MyExit;" INT TERM 
    trap "MyExitNoSub;" $sigExit 
    
    echo -ne "\033[?25l"  # Esconder cursor
    
    print_controls() {
        local y
        ((y = iTop + iTrayHeight + 6))
        echo -e "\033[${y};0H\033[1m\033[36mCONTROLES:\033[0m"
        ((y++))
        echo -e "\033[${y};0H↑/W: Rotacionar  ↓/S: Acelerar  ←/A: Esquerda  →/D: Direita"
        ((y++))
        echo -e "\033[${y};0HEspaço: Derrubar  Q/ESC: Sair"
    }
    
    print_controls
    
    while : ; do 
        read -s -n 1 key 
        aKey[0]=${aKey[1]} 
        aKey[1]=${aKey[2]} 
        aKey[2]=$key 
        sig=0 
        
        if [[ $key == $cESC && ${aKey[1]} == $cESC ]]; then 
            MyExit 
        elif [[ ${aKey[0]} == $cESC && ${aKey[1]} == "[" ]]; then 
            if [[ $key == "A" ]]; then sig=$sigRotate 
            elif [[ $key == "B" ]]; then sig=$sigDown 
            elif [[ $key == "D" ]]; then sig=$sigLeft 
            elif [[ $key == "C" ]]; then sig=$sigRight 
            fi 
        elif [[ $key == "W" || $key == "w" ]]; then sig=$sigRotate 
        elif [[ $key == "S" || $key == "s" ]]; then sig=$sigDown 
        elif [[ $key == "A" || $key == "a" ]]; then sig=$sigLeft 
        elif [[ $key == "D" || $key == "d" ]]; then sig=$sigRight 
        elif [[ "[$key]" == "[]" ]]; then sig=$sigAllDown 
        elif [[ $key == "Q" || $key == "q" ]]; then 
            MyExit 
        fi 
        
        if [[ $sig != 0 ]]; then 
            kill -$sig $pidDisplayer 
        fi 
    done 
} 

MyExitNoSub() { 
    local y 
    stty $sTTY 
    ((y = iTop + iTrayHeight + 10)) 
    echo -e "\033[?25h\033[${y};0H\033[1m\033[32mObrigado por jogar!\033[0m" 
    exit 
} 

MyExit() { 
    kill -$sigExit $pidDisplayer 
    MyExitNoSub 
} 

# Função principal do display do jogo
RunAsDisplayer() { 
    local sigThis 
    InitDraw 
    
    trap "sig=$sigRotate;" $sigRotate 
    trap "sig=$sigLeft;" $sigLeft 
    trap "sig=$sigRight;" $sigRight 
    trap "sig=$sigDown;" $sigDown 
    trap "sig=$sigAllDown;" $sigAllDown 
    trap "ShowExit;" $sigExit 
    
    while : ; do 
        for ((i = 0; i < 21 - iLevel; i++)); do 
            usleep 20000 
            sigThis=$sig 
            sig=0 
            if ((sigThis == sigRotate)); then BoxRotate
            elif ((sigThis == sigLeft)); then BoxLeft
            elif ((sigThis == sigRight)); then BoxRight
            elif ((sigThis == sigDown)); then BoxDown
            elif ((sigThis == sigAllDown)); then BoxAllDown
            fi 
        done 
        BoxDown 
    done 
} 

# Verificar se movimento é válido
BoxMove() {
    local j i x y xTest yTest 
    yTest=$1 
    xTest=$2 
    
    for ((j = 0; j < 8; j += 2)); do 
        ((i = j + 1)) 
        ((y = ${boxCur[$j]} + yTest)) 
        ((x = ${boxCur[$i]} + xTest)) 
        if (( y < 0 || y >= iTrayHeight || x < 0 || x >= iTrayWidth)); then 
            return 1 
        fi 
        if ((${iMap[y * iTrayWidth + x]} != -1 )); then 
            return 1 
        fi 
    done 
    return 0
} 

# Adicionar peça ao mapa e verificar linhas completas
Box2Map() { 
    local j i x y xp yp line 
    
    # Adicionar peça ao mapa
    for ((j = 0; j < 8; j += 2)); do 
        ((i = j + 1)) 
        ((y = ${boxCur[$j]} + boxCurY)) 
        ((x = ${boxCur[$i]} + boxCurX)) 
        ((i = y * iTrayWidth + x)) 
        iMap[$i]=$cBoxCur 
    done 
    
    # Verificar linhas completas
    line=0 
    for ((j = 0; j < iTrayWidth * iTrayHeight; j += iTrayWidth)); do 
        for ((i = j + iTrayWidth - 1; i >= j; i--)); do 
            if ((${iMap[$i]} == -1)); then break; fi 
        done 
        if ((i >= j)); then continue; fi 
        
        ((line++))    
        # Mover linhas para baixo
        for ((i = j - 1; i >= 0; i--)); do 
            ((x = i + iTrayWidth)) 
            iMap[$x]=${iMap[$i]} 
        done 
        # Limpar linha superior
        for ((i = 0; i < iTrayWidth; i++)); do 
            iMap[$i]=-1 
        done 
    done 
    
    if ((line == 0)); then return; fi 
    
    # Atualizar pontuação
    ((x = iLeft + iTrayWidth * 2 + 7)) 
    ((y = iTop + 11)) 
    ((iScore += line * 2 - 1)) 
    echo -ne "\033[1m\033[3${cScoreValue}m\033[${y};${x}H${iScore}         " 
    
    # Verificar mudança de nível
    if ((iScore % iScoreEachLevel < line * 2 - 1)); then 
        if ((iLevel < 20)); then 
            ((iLevel++)) 
            ((y = iTop + 14)) 
            echo -ne "\033[3${cScoreValue}m\033[${y};${x}H${iLevel}        " 
        fi 
    fi 
    
    echo -ne "\033[0m" 
    
    # Redesenhar campo
    for ((y = 0; y < iTrayHeight; y++)); do 
        ((yp = y + iTrayTop + 1)) 
        ((xp = iTrayLeft + 1)) 
        ((i = y * iTrayWidth)) 
        echo -ne "\033[${yp};${xp}H" 
        for ((x = 0; x < iTrayWidth; x++)); do 
            ((j = i + x)) 
            if ((${iMap[$j]} == -1)); then 
                echo -ne "  " 
            else 
                echo -ne "\033[1m\033[7m\033[3${iMap[$j]}m\033[4${iMap[$j]}m\040\040\033[0m" 
            fi 
        done 
    done 
} 

# Funções de movimento das peças
BoxDown() { 
    local y s 
    ((y = boxCurY + 1)) 
    if BoxMove $y $boxCurX; then 
        s="$(DrawCurBox 0)" 
        ((boxCurY = y)) 
        s="$s$(DrawCurBox 1)" 
        echo -ne $s 
    else 
        Box2Map 
        RandomBox 
    fi 
} 

BoxLeft() { 
    local x s 
    ((x = boxCurX - 1)) 
    if BoxMove $boxCurY $x; then 
        s=$(DrawCurBox 0) 
        ((boxCurX = x)) 
        s=$s$(DrawCurBox 1) 
        echo -ne $s 
    fi 
} 

BoxRight() { 
    local x s 
    ((x = boxCurX + 1)) 
    if BoxMove $boxCurY $x; then 
        s=$(DrawCurBox 0) 
        ((boxCurX = x)) 
        s=$s$(DrawCurBox 1) 
        echo -ne $s 
    fi 
} 

BoxAllDown() { 
    local k j i x y iDown s 
    iDown=$iTrayHeight 
    
    for ((j = 0; j < 8; j += 2)); do 
        ((i = j + 1)) 
        ((y = ${boxCur[$j]} + boxCurY)) 
        ((x = ${boxCur[$i]} + boxCurX)) 
        for ((k = y + 1; k < iTrayHeight; k++)); do 
            ((i = k * iTrayWidth + x)) 
            if (( ${iMap[$i]} != -1)); then break; fi 
        done 
        ((k -= y + 1)) 
        if (( $iDown > $k )); then iDown=$k; fi 
    done 
    
    s=$(DrawCurBox 0) 
    ((boxCurY += iDown)) 
    s=$s$(DrawCurBox 1) 
    echo -ne $s 
    Box2Map 
    RandomBox 
} 

BoxRotate() { 
    local iCount iTestRotate boxTest j i s 
    iCount=${countBox[$iBoxCurType]} 
    ((iTestRotate = iBoxCurRotate + 1)) 
    if ((iTestRotate >= iCount)); then 
        ((iTestRotate = 0)) 
    fi 
    
    # Salvar estado atual
    for ((j = 0, i = (${offsetBox[$iBoxCurType]} + $iTestRotate) * 8; j < 8; j++, i++)); do 
        boxTest[$j]=${boxCur[$j]} 
        boxCur[$j]=${box[$i]} 
    done 
    
    if BoxMove $boxCurY $boxCurX; then 
        # Restaurar para limpar
        for ((j = 0; j < 8; j++)); do 
            boxCur[$j]=${boxTest[$j]} 
        done 
        s=$(DrawCurBox 0) 
        # Aplicar rotação
        for ((j = 0, i = (${offsetBox[$iBoxCurType]} + $iTestRotate) * 8; j < 8; j++, i++)); do 
            boxCur[$j]=${box[$i]} 
        done 
        s=$s$(DrawCurBox 1) 
        echo -ne $s 
        iBoxCurRotate=$iTestRotate 
    else 
        # Restaurar estado se rotação inválida
        for ((j = 0; j < 8; j++)); do 
            boxCur[$j]=${boxTest[$j]} 
        done 
    fi 
} 

# Desenhar peça atual
DrawCurBox() { 
    local i j t bDraw sBox s 
    bDraw=$1 
    s="" 
    
    if (( bDraw == 0 )); then 
        sBox="\040\040" 
    else 
        sBox="\040\040" 
        s=$s"\033[1m\033[7m\033[3${cBoxCur}m\033[4${cBoxCur}m"       
    fi 
    
    for ((j = 0; j < 8; j += 2)); do 
        ((i = iTrayTop + 1 + ${boxCur[$j]} + boxCurY)) 
        ((t = iTrayLeft + 1 + 2 * (boxCurX + ${boxCur[$j + 1]}))) 
        s=$s"\033[${i};${t}H${sBox}" 
    done 
    s=$s"\033[0m" 
    echo -n $s 
} 

# Gerar nova peça aleatória
RandomBox() { 
    local i j t 
    
    # Mover nova peça para atual
    iBoxCurType=${iBoxNewType} 
    iBoxCurRotate=${iBoxNewRotate} 
    cBoxCur=${cBoxNew} 
    for ((j = 0; j < ${#boxNew[@]}; j++)); do 
        boxCur[$j]=${boxNew[$j]} 
    done 
    
    if (( ${#boxCur[@]} == 8 )); then 
        # Calcular posição inicial
        for ((j = 0, t = 4; j < 8; j += 2)); do 
            if ((${boxCur[$j]} < t)); then t=${boxCur[$j]}; fi 
        done 
        ((boxCurY = -t)) 
        
        for ((j = 1, i = -4, t = 20; j < 8; j += 2)); do 
            if ((${boxCur[$j]} > i)); then i=${boxCur[$j]}; fi 
            if ((${boxCur[$j]} < t)); then t=${boxCur[$j]}; fi 
        done 
        ((boxCurX = (iTrayWidth - 1 - i - t) / 2)) 
        
        echo -ne $(DrawCurBox 1) 
        if ! BoxMove $boxCurY $boxCurX; then 
            kill -$sigExit ${PPID} 
            ShowExit 
        fi 
    fi 
    
    # Limpar área da próxima peça
    for ((j = 0; j < 4; j++)); do 
        ((i = iTop + 1 + j)) 
        ((t = iLeft + 2 * iTrayWidth + 7)) 
        echo -ne "\033[${i};${t}H        " 
    done 
    
    # Gerar nova peça
    ((iBoxNewType = RANDOM % ${#offsetBox[@]})) 
    ((iBoxNewRotate = RANDOM % ${countBox[$iBoxNewType]})) 
    for ((j = 0, i = (${offsetBox[$iBoxNewType]} + $iBoxNewRotate) * 8; j < 8; j++, i++)); do 
        boxNew[$j]=${box[$i]}
    done 
    ((cBoxNew = ${colorTable[RANDOM % ${#colorTable[@]}]})) 
    
    # Mostrar próxima peça
    echo -ne "\033[1m\033[7m\033[3${cBoxNew}m\033[4${cBoxNew}m" 
    for ((j = 0; j < 8; j += 2)); do 
        ((i = iTop + 1 + ${boxNew[$j]})) 
        ((t = iLeft + 2 * iTrayWidth + 7 + 2 * ${boxNew[$j + 1]})) 
        echo -ne "\033[${i};${t}H\040\040" 
    done 
    echo -ne "\033[0m" 
} 

# Inicializar display
InitDraw() { 
    clear 
    
    # Mostrar título
    echo -e "\033[1;34m"
    echo "    ████████ ███████ ████████ ██████  ██ ███████ "
    echo "       ██    ██         ██    ██   ██ ██ ██      "
    echo "       ██    █████      ██    ██████  ██ ███████ "
    echo "       ██    ██         ██    ██   ██ ██      ██ "
    echo "       ██    ███████    ██    ██   ██ ██ ███████ "
    echo -e "\033[0m"
    
    RandomBox 
    RandomBox 
    local i t1 t2 t3 
    
    # Desenhar borda
    echo -ne "\033[1m" 
    echo -ne "\033[3${cBorder}m\033[4${cBorder}m" 
    ((t2 = iLeft + 1)) 
    ((t3 = iLeft + iTrayWidth * 2 + 3)) 
    for ((i = 0; i < iTrayHeight; i++)); do 
        ((t1 = i + iTop + 2)) 
        echo -ne "\033[${t1};${t2}H\040\040" 
        echo -ne "\033[${t1};${t3}H\040\040" 
    done 
    
    ((t2 = iTop + iTrayHeight + 2)) 
    for ((i = 0; i < iTrayWidth + 2; i++)); do 
        ((t1 = i * 2 + iLeft + 1)) 
        echo -ne "\033[${iTrayTop};${t1}H\040\040" 
        echo -ne "\033[${t2};${t1}H\040\040" 
    done 
    echo -ne "\033[0m" 
    
    # Desenhar interface de pontuação
    echo -ne "\033[1m" 
    ((t1 = iLeft + iTrayWidth * 2 + 7)) 
    ((t2 = iTop + 6))
    echo -ne "\033[3${cScore}m\033[${t2};${t1}HPróxima:" 
    ((t2 = iTop + 10)) 
    echo -ne "\033[3${cScore}m\033[${t2};${t1}HScore:" 
    ((t2 = iTop + 11)) 
    echo -ne "\033[3${cScoreValue}m\033[${t2};${t1}H${iScore}" 
    ((t2 = iTop + 13)) 
    echo -ne "\033[3${cScore}m\033[${t2};${t1}HNível:" 
    ((t2 = iTop + 14)) 
    echo -ne "\033[3${cScoreValue}m\033[${t2};${t1}H${iLevel}" 
    echo -ne "\033[0m" 
} 

ShowExit() { 
    local y 
    ((y = iTrayHeight + iTrayTop + 3)) 
    echo -e "\033[${y};0H\033[1;31m"
    echo "  ██████   █████  ███    ███ ███████      ██████  ██    ██ ███████ ██████  "
    echo " ██       ██   ██ ████  ████ ██          ██    ██ ██    ██ ██      ██   ██ "
    echo " ██   ███ ███████ ██ ████ ██ █████       ██    ██ ██    ██ █████   ██████  "
    echo " ██    ██ ██   ██ ██  ██  ██ ██          ██    ██  ██  ██  ██      ██   ██ "
    echo "  ██████  ██   ██ ██      ██ ███████      ██████    ████   ███████ ██   ██ "
    echo -e "\033[0m"
    ((y += 6))
    echo -e "\033[${y};0H\033[1;36mPontuação Final: $iScore | Nível Alcançado: $iLevel\033[0m"
    exit 
} 

# Início do programa
if [[ $1 != "--go" ]]; then 
    $0 --go& 
    RunAsKeyReceiver $! 
    exit 
else 
    RunAsDisplayer 
    exit 
fi