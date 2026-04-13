# Sistema de Progresso Aplicado aos Scripts

## ✅ Scripts Totalmente Atualizados

### 1. **pos-instalacao-ubuntu-20.04.6.sh**
- ✅ Variáveis de progresso e tempo
- ✅ 18 etapas com update_progress()
- ✅ Dialog integrado  
- ✅ Porcentagens detalhadas
- ✅ Tempo total no final
- **Seções**: 15 principais + 3 auxiliares

### 2. **pos-instalacao-ubuntu-24.04.4.sh**
- ✅ Variáveis de progresso e tempo
- ✅ 18 etapas com update_progress()
- ✅ Dialog integrado
- ✅ Porcentagens detalhadas
- ✅ Tempo total no final
- **Seções**: 15 principais + 3 auxiliares

### 3. **pos-instalacao-fedora-43.sh**
- ✅ Variáveis de progresso (START_TIME, TOTAL_STEPS=13, CURRENT_STEP, USE_DIALOG)
- ✅ Funções completas (get_elapsed_time, update_progress, check_dialog)
- ⚠️ Parcialmente atualizado (seções 1-2 com update_progress)
- **Pendente**: Adicionar update_progress nas seções 3-13

## 📋 Scripts Pendentes de Atualização Completa

### 4. **pos-instalacao-fedora-44.sh**
- **Total de Seções**: 13
- **Estrutura**: Idêntica ao Fedora 43
- **Pendente**: Copiar funções e adicionar update_progress em todas as seções

### 5. **pos-instalacao-fedora-43-mate.sh**
- **Total de Seções**: 13
- **Diferença**: Versão específica MATE (sem instalação do MATE, apenas Compiz opcional)
- **Pendente**: Copiar funções e adicionar update_progress em todas as seções

### 6. **pos-instalacao-fedora-44-mate.sh**
- **Total de Seções**: 13
- **Diferença**: Versão específica MATE (sem instalação do MATE, apenas Compiz opcional)
- **Pendente**: Copiar funções e adicionar update_progress em todas as seções

### 7. **pos-instalacao-opensuse-tumbleweed.sh**
- **Gerenciador de Pacotes**: zypper
- **Pendente**: Adaptar funções e adicionar update_progress

### 8. **pos-instalacao-opensuse-tumbleweed-mate.sh**
- **Gerenciador de Pacotes**: zypper
- **Diferença**: Versão MATE
- **Pendente**: Adaptar funções e adicionar update_progress

### Outros Scripts Encontrados:
9. **pos-instalacao-fedora-42.sh** (15 seções)
10. **pos-instalacao-linux-mint-22.sh**
11. **pos-instalacao-debian-13.sh**
12. **pos-instalacao-centos-stream-9.sh**

## 🔧 Template de Funções a Adicionar

```bash
# Cores para output (adicionar PURPLE, CYAN, WHITE se não existirem)
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

# Variáveis de progresso e tempo
START_TIME=$(date +%s)
TOTAL_STEPS=13  # Ajustar conforme número de seções
CURRENT_STEP=0
USE_DIALOG=false

# Função para calcular tempo decorrido
get_elapsed_time() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))
    local hours=$((elapsed / 3600))
    local minutes=$(((elapsed % 3600) / 60))
    local seconds=$((elapsed % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%02dh %02dm %02ds" $hours $minutes $seconds
    elif [[ $minutes -gt 0 ]]; then
        printf "%02dm %02ds" $minutes $seconds
    else
        printf "%02ds" $seconds
    fi
}

# Função para atualizar progresso global
update_progress() {
    local step_name="$1"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local elapsed=$(get_elapsed_time)
    
    echo
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}📊 Progresso: ${GREEN}${CURRENT_STEP}/${TOTAL_STEPS}${WHITE} (${CYAN}${percentage}%${WHITE})  ⏱️  Tempo: ${YELLOW}${elapsed}${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Função para verificar e instalar dialog
check_dialog() {
    if command -v dialog &> /dev/null; then
        USE_DIALOG=true
        print_message "✅ Dialog detectado - usando interface avançada"
    else
        print_warning "Instalando dialog para melhor experiência visual..."
        # Para Fedora/RHEL:
        dnf install -y dialog &> /dev/null || true
        # Para openSUSE:
        # zypper install -y dialog &> /dev/null || true
        # Para Debian/Ubuntu:
        # apt-get install -y dialog &> /dev/null || true
        if command -v dialog &> /dev/null; then
            USE_DIALOG=true
        fi
    fi
}
```

## 📝 Instruções para Aplicar Manualmente

### Para cada script Fedora (43, 44, 43-mate, 44-mate):

