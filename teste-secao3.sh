#!/bin/bash

#=============================================================================
# Script de Teste - Seção 3 (Instalação com 1 Click)
# Use este script para testar se a correção funcionou
#=============================================================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Teste da Seção 3 - 1 Click Install${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Verificar se é root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Execute como root: sudo ./teste-secao3.sh${NC}"
   exit 1
fi

echo -e "${BLUE}🔍 Verificando pacotes disponíveis...${NC}"
echo

# Verificar apturl
if apt-cache show apturl &> /dev/null; then
    echo -e "${GREEN}✅ apturl está disponível${NC}"
else
    echo -e "${YELLOW}⚠️  apturl NÃO está disponível${NC}"
fi

# Verificar gnome-software-plugin-snap
if apt-cache show gnome-software-plugin-snap &> /dev/null; then
    echo -e "${GREEN}✅ gnome-software-plugin-snap está disponível${NC}"
else
    echo -e "${YELLOW}⚠️  gnome-software-plugin-snap NÃO está disponível${NC}"
fi

# Verificar sessioninstaller
if apt-cache show sessioninstaller &> /dev/null; then
    echo -e "${GREEN}✅ sessioninstaller está disponível${NC}"
else
    echo -e "${YELLOW}⚠️  sessioninstaller NÃO está disponível (normal no Ubuntu 24.04)${NC}"
fi

echo
echo -e "${BLUE}📦 Tentando instalar pacotes disponíveis...${NC}"
echo

# Instalar apturl
if apt-cache show apturl &> /dev/null; then
    echo -e "${BLUE}Instalando apturl...${NC}"
    if apt install -y apturl; then
        echo -e "${GREEN}✅ apturl instalado com sucesso${NC}"
    else
        echo -e "${RED}❌ Erro ao instalar apturl${NC}"
    fi
fi

echo
echo -e "${BLUE}✅ Teste concluído!${NC}"
echo -e "${BLUE}Se não houve erros críticos, o script principal deve funcionar.${NC}"
