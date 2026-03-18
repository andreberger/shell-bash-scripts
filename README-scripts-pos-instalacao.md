# Scripts de Pós-Instalação Linux

Este conjunto de scripts foi desenvolvido para automatizar a pós-instalação de diversas distribuições Linux, instalando todos os softwares, ferramentas de desenvolvimento, jogos e servidores necessários.

## 📋 Scripts Disponíveis

1. **pos-instalacao-fedora-43.sh** - Fedora 43
2. **pos-instalacao-opensuse-tumbleweed.sh** - openSUSE Tumbleweed
3. **pos-instalacao-debian-13.sh** - Debian 13 (Trixie)
4. **pos-instalacao-ubuntu-24-04-v2.sh** - Ubuntu 24.04 LTS (Noble Numbat)
5. **pos-instalacao-linux-mint-22.sh** - Linux Mint 22 (Wilma)
6. **pos-instalacao-centos-stream-9.sh** - CentOS Stream 9

## 🚀 Como Usar

### 1. Baixar o Script

Escolha o script correspondente à sua distribuição.

### 2. Dar Permissão de Execução

```bash
chmod +x pos-instalacao-[DISTRIBUICAO].sh
```

### 3. Executar como Root

```bash
sudo ./pos-instalacao-[DISTRIBUICAO].sh
```

## 📦 O que os Scripts Instalam

### ⚙️ Configurações do Sistema
- ✅ Atualizações completas do sistema
- ✅ Configuração de idioma para Português-BR (pt_BR.UTF-8)
- ✅ Teclado ABNT2 (layout brasileiro)

### 🖥️ Interface Gráfica
- ✅ MATE Desktop Environment
- ✅ Compiz (gerenciador de janelas com efeitos 3D)
- ✅ Emerald e temas

### 📚 Repositórios

**Fedora/CentOS:**
- RPM Fusion Free
- RPM Fusion Non-free
- RPM Fusion Tainted (Free e Non-free)
- Flathub (Flatpak)

**Debian/Ubuntu/Mint:**
- Repositórios contrib e non-free
- Universe e Multiverse (Ubuntu/Mint)
- Flathub (Flatpak)

**openSUSE:**
- Packman (multimídia)
- Flathub (Flatpak)

### 🎵 Multimídia
- ✅ Codecs de áudio e vídeo (FFmpeg, GStreamer, x264, x265, LAME)
- ✅ Suporte a DVDs criptografados (libdvdcss)
- ✅ VLC Media Player

### 🗜️ Compressão
- ✅ 7zip
- ✅ ZIP/UNZIP
- ✅ RAR/UNRAR

### ☕ Java
- ✅ OpenJDK 11, 17, 21 e versão mais recente
- ✅ JRE e JDK completos

### 🛠️ Softwares Gerais
- ✅ PuTTY
- ✅ Vim/GVim
- ✅ HTOP
- ✅ Glances
- ✅ Google Chrome
- ✅ TeamViewer
- ✅ AnyDesk
- ✅ Dropbox
- ✅ VirtualBox
- ✅ Spotify
- ✅ HandBrake
- ✅ GIMP
- ✅ Inkscape
- ✅ Fontes Microsoft (Times New Roman, Arial, etc.)
- ✅ Telegram Desktop
- ✅ Warehouse (gerenciador Flatpak)
- ✅ Suporte impressoras HP (HPLIP)

### 💻 Ambiente de Desenvolvimento

**IDEs e Editores:**
- ✅ Code::Blocks
- ✅ Visual Studio Code
- ✅ Eclipse IDE
- ✅ Apache NetBeans
- ✅ PyCharm Community Edition

**Linguagens e Ferramentas:**
- ✅ GCC/G++ (compiladores C/C++)
- ✅ Make, CMake
- ✅ Python 3 + pip
  - pyopengl
  - pyopengl-accelerate
- ✅ Git + Git GUI
- ✅ GitHub Desktop

**Ferramentas de Modelagem:**
- ✅ Umbrello (UML)
- ✅ DIA (diagramas)

**Banco de Dados:**
- ✅ MySQL Workbench

### 🎮 Games
- ✅ Flycast (Emulador SEGA Dreamcast)
- ✅ Snes9x (Emulador Super Nintendo)
- ✅ Extreme Tux Racer
- ✅ SuperTuxKart

### 🌐 Servidor (LAMP Stack + MongoDB)
- ✅ **Apache** (servidor web)
- ✅ **PHP** (última versão disponível)
  - Extensões: MySQL, GD, MBString, XML, cURL, JSON, ZIP
- ✅ **MariaDB/MySQL** (banco de dados)
- ✅ **phpMyAdmin** (interface web para MySQL)
- ✅ **MongoDB** (banco de dados NoSQL)

## 🔧 Pós-Execução

### Configurar MySQL/MariaDB

Após a instalação, execute:

```bash
sudo mysql_secure_installation
```

Siga as instruções para:
- Definir senha do root
- Remover usuários anônimos
- Desabilitar login root remoto
- Remover banco de dados de teste

### Acessar phpMyAdmin

Abra o navegador e acesse:
```
http://localhost/phpmyadmin
```

### Iniciar Compiz

Para ativar os efeitos do Compiz:
```bash
compiz --replace
```

### Configurar VirtualBox

Adicione seu usuário ao grupo vboxusers (já feito automaticamente):
```bash
sudo usermod -a -G vboxusers $USER
```

## ⚠️ Observações Importantes

1. **Conexão com Internet**: Os scripts requerem conexão estável com a internet para download dos pacotes.

2. **Tempo de Execução**: Dependendo da velocidade da internet e do hardware, a execução pode levar de 30 minutos a 2 horas.

3. **Espaço em Disco**: Certifique-se de ter pelo menos 10-15 GB de espaço livre.

4. **Reinicialização**: Após a conclusão, é **altamente recomendado** reiniciar o sistema para aplicar todas as mudanças.

5. **Firewall**: Os scripts configuram o firewall para permitir tráfego HTTP/HTTPS (portas 80 e 443).

6. **SELinux (CentOS/Fedora)**: Em sistemas com SELinux, algumas configurações adicionais podem ser necessárias para aplicações web.

## 🐛 Solução de Problemas

### Script não executa
```bash
# Verificar permissões
ls -l pos-instalacao-*.sh

# Dar permissão de execução
chmod +x pos-instalacao-*.sh
```

### Erro de pacote não encontrado
- Alguns pacotes podem não estar disponíveis em determinadas versões
- O script tentará instalar via Flatpak como alternativa
- Verifique os logs para ver quais pacotes falharam

### Problemas com repositórios
```bash
# Limpar cache e atualizar
sudo dnf clean all && sudo dnf update  # Fedora/CentOS
sudo apt clean && sudo apt update      # Debian/Ubuntu/Mint
sudo zypper clean && sudo zypper refresh  # openSUSE
```

## 📝 Personalização

Você pode editar os scripts para:
- Remover softwares que não deseja instalar
- Adicionar novos pacotes
- Modificar configurações

Basta editar o arquivo .sh com seu editor preferido:
```bash
vim pos-instalacao-[DISTRIBUICAO].sh
```

## 📄 Licença

Estes scripts são fornecidos "como estão", sem garantias. Use por sua conta e risco.

## 👤 Autor

**André Kroetz Berger**  
📧 E-mail: andre@andre.poa.br  
🌐 Site: [andre.poa.br](http://andre.poa.br)  
📅 Data: 18/03/2026

## 🤝 Contribuições

Sinta-se à vontade para modificar e melhorar estes scripts!

---

**Desenvolvido com ❤️ para a comunidade Linux**