1. **Adicionar variáveis no cabeçalho** (após as cores):
```bash
# Variáveis de progresso e tempo
START_TIME=$(date +%s)
TOTAL_STEPS=13
CURRENT_STEP=0
USE_DIALOG=false
```

2. **Adicionar funções** (após print_section):
- get_elapsed_time()
- update_progress()
- check_dialog()

3. **Chamar check_dialog** logo após verificação de root:
```bash
# Instalar dialog para melhor interface
check_dialog
```

4. **Adicionar update_progress em cada seção**:
```bash
print_section "X. NOME DA SEÇÃO"
update_progress "Nome Descritivo"
```

5. **Adicionar tempo total no final**:
```bash
local total_time=$(get_elapsed_time)
echo -e "${CYAN}⏱️ Tempo total de instalação: ${YELLOW}${total_time}${NC}"
echo
```

### Para scripts openSUSE:

Mesmas instruções acima, mas trocar `dnf` por `zypper` na função check_dialog:
```bash
zypper install -y dialog &> /dev/null || true
```

## 🎯 Mapeamento de Seções

### Fedora 43/44 (13 seções):
1. Atualização do Sistema
2. Configuração de Idioma
3. MATE Desktop/Compiz
4. Repositórios
5. Codecs Multimídia
6. DVDs Criptografados
7. Ferramentas de Compressão
8. Java
9. Softwares Gerais
10. Ambiente de Desenvolvimento
11. Games
12. Servidor LAMP + MongoDB
13. Configurações Finais

### Fedora 43/44-MATE (13 seções):
1. Atualização do Sistema
2. Configuração de Idioma
3. Compiz (Opcional)
4. Repositórios
5. Codecs Multimídia
6. DVDs Criptografados
7. Ferramentas de Compressão
8. Java
9. Softwares Gerais
10. Ambiente de Desenvolvimento
11. Games
12. Servidor LAMP + MongoDB
13. Configurações Finais

## 🔄 Status de Implementação

| Script | Variáveis | Funções | update_progress | Tempo Total | Status |
|--------|-----------|---------|-----------------|-------------|--------|
| ubuntu-20.04.6 | ✅ | ✅ | ✅ (18/18) | ✅ | 100% |
| ubuntu-24.04.4 | ✅ | ✅ | ✅ (18/18) | ✅ | 100% |
| fedora-43 | ✅ | ✅ | ⚠️ (2/13) | ❌ | 30% |
| fedora-44 | ❌ | ❌ | ❌ (0/13) | ❌ | 0% |
| fedora-43-mate | ❌ | ❌ | ❌ (0/13) | ❌ | 0% |
| fedora-44-mate | ❌ | ❌ | ❌ (0/13) | ❌ | 0% |
| opensuse-tumbleweed | ❌ | ❌ | ❌ | ❌ | 0% |
| opensuse-tumbleweed-mate | ❌ | ❌ | ❌ | ❌ | 0% |

## 💡 Próximos Passos Recomendados

1. ✅ Concluir pos-instalacao-fedora-43.sh (adicionar update_progress nas seções 3-13)
2. ⏭️ Aplicar ao pos-instalacao-fedora-44.sh (copiar estrutura do 43)
3. ⏭️ Aplicar ao pos-instalacao-fedora-43-mate.sh
4. ⏭️ Aplicar ao pos-instalacao-fedora-44-mate.sh
5. ⏭️ Adaptar e aplicar ao pos-instalacao-opensuse-tumbleweed.sh
6. ⏭️ Adaptar e aplicar ao pos-instalacao-opensuse-tumbleweed-mate.sh
7. ⏭️ Considerar aplicar aos demais scripts (Fedora 42, Linux Mint, Debian, CentOS)

## 📊 Benefícios da Implementação

- ⏱️ **Tempo Real**: Usuário vê quanto tempo já passou
- 📈 **Progresso Visual**: Sabe exatamente em qual etapa está
- 🎯 **Estimativa**: Pode calcular quanto falta aproximadamente
- 🎨 **Interface Profissional**: Dialog quando disponível, terminal colorido caso contrário
- 📝 **Feedback Constante**: Nunca parece "travado"

## 🔗 Arquivos Relacionados

- [MELHORIAS-INTERFACE.md](./MELHORIAS-INTERFACE.md) - Documentação completa do sistema
- [pos-instalacao-ubuntu-20.04.6.sh](./pos-instalacao-ubuntu-20.04.6.sh) - Exemplo completo implementado
- [pos-instalacao-ubuntu-24.04.4.sh](./pos-instalacao-ubuntu-24.04.4.sh) - Exemplo completo implementado

---

**Última Atualização**: 13/04/2026  
**Autor**: Andre Berger
