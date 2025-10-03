# 🐚 Shell Bash Scripts Collection

![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)
![Version](https://img.shields.io/badge/Version-2.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![OS](https://img.shields.io/badge/OS-Linux%20%7C%20Unix-lightgrey.svg)

Uma coleção completa e organizada de scripts shell úteis para administração de sistemas Linux/Unix, automatização de tarefas e ferramentas de produtividade.

## 📁 Estrutura do Repositório

```
shell-bash-scripts/
├── 🛠️  UTILITÁRIOS SISTEMA
│   ├── backup-diretorio.sh          # Backup automatizado de diretórios
│   ├── gerenciar-usuarios.sh        # Gerenciamento completo de usuários
│   ├── procurar-arquivo.sh          # Sistema avançado de busca de arquivos
│   ├── retorna-ip.sh               # Informações detalhadas de IP e rede
│   ├── verifica-usuario-logado.sh   # Monitoramento de usuários logados
│   └── tentativa-login.sh          # Análise de segurança e tentativas de login
│
├── 🌐 CONECTIVIDADE E REDE
│   ├── pingar.sh                   # Análise comparativa de conectividade
│   └── retorna-ip.sh              # Geolocalização e testes de rede
│
├── 🎮 JOGOS TERMINAL
│   ├── tetris.sh                   # Jogo Tetris completo para terminal
│   └── invaders.sh                 # Space Invaders para terminal
│
├── 🖥️  INTERFACE GRÁFICA
│   ├── forms.sh                    # Formulários interativos com validação
│   └── zenity-demo.sh             # Demonstração completa do Zenity
│
├── 🔧 INSTALAÇÃO E CONFIGURAÇÃO
│   ├── pos-instalacao-ubuntu.sh    # Pós-instalação Ubuntu 24.04.3 LTS
│   ├── pos-instalacao-fedora-42.sh # Pós-instalação Fedora 42
│   ├── lamp-centos7.sh             # Stack LAMP para CentOS 7
│   └── repositorios-centos7.sh     # Configuração de repositórios CentOS 7
│
└── 📊 AUTOMAÇÃO EMPRESARIAL
    └── TRABALHO-AUTOMACAO-V1.0SBE/
        ├── SISBKT2G2.sh            # Sistema principal de automação
        ├── bkp_mysql.sh            # Backup automatizado MySQL
        ├── functionBkpMySql.sh     # Funções de backup MySQL
        ├── functionMonitoramento.sh # Funções de monitoramento
        ├── functionUsers.sh        # Funções de gerenciamento de usuários
        ├── monitor_exec.sh         # Monitor de execução de processos
        └── telasSistema.sh         # Interface do sistema
```

## 🚀 Início Rápido

### Pré-requisitos
- Sistema Linux/Unix
- Bash 4.0 ou superior
- Privilégios sudo (para alguns scripts)

### Instalação
```bash
# Clonar o repositório
git clone https://github.com/andreberger/shell-bash-scripts.git

# Entrar no diretório
cd shell-bash-scripts

# Tornar todos os scripts executáveis
chmod +x *.sh

# Executar um script (exemplo)
./backup-diretorio.sh
```

## 📖 Guia de Scripts

### 🛠️ Utilitários do Sistema

#### backup-diretorio.sh
**Funcionalidades:**
- ✅ Backup compactado com data/usuário
- ✅ Verificação de integridade
- ✅ Cálculo de tamanho e taxa de compressão
- ✅ Interface colorida e logs detalhados

**Uso:**
```bash
./backup-diretorio.sh
# Siga as instruções na tela
```

#### gerenciar-usuarios.sh
**Funcionalidades:**
- ✅ Adicionar/remover usuários com validação
- ✅ Gerenciamento de grupos
- ✅ Verificação de usuários logados
- ✅ Estatísticas do sistema
- ✅ Interface de menu interativa

**Uso:**
```bash
sudo ./gerenciar-usuarios.sh
```

#### procurar-arquivo.sh
**Funcionalidades:**
- ✅ Busca por nome, extensão ou conteúdo
- ✅ Estatísticas de diretórios
- ✅ Interface de menu intuitiva
- ✅ Resultados formatados e detalhados

**Uso:**
```bash
./procurar-arquivo.sh
```

### 🌐 Rede e Conectividade

#### pingar.sh
**Funcionalidades:**
- ✅ Análise comparativa entre dois endereços
- ✅ Estatísticas detalhadas de RTT e perda
- ✅ Relatórios automáticos
- ✅ Validação de endereços

**Uso:**
```bash
./pingar.sh google.com cloudflare.com 10
./pingar.sh 8.8.8.8 1.1.1.1 5
```

#### retorna-ip.sh
**Funcionalidades:**
- ✅ IP público com geolocalização
- ✅ IPs locais de todas as interfaces
- ✅ Teste de conectividade
- ✅ Informações de provedor

**Uso:**
```bash
./retorna-ip.sh
```

### 🎮 Jogos para Terminal

#### tetris.sh
**Funcionalidades:**
- ✅ Jogo Tetris completo
- ✅ Sistema de pontuação e níveis
- ✅ Controles personalizáveis
- ✅ Interface gráfica ASCII

**Controles:**
- `↑/W`: Rotacionar
- `↓/S`: Acelerar
- `←/A`: Esquerda
- `→/D`: Direita
- `Espaço`: Derrubar
- `Q`: Sair

#### invaders.sh
**Funcionalidades:**
- ✅ Space Invaders para terminal
- ✅ 24 invasores para destruir
- ✅ Movimento e tiro realistas
- ✅ Tela de vitória/derrota

**Controles:**
- `J`: Esquerda
- `L`: Direita
- `K`: Atirar
- `Q`: Sair

### 🖥️ Interface Gráfica

#### zenity-demo.sh
**Funcionalidades:**
- ✅ Demonstração completa do Zenity
- ✅ 10+ tipos de diálogos diferentes
- ✅ Exemplos práticos e educativos
- ✅ Menu interativo de navegação

**Uso:**
```bash
# Instalar Zenity primeiro
sudo apt install zenity  # Ubuntu/Debian
sudo dnf install zenity  # Fedora

./zenity-demo.sh
```

### 🔧 Instalação e Configuração

#### pos-instalacao-ubuntu.sh
**Para:** Ubuntu 24.04.3 LTS
**Funcionalidades:**
- ✅ Configuração completa pós-instalação
- ✅ Flatpak, Snap e repositórios
- ✅ Aplicativos essenciais
- ✅ Otimização de energia (TLP)
- ✅ Codecs multimídia

#### pos-instalacao-fedora-42.sh
**Para:** Fedora 42
**Funcionalidades:**
- ✅ RPM Fusion e repositórios
- ✅ Codecs e aplicativos multimídia
- ✅ Ambiente Java completo
- ✅ VirtualBox e ferramentas de desenvolvimento

#### lamp-centos7.sh
**Para:** CentOS 7/RHEL 7
**Funcionalidades:**
- ✅ Stack LAMP completa
- ✅ Apache + MariaDB + PHP 7.3
- ✅ phpMyAdmin configurado
- ✅ Configurações de segurança

#### repositorios-centos7.sh
**Para:** CentOS 7/RHEL 7
**Funcionalidades:**
- ✅ EPEL, REMI, RPM Fusion
- ✅ Google Chrome, Adobe
- ✅ ELRepo, IUS
- ✅ Configuração de prioridades

## 🔐 Segurança e Monitoramento

### verifica-usuario-logado.sh
- Monitoramento em tempo real
- Histórico de logins
- Detecção de tentativas falhadas
- Estatísticas do sistema

### tentativa-login.sh
- Análise de logs de autenticação
- Detecção de ataques de força bruta
- Relatórios de IPs suspeitos
- Monitoramento de conexões SSH

## 💼 Sistema de Automação Empresarial

O diretório `TRABALHO-AUTOMACAO-V1.0SBE/` contém um sistema completo de automação empresarial com:

- **SISBKT2G2.sh**: Sistema principal de automação
- **Backup MySQL**: Scripts especializados para backup de bancos
- **Monitoramento**: Ferramentas de monitoramento de sistema
- **Interface de usuário**: Telas e menus para operação

## 🎨 Características dos Scripts

### ✨ Padronização
- **Cabeçalhos informativos** com instruções de uso
- **Tratamento de erros** robusto
- **Logging automático** de operações
- **Códigos de saída** apropriados

### 🎯 Interface de Usuário
- **Cores e formatação** consistentes
- **Menus interativos** intuitivos
- **Mensagens de feedback** claras
- **Barras de progresso** quando aplicável

### 🔒 Segurança
- **Validação de entrada** rigorosa
- **Verificação de privilégios** antes da execução
- **Confirmações** para operações críticas
- **Sanitização** de dados de entrada

### 📝 Documentação
- **Comentários detalhados** no código
- **Exemplos de uso** práticos
- **Troubleshooting** incluído
- **Dependências** claramente listadas

## 🔧 Dependências Comuns

### Pacotes Base
```bash
# Ubuntu/Debian
sudo apt install curl wget git vim htop bc

# CentOS/RHEL/Fedora
sudo yum install curl wget git vim htop bc
# ou
sudo dnf install curl wget git vim htop bc
```

### Interface Gráfica (Zenity)
```bash
# Ubuntu/Debian
sudo apt install zenity

# CentOS/RHEL
sudo yum install zenity

# Fedora
sudo dnf install zenity
```

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### 📋 Guidelines de Contribuição
- Mantenha o padrão de cabeçalhos dos scripts
- Adicione documentação adequada
- Teste em múltiplas distribuições quando possível
- Use cores e formatação consistentes
- Implemente tratamento de erros

## 📝 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Andre Berger**
- Email: [seu-email@exemplo.com]
- GitHub: [@andreberger](https://github.com/andreberger)

## 🙏 Agradecimentos

- Comunidade Bash/Shell scripting
- Mantenedores das distribuições Linux
- Desenvolvedores das ferramentas utilizadas
- Contribuidores e usuários dos scripts

## 📊 Status do Projeto

- ✅ **Scripts principais**: Todos funcionais e testados
- ✅ **Documentação**: Completa e atualizada
- ✅ **Compatibilidade**: Testado em Ubuntu, CentOS, Fedora
- 🔄 **Desenvolvimento ativo**: Melhorias contínuas

---

### 🔄 Última Atualização
Este README foi atualizado em **$(date '+%d/%m/%Y')**

### 📈 Estatísticas
- **20+ scripts** únicos
- **15+ funcionalidades** diferentes
- **3 distribuições** suportadas
- **2000+ linhas** de código

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!**