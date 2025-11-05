# Script de Pós-Instalação Ubuntu 24.04 LTS

## 📋 Descrição

Este script automatiza a instalação e configuração completa de um sistema Ubuntu 24.04 LTS recém-instalado, incluindo:

### 🔧 Configurações do Sistema
- Atualização completa do sistema
- Configuração de swappiness (vm.swappiness=10)
- Instalação e configuração do TLP para economia de energia
- Configuração do GNOME Shell Extensions

### 📦 Repositórios e Gerenciadores
- Configuração do Flatpak e repositório Flathub
- Adição do repositório Microsoft para VS Code
- Repositórios para AnyDesk e TeamViewer

### 🛠️ Ferramentas de Desenvolvimento
- **Java**: OpenJDK 8, 11, 17, 21 (JRE e JDK)
- **Visual Studio Code**
- **Ambiente de desenvolvimento completo**

### 🎯 Aplicativos Instalados

#### Multimídia e Codecs
- Ubuntu Restricted Extras
- VLC Media Player
- SMPlayer
- Audacity
- OBS Studio
- OpenShot
- HandBrake

#### Produtividade
- GNOME Tweaks
- Synaptic Package Manager
- Thunderbird (com localização PT-BR)
- Google Chrome
- Telegram Desktop
- Spotify

#### Design e Criação
- GIMP
- Inkscape
- Blender

#### Virtualização
- Oracle VM VirtualBox
- Virtual Machine Manager (QEMU/KVM)

#### Armazenamento em Nuvem
- Dropbox
- MEGA Sync

#### Ferramentas de Sistema
- Vim
- Glances
- Htop
- qBittorrent

#### Acesso Remoto
- AnyDesk
- TeamViewer

## 🚀 Como Usar

### No Ubuntu 24.04 LTS:

1. **Baixar o script:**
   ```bash
   wget https://raw.githubusercontent.com/seu-usuario/shell-bash-scripts/master/pos-instalacao-ubuntu-24-04.sh
   ```

2. **Tornar executável:**
   ```bash
   chmod +x pos-instalacao-ubuntu-24-04.sh
   ```

3. **Executar o script:**
   ```bash
   ./pos-instalacao-ubuntu-24-04.sh
   ```

### ⚠️ Pré-requisitos

- Ubuntu 24.04 LTS recém-instalado
- Conexão com a internet
- Usuário com privilégios sudo

## 📝 Detalhes das Configurações

### Configuração de Swappiness
O script configura a swappiness para 10, otimizando o uso da memória RAM:
```bash
vm.swappiness=10
```

### TLP - Gerenciamento de Energia
Instala e configura o TLP para otimizar o consumo de energia, especialmente útil em laptops.

### Configuração VirtualBox
Adiciona o usuário atual ao grupo `vboxusers` para uso completo do VirtualBox.

### GNOME Shell Extensions
Configura o dash-to-dock para minimizar janelas ao clicar.

## 🔍 Logs e Monitoramento

O script fornece logs detalhados durante a execução:
- ✅ **Verde**: Operações concluídas com sucesso
- ❌ **Vermelho**: Erros
- ⚠️ **Amarelo**: Avisos
- ℹ️ **Azul**: Informações gerais

## 🔄 Pós-Execução

Após a execução do script:

1. **Reinicie o sistema** para aplicar todas as configurações
2. **Configure suas contas** nos aplicativos instalados (Dropbox, MEGA, etc.)
3. **Faça logout/login** para que o grupo VirtualBox seja aplicado

## 🛡️ Segurança

- O script faz backup do arquivo `/etc/sysctl.conf` antes de modificá-lo
- Todas as chaves GPG são verificadas antes da instalação
- Apenas repositórios oficiais são adicionados

## 📋 Lista Completa de Pacotes

### APT Packages:
```
apturl, apturl-common, gnome-software, gnome-tweaks, curl, tlp, tlp-rdw,
flatpak, gnome-software-plugin-flatpak, ubuntu-restricted-extras, libdvd-pkg,
vlc, smplayer, audacity, blender, gimp, handbrake, inkscape, obs-studio,
openshot-qt, thunderbird, thunderbird-l10n-pt-br, openjdk-8-jre, openjdk-11-jre,
openjdk-17-jre, openjdk-21-jre, default-jre, openjdk-8-jdk, openjdk-11-jdk,
openjdk-17-jdk, openjdk-21-jdk, default-jdk, code, virtualbox, virt-manager,
python3-gpg, qbittorrent, vim, glances, htop, synaptic, anydesk, teamviewer
```

### Snap Packages:
```
spotify, telegram-desktop
```

### Flatpak:
```
Repositório Flathub configurado
```

### Downloads Diretos:
```
Google Chrome, Dropbox, MEGA Sync
```

## 📞 Suporte

Se encontrar algum problema durante a execução do script:

1. Verifique a conexão com a internet
2. Certifique-se de ter privilégios sudo
3. Execute o script em uma instalação limpa do Ubuntu 24.04 LTS
4. Verifique os logs de erro para identificar o problema específico

## 📄 Licença

Este script é fornecido "como está" para fins educacionais e de automação. Use por sua própria conta e risco.

---

**Última atualização:** Novembro 2025  
**Compatibilidade:** Ubuntu 24.04 LTS  
**Versão do Script:** 1.0