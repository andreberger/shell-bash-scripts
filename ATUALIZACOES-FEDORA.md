# 📋 Atualizações dos Scripts Fedora

## 🎯 Alterações Implementadas

### ✅ Script Fedora 43 Atualizado

**Arquivo:** `pos-instalacao-fedora-43.sh`

#### Novas Instalações:

1. **Stacer** - Otimizador e Monitor do Sistema
   ```bash
   flatpak install -y flathub com.oguzhaninan.Stacer
   ```
   - 🔧 Limpeza de sistema
   - 📊 Monitoramento de recursos
   - ⚡ Gerenciamento de processos e serviços
   - 🗑️ Desinstalação de pacotes

2. **GitHub Desktop** - Interface Gráfica para Git (Atualizado)
   
   **Método Primário: Via Repositório RPM (Nativo)**
   ```bash
   rpm --import https://rpm.packages.shiftkey.dev/gpg.key
   
   # Criar repositório
   [shiftkey-packages]
   name=GitHub Desktop
   baseurl=https://rpm.packages.shiftkey.dev/rpm/
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://rpm.packages.shiftkey.dev/gpg.key
   
   dnf install -y github-desktop
   ```
   
   **Método Alternativo: Via Flatpak**
   ```bash
   flatpak install -y flathub io.github.shiftey.Desktop
   ```
   
   ✨ **O script tenta primeiro via RPM e, se falhar, usa Flatpak automaticamente!**

#### Melhorias:

- ✅ URL do Flathub atualizada: `https://dl.flathub.org/repo/flathub.flatpakrepo`
- ✅ Instalação inteligente do GitHub Desktop com fallback
- ✅ Mensagens informativas sobre os novos aplicativos

---

### 🆕 Script Fedora 44 Criado

**Arquivo:** `pos-instalacao-fedora-44.sh`

- 📅 **Data:** 11/04/2026
- 🔄 **Baseado em:** Fedora 43 com todas as melhorias
- ✨ **Inclui:** Stacer + GitHub Desktop (ambos métodos)
- 🎯 **Status:** Pronto para uso quando o Fedora 44 for lançado

---

## 📦 Aplicativos Adicionados

### 1. Stacer

**O que é?**
- Ferramenta de otimização e monitoramento para Linux
- Interface gráfica moderna e intuitiva

**Funcionalidades:**
- 🗑️ Limpeza de cache do sistema
- 📊 Monitoramento de CPU, RAM, disco
- ⚡ Gerenciamento de processos em execução
- 🚀 Gerenciamento de aplicativos de inicialização
- 📦 Desinstalador de pacotes
- 🔍 Análise de espaço em disco
- 🌐 Monitoramento de rede

**Como usar:**
```bash
# Executar via menu de aplicativos ou:
flatpak run com.oguzhaninan.Stacer
```

---

### 2. GitHub Desktop

**O que é?**
- Interface gráfica oficial para Git e GitHub
- Simplifica o controle de versão

**Funcionalidades:**
- 📂 Clone de repositórios
- 🔄 Commit e push visual
- 🌿 Gerenciamento de branches
- 🔀 Pull requests integrados
- 📊 Histórico visual de commits
- ⚡ Sincronização com GitHub

**Métodos de Instalação:**

#### Método 1: RPM (Recomendado) ✅
```bash
sudo rpm --import https://rpm.packages.shiftkey.dev/gpg.key

sudo sh -c 'echo -e "[shiftkey-packages]\nname=GitHub Desktop\nbaseurl=https://rpm.packages.shiftkey.dev/rpm/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://rpm.packages.shiftkey.dev/gpg.key" > /etc/yum.repos.d/shiftkey-packages.repo'

sudo dnf install github-desktop
```

**Vantagens:**
- ✅ Instalação nativa
- ✅ Melhor integração com o sistema
- ✅ Atualizações automáticas via dnf

#### Método 2: Flatpak (Alternativo) 🔄
```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub io.github.shiftey.Desktop
```

