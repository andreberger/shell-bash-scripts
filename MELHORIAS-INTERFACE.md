# Melhorias de Interface e Progresso

## 📅 Data: 13 de Abril de 2026

## 🎯 Objetivo
Adicionar sistema de porcentagem, tempo de execução e interface dialog para melhor feedback visual durante a instalação.

## ✨ Melhorias Implementadas

### 1. Sistema de Progresso Global
- **Contador de Passos**: Exibe progresso atual (X/18 passos)
- **Porcentagem**: Cálculo automático do percentual concluído
- **Tempo Decorrido**: Mostra tempo desde o início da execução
- **Formato**: `📊 Progresso: 5/18 (27%) ⏱️ Tempo: 03m 45s`

### 2. Integração com Dialog
- **Instalação Automática**: Dialog instalado no início do script
- **Interface Gráfica**: Gauge bars para processos longos
- **Fallback Inteligente**: Usa output colorido se dialog não disponível
- **Exemplo de uso**:
  ```bash
  (
    echo "30" ; echo "XXX" ; echo "Atualizando pacotes..." ; echo "XXX"
    apt-get update
    echo "100" ; echo "XXX" ; echo "Concluído!" ; echo "XXX"
  ) | dialog --gauge "Progresso" 7 70 0
  ```

### 3. Indicadores de Progresso por Seção

#### Seção 1: Atualização do Sistema
- **Com Dialog**:
  - 10% - Removendo locks
  - 30% - Atualizando lista de pacotes
  - 50% - upgrade
  - 80% - dist-upgrade
  - 100% - Concluído
  
- **Sem Dialog**:
  - Mostra porcentagem em cada etapa: `[30%]`, `[50%]`, `[80%]`, `[100%]`

#### Seção 2: Idioma Português BR
- 25% - Pacotes de idioma
- 50% - Pacotes base
- 75% - Dicionários
- 100% - Configuração locale

#### Seção 10: Google Chrome
- 0% - Iniciando download
- Barra de progresso durante wget (--show-progress)
- 100% - Instalação

### 4. Funções Adicionadas

#### `get_elapsed_time()`
Calcula tempo decorrido desde o início
```bash
# Formato de saída:
# Menos de 1 minuto: "45s"
# Menos de 1 hora: "15m 30s"
# Mais de 1 hora: "02h 15m 30s"
```

#### `update_progress()`
Atualiza contador global e exibe progresso
```bash
update_progress "Nome da Tarefa"
# Saída:
# ═══════════════════════════════════════════
# 📊 Progresso: 5/18 (27%)  ⏱️ Tempo: 03m 45s
# ═══════════════════════════════════════════
```

#### `check_dialog()`
Verifica/instala dialog para interface avançada
```bash
# Detecta se dialog está instalado
# Se não, instala automaticamente
# Define USE_DIALOG=true se disponível
```

#### `show_dialog_progress()`
Formata output para dialog gauge
```bash
# Formato XXX para dialog:
# XXX
# 50
# Mensagem de progresso
# XXX
```

#### `show_install_progress()`
Animação spinner para instalações
```bash
# Exibe spinner rotativo: ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
# [⠋] Instalando pacote...
# [✓] Instalando pacote... Concluído!
```

### 5. Variáveis de Controle

```bash
START_TIME=$(date +%s)      # Timestamp do início
TOTAL_STEPS=18              # Total de etapas principais
CURRENT_STEP=0              # Etapa atual
USE_DIALOG=false            # Se dialog está disponível
```

### 6. Proteções Contra Travamento

Mantidas todas as proteções anteriores:
- `DEBIAN_FRONTEND=noninteractive`
- `NEEDRESTART_MODE=a`
- `NEEDRESTART_SUSPEND=1`
- Remoção de locks antes de apt update
- `< /dev/null` em todos os comandos apt
- Dpkg::Options para evitar prompts

## 📊 Exemplo de Execução

### Início do Script
```
╔════════════════════════════════════════════════════╗
║  🐧 PÓS-INSTALAÇÃO UBUNTU 20.04.6 LTS             ║
║                                                    ║
║     Configuração Completa e Automatizada          ║
║              Versão 1.0 - 2026                    ║
╚════════════════════════════════════════════════════╝

✅ Dialog detectado - usando interface avançada
✅ Ubuntu 20.04 detectado
✅ Conexão com internet OK
```

### Durante Execução
```
═══════════════════════════════════════════════════════
  📦 SEÇÃO 1/15: ATUALIZANDO O SISTEMA
═══════════════════════════════════════════════════════

═══════════════════════════════════════════════════════
📊 Progresso: 1/18 (5%)  ⏱️ Tempo: 00m 15s
═══════════════════════════════════════════════════════

┌─────────────── Atualizando Sistema ───────────────┐
│ ██████████████████████░░░░░░░░░░░░  50%          │
│ ⬆️ Instalando atualizações (upgrade)...          │
└───────────────────────────────────────────────────┘
```

### Instalação de Aplicativo
```
═══════════════════════════════════════════════════════
  🌐 SEÇÃO 10/15: INSTALANDO GOOGLE CHROME
═══════════════════════════════════════════════════════

═══════════════════════════════════════════════════════
📊 Progresso: 10/18 (55%)  ⏱️ Tempo: 12m 30s
═══════════════════════════════════════════════════════

📥 Baixando... 45%
📦 Instalando Google Chrome... [100%]
✅ Google Chrome instalado!
```

### Final
```
═══════════════════════════════════════════════════════
  🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!
═══════════════════════════════════════════════════════

═══════════════════════════════════════════════════════
📊 Progresso: 18/18 (100%)  ⏱️ Tempo: 23m 47s
═══════════════════════════════════════════════════════

⏱️ Tempo total de instalação: 23m 47s

✓ Sistema totalmente atualizado
✓ Idioma configurado para Português BR
...
```

## 🎨 Elementos Visuais

### Cores
- 🔵 **CYAN**: Barras de progresso e informações técnicas
- 🟢 **GREEN**: Sucesso e conclusões
- 🟡 **YELLOW**: Avisos e tempo decorrido
- 🔴 **RED**: Erros críticos
- 🟣 **PURPLE**: Separadores e títulos de seção
- ⚪ **WHITE**: Texto principal

### Símbolos Unicode
- ⏱️ Tempo
- 📊 Progresso
- ✅ Sucesso
- ❌ Erro
- ⚠️ Aviso
- 🔄 Processando
- ⬆️ Update
- 📥 Download
- 📦 Instalação
- 🧹 Limpeza

### Barras de Progresso
- Completo: █ (U+2588)
- Incompleto: ░ (U+2591)
- Exemplo: `[████████████░░░░░░] 60%`

### Spinner de Loading
- Caracteres Braille: ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
- Rotação suave durante processos

## 📋 Arquivos Modificados

1. **pos-instalacao-ubuntu-20.04.6.sh**
   - Adicionadas variáveis de progresso
   - 6 novas funções de interface
   - update_progress() em todas as 18 seções
   - Dialog integrado na seção de atualização
   - Tempo total no resumo final

2. **pos-instalacao-ubuntu-24.04.4.sh**
   - Mesmas modificações da versão 20.04.6
   - Adaptado para 3 comandos de upgrade (upgrade, dist-upgrade, full-upgrade)

## 🔧 Uso

### Para Desenvolvedores

#### Adicionar nova seção com progresso:
```bash
minha_funcao() {
    print_section "🎯 SEÇÃO X/15: TÍTULO DA SEÇÃO"
    update_progress "Nome da Tarefa"
    
    # Com dialog
    if [[ "$USE_DIALOG" == "true" ]]; then
        (
            echo "0" ; echo "XXX" ; echo "Iniciando..." ; echo "XXX"
            comando1
            echo "50" ; echo "XXX" ; echo "Meio do caminho..." ; echo "XXX"
            comando2
            echo "100" ; echo "XXX" ; echo "Concluído!" ; echo "XXX"
        ) | dialog --gauge "Título" 7 70 0
    else
        print_message "$BLUE" "Passo 1... [0%]"
        comando1
        print_message "$BLUE" "Passo 2... [50%]"
        comando2
        print_message "$BLUE" "Finalizado... [100%]"
    fi
    
    print_message "$GREEN" "✅ Tarefa concluída!"
}
```

#### Download com progresso:
```bash
wget --show-progress https://exemplo.com/arquivo.deb 2>&1 | 
    while IFS= read -r line; do
        if [[ $line =~ ([0-9]+)% ]]; then
            printf "\r📥 Baixando... ${BASH_REMATCH[1]}%%"
        fi
    done
```

## ✅ Testes Recomendados

1. **Testar com Dialog**:
   ```bash
   sudo apt install dialog
   sudo ./pos-instalacao-ubuntu-20.04.6.sh
   ```

2. **Testar sem Dialog**:
   ```bash
   sudo apt remove dialog
   sudo ./pos-instalacao-ubuntu-20.04.6.sh
   ```

3. **Verificar tempo**:
   - Executar script completo
   - Verificar se tempo é exibido corretamente
   - Confirmar formato (hh:mm:ss)

4. **Testar interrupção**:
   - Pressionar Ctrl+C durante execução
   - Verificar se cleanup é executado
   - Confirmar que arquivos temporários são removidos

## 🚀 Próximas Melhorias Sugeridas

- [ ] Barra de progresso global no topo do terminal
- [ ] Notificações desktop ao concluir seções
- [ ] Log colorido em tempo real
- [ ] Estimativa de tempo restante (ETA)
- [ ] Modo verboso/silencioso selecionável
- [ ] Salvamento de checkpoint para retomar instalação

## 📝 Notas Importantes

1. **Dialog é opcional**: Script funciona perfeitamente sem dialog
2. **Performance**: Adição de progresso não afeta velocidade de instalação
3. **Compatibilidade**: Testado em Ubuntu 20.04.6 e 24.04.4
4. **Logs**: Todos os logs continuam sendo salvos em `/tmp/pos-instalacao-ubuntu-*.log`

## 🆘 Troubleshooting

### Dialog não aparece
- Verificar se dialog foi instalado: `dpkg -l | grep dialog`
- Verificar permissões: script deve rodar como root
- Testar manualmente: `dialog --msgbox "Teste" 7 40`

### Progresso travado
- Verificar log: `tail -f /tmp/pos-instalacao-ubuntu-*.log`
- Processos apt podem demorar em conexões lentas
- Dialog aguarda conclusão do comando antes de atualizar

### Tempo incorreto
- Verificar se START_TIME está sendo definido
- Confirmar que função get_elapsed_time() está presente
- Verificar se comando `date` funciona

## 📄 Licença
MIT - Mesma licença dos scripts principais

---

**Autor**: Andre Berger  
**Data**: 13 de Abril de 2026  
**Versão**: 1.0