**Vantagens:**
- ✅ Isolamento de aplicativo
- ✅ Funciona em qualquer distribuição
- ✅ Atualizações via Flatpak

**Como usar:**
```bash
# Via comando:
github-desktop

# Ou via menu de aplicativos
```

---

## 🚀 Como Executar os Scripts

### Fedora 43
```bash
# Tornar executável
chmod +x pos-instalacao-fedora-43.sh

# Executar com sudo
sudo ./pos-instalacao-fedora-43.sh
```

### Fedora 44
```bash
# Tornar executável
chmod +x pos-instalacao-fedora-44.sh

# Executar com sudo
sudo ./pos-instalacao-fedora-44.sh
```

---

## 📊 Comparativo de Métodos - GitHub Desktop

| Característica | RPM Nativo | Flatpak |
|---------------|------------|---------|
| **Instalação** | ✅ Via DNF | ✅ Via Flatpak |
| **Integração** | ✅✅ Completa | ✅ Boa |
| **Atualizações** | `dnf upgrade` | `flatpak update` |
| **Espaço** | ✅ Menor | ⚠️ Maior (runtime) |
| **Segurança** | ✅ Boa | ✅✅ Sandbox |
| **Compatibilidade** | Fedora específico | Todas as distros |

---

## 🎯 Resumo das Melhorias

### Scripts Atualizados:
- ✅ `pos-instalacao-fedora-43.sh` - Atualizado com Stacer e GitHub Desktop
- ✅ `pos-instalacao-fedora-44.sh` - Nova versão criada

### Novas Funcionalidades:
- 🔧 Stacer para otimização do sistema
- 🐙 GitHub Desktop com 2 métodos de instalação
- ⚡ Instalação inteligente com fallback automático
- 📱 URL do Flathub atualizada

### Aplicativos Instalados (Total):
- **Desenvolvimento:** 12 ferramentas
- **Produtividade:** 15+ aplicativos
- **Multimídia:** 8 programas
- **Jogos:** 4 emuladores/jogos
- **Servidor:** LAMP + MongoDB
- **Otimização:** Stacer ⭐ NOVO
- **Controle de Versão:** Git + GitHub Desktop ⭐ MELHORADO

---

## 💡 Dicas de Uso

### Stacer
```bash
# Abrir Stacer
flatpak run com.oguzhaninan.Stacer

# Funções principais:
# 1. Dashboard - Visão geral do sistema
# 2. System Cleaner - Limpar cache e arquivos temporários
# 3. Startup Apps - Gerenciar inicialização
# 4. Services - Controlar serviços do sistema
# 5. Processes - Gerenciar processos
# 6. Uninstaller - Remover aplicativos
```

### GitHub Desktop
```bash
# Abrir GitHub Desktop
github-desktop

# Ou se instalado via Flatpak:
flatpak run io.github.shiftey.Desktop

# Primeiro uso:
# 1. Fazer login com conta GitHub
# 2. Clonar repositórios ou criar novos
# 3. Fazer commits visuais
# 4. Criar e gerenciar branches
```

---

## 🆘 Solução de Problemas

### GitHub Desktop não instala via RPM
```bash
# O script automaticamente tentará via Flatpak
# Ou instale manualmente:
flatpak install flathub io.github.shiftey.Desktop
```

### Stacer não abre
```bash
# Verificar se está instalado:
flatpak list | grep Stacer

# Reinstalar se necessário:
flatpak uninstall com.oguzhaninan.Stacer
flatpak install flathub com.oguzhaninan.Stacer
```

### Atualizar aplicativos Flatpak
```bash
# Atualizar todos:
flatpak update

# Atualizar específico:
flatpak update com.oguzhaninan.Stacer
```

---

## 📚 Links Úteis

- **Stacer GitHub:** https://github.com/oguzhaninan/Stacer
- **GitHub Desktop (ShiftKey):** https://github.com/shiftkey/desktop
- **Flathub:** https://flathub.org/
- **RPM Fusion:** https://rpmfusion.org/

---

**🎉 Scripts atualizados e prontos para uso!**
