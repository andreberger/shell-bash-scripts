#!/bin/bash

#=============================================================================
# Script de Configuração de Repositórios CentOS 7
#=============================================================================
# Descrição: Script para configuração completa de repositórios essenciais
#            no CentOS 7, incluindo EPEL, RPM Fusion, REMI, Adobe, Google
#            e outros repositórios importantes para um sistema completo.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: CentOS 7, RHEL 7
#
# ATENÇÃO: Este script requer privilégios de administrador (root)
#          e conectividade com a internet
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x repositorios-centos7.sh
# 2. Execute como root: sudo ./repositorios-centos7.sh
# 3. Acompanhe a instalação dos repositórios
# 4. Confirme as instalações quando solicitado
#
# REPOSITÓRIOS CONFIGURADOS:
#   • EPEL (Extra Packages for Enterprise Linux)
#   • REMI (PHP e ferramentas web)
#   • RPM Fusion (codecs multimídia)
#   • Google Chrome
#   • Adobe Flash Player
#   • ElRepo (drivers de hardware)
#   • IUS (versões atualizadas de pacotes)
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/var/log/repos-setup-$(date +%Y%m%d_%H%M%S).log"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para imprimir mensagens coloridas
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

# Função para imprimir cabeçalho de seção
print_section() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

# Função para verificar se o comando foi executado com sucesso
check_command() {
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✓ $1 executado com sucesso"
    else
        print_message "$RED" "✗ Erro ao executar: $1"
        exit 1
    fi
}

# Função para verificar se está executando como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_message "$RED" "Este script deve ser executado como root!"
        print_message "$YELLOW" "Use: sudo $0"
        exit 1
    fi
}

# Função para verificar se é CentOS 7
check_centos7() {
    if [ ! -f /etc/centos-release ]; then
        print_message "$RED" "Este script é específico para CentOS/RHEL!"
        exit 1
    fi
    
    local version=$(cat /etc/centos-release | grep -oP '(?<=release )\d+')
    if [ "$version" != "7" ]; then
        print_message "$YELLOW" "⚠ Aviso: Este script foi testado apenas no CentOS 7"
        print_message "$YELLOW" "Versão detectada: CentOS $version"
        read -p "Deseja continuar? (s/N): " continue_install
        case $continue_install in
            [sS]|[sS][iI][mM])
                print_message "$YELLOW" "Continuando configuração..."
                ;;
            *)
                print_message "$BLUE" "Configuração cancelada"
                exit 0
                ;;
        esac
    fi
}

# Função para fazer backup de arquivos de repositório
backup_repo_files() {
    print_message "$YELLOW" "📁 Fazendo backup dos arquivos de repositório..."
    
    local backup_dir="/etc/yum.repos.d/backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    if ls /etc/yum.repos.d/*.repo >/dev/null 2>&1; then
        cp /etc/yum.repos.d/*.repo "$backup_dir/"
        print_message "$GREEN" "✓ Backup salvo em: $backup_dir"
    fi
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "Iniciando configuração de repositórios CentOS 7..."
print_message "$YELLOW" "Log será salvo em: $LOG_FILE"

# Verificações iniciais
check_root
check_centos7

echo "Configuração de repositórios iniciada em: $(date)" >> "$LOG_FILE"

# Fazer backup
backup_repo_files

#=============================================================================
# 1. ATUALIZAÇÃO INICIAL DO SISTEMA
#=============================================================================

print_section "1. ATUALIZANDO SISTEMA BASE"

print_message "$YELLOW" "Limpando cache do YUM..."
yum clean all
check_command "Limpeza cache YUM"

print_message "$YELLOW" "Atualizando sistema..."
yum update -y
check_command "Atualização sistema"

#=============================================================================
# 2. INSTALAÇÃO DO REPOSITÓRIO EPEL
#=============================================================================

print_section "2. CONFIGURANDO REPOSITÓRIO EPEL"

print_message "$YELLOW" "Instalando EPEL Release..."
yum install -y epel-release
check_command "Instalação EPEL"

print_message "$YELLOW" "Configurando prioridades do EPEL..."
sed -i 's/enabled=1/enabled=1\npriority=10/' /etc/yum.repos.d/epel.repo
check_command "Configuração prioridades EPEL"

#=============================================================================
# 3. INSTALAÇÃO DO REPOSITÓRIO REMI
#=============================================================================

print_section "3. CONFIGURANDO REPOSITÓRIO REMI"

print_message "$YELLOW" "Instalando chaves GPG do REMI..."
rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi
check_command "Importação chaves REMI"

print_message "$YELLOW" "Instalando repositório REMI..."
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
check_command "Instalação repositório REMI"

print_message "$YELLOW" "Configurando prioridades do REMI..."
sed -i 's/enabled=1/enabled=1\npriority=15/' /etc/yum.repos.d/remi.repo
sed -i 's/enabled=0/enabled=0\npriority=15/' /etc/yum.repos.d/remi-*.repo
check_command "Configuração prioridades REMI"

#=============================================================================
# 4. INSTALAÇÃO DO RPM FUSION
#=============================================================================

print_section "4. CONFIGURANDO RPM FUSION"

print_message "$YELLOW" "Instalando RPM Fusion Free..."
yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
check_command "Instalação RPM Fusion Free"

print_message "$YELLOW" "Instalando RPM Fusion Non-Free..."
yum install -y https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
check_command "Instalação RPM Fusion Non-Free"

print_message "$YELLOW" "Configurando prioridades RPM Fusion..."
if [ -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
    sed -i 's/enabled=1/enabled=1\npriority=20/' /etc/yum.repos.d/rpmfusion-free.repo
fi
if [ -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]; then
    sed -i 's/enabled=1/enabled=1\npriority=20/' /etc/yum.repos.d/rpmfusion-nonfree.repo
fi
check_command "Configuração prioridades RPM Fusion"

#=============================================================================
# 5. REPOSITÓRIO GOOGLE CHROME
#=============================================================================

print_section "5. CONFIGURANDO REPOSITÓRIO GOOGLE CHROME"

print_message "$YELLOW" "Adicionando repositório Google Chrome..."
cat > /etc/yum.repos.d/google-chrome.repo << 'EOF'
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
priority=25
EOF

print_message "$YELLOW" "Importando chave GPG do Google..."
rpm --import https://dl.google.com/linux/linux_signing_key.pub
check_command "Configuração repositório Google Chrome"

#=============================================================================
# 6. REPOSITÓRIO ELREPO
#=============================================================================

print_section "6. CONFIGURANDO REPOSITÓRIO ELREPO"

print_message "$YELLOW" "Importando chave GPG do ELRepo..."
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
check_command "Importação chave ELRepo"

print_message "$YELLOW" "Instalando repositório ELRepo..."
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
check_command "Instalação ELRepo"

print_message "$YELLOW" "Configurando prioridades ELRepo..."
if [ -f /etc/yum.repos.d/elrepo.repo ]; then
    sed -i 's/enabled=1/enabled=1\npriority=30/' /etc/yum.repos.d/elrepo.repo
fi
check_command "Configuração prioridades ELRepo"

#=============================================================================
# 7. REPOSITÓRIO IUS
#=============================================================================

print_section "7. CONFIGURANDO REPOSITÓRIO IUS"

print_message "$YELLOW" "Instalando repositório IUS..."
yum install -y https://repo.ius.io/ius-release-el7.rpm
check_command "Instalação repositório IUS"

print_message "$YELLOW" "Configurando prioridades IUS..."
if [ -f /etc/yum.repos.d/ius.repo ]; then
    sed -i 's/enabled=1/enabled=1\npriority=35/' /etc/yum.repos.d/ius.repo
fi
check_command "Configuração prioridades IUS"

#=============================================================================
# 8. REPOSITÓRIO ADOBE (FLASH PLAYER)
#=============================================================================

print_section "8. CONFIGURANDO REPOSITÓRIO ADOBE"

print_message "$YELLOW" "Adicionando repositório Adobe..."
cat > /etc/yum.repos.d/adobe-linux-x86_64.repo << 'EOF'
[adobe-linux-x86_64]
name=Adobe Systems Incorporated
baseurl=http://linuxdownload.adobe.com/linux/x86_64/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
priority=40
EOF

print_message "$YELLOW" "Importando chave GPG da Adobe..."
rpm --import http://linuxdownload.adobe.com/linux/x86_64/RPM-GPG-KEY-adobe-linux
check_command "Configuração repositório Adobe"

#=============================================================================
# 9. INSTALAÇÃO DE UTILITÁRIOS DE REPOSITÓRIO
#=============================================================================

print_section "9. INSTALANDO UTILITÁRIOS"

print_message "$YELLOW" "Instalando yum-utils e yum-plugin-priorities..."
yum install -y yum-utils yum-plugin-priorities
check_command "Instalação utilitários YUM"

print_message "$YELLOW" "Instalando yum-plugin-fastestmirror..."
yum install -y yum-plugin-fastestmirror
check_command "Instalação plugin fastest mirror"

#=============================================================================
# 10. ATUALIZAÇÃO FINAL E VALIDAÇÃO
#=============================================================================

print_section "10. VALIDAÇÃO FINAL"

print_message "$YELLOW" "Limpando cache após configurações..."
yum clean all
yum makecache
check_command "Reconstrução cache YUM"

print_message "$YELLOW" "Testando repositórios configurados..."
yum repolist enabled | tee -a "$LOG_FILE"
check_command "Listagem repositórios ativos"

#=============================================================================
# RESUMO E FINALIZAÇÃO
#=============================================================================

print_section "CONFIGURAÇÃO CONCLUÍDA"

print_message "$GREEN" "✓ Repositórios configurados com sucesso!"

echo -e "${YELLOW}📋 RESUMO DOS REPOSITÓRIOS INSTALADOS:${NC}"
echo -e "   • ${GREEN}EPEL${NC} - Extra Packages for Enterprise Linux"
echo -e "   • ${GREEN}REMI${NC} - PHP e ferramentas web atualizadas"
echo -e "   • ${GREEN}RPM Fusion${NC} - Codecs multimídia e drivers"
echo -e "   • ${GREEN}Google Chrome${NC} - Navegador web"
echo -e "   • ${GREEN}ELRepo${NC} - Drivers de hardware"
echo -e "   • ${GREEN}IUS${NC} - Versões atualizadas de pacotes"
echo -e "   • ${GREEN}Adobe${NC} - Flash Player e plugins"

echo -e "\n${BLUE}🔧 COMANDOS ÚTEIS:${NC}"
echo -e "   • Listar repositórios: ${CYAN}yum repolist${NC}"
echo -e "   • Buscar pacotes: ${CYAN}yum search <pacote>${NC}"
echo -e "   • Instalar de repo específico: ${CYAN}yum --enablerepo=<repo> install <pacote>${NC}"
echo -e "   • Atualizar sistema: ${CYAN}yum update${NC}"

echo -e "\n${CYAN}📦 EXEMPLOS DE INSTALAÇÃO:${NC}"
echo -e "   • PHP 7.4: ${YELLOW}yum --enablerepo=remi-php74 install php php-mysql${NC}"
echo -e "   • Google Chrome: ${YELLOW}yum install google-chrome-stable${NC}"
echo -e "   • Codecs de vídeo: ${YELLOW}yum install ffmpeg gstreamer1-plugins-bad-free${NC}"
echo -e "   • Git atualizado: ${YELLOW}yum install git2u${NC}"

echo -e "\n${YELLOW}📄 ARQUIVOS DE LOG:${NC}"
echo -e "   • Log da configuração: ${CYAN}$LOG_FILE${NC}"
echo -e "   • Backup dos repos: ${CYAN}/etc/yum.repos.d/backup-*${NC}"

print_message "$GREEN" "🎉 Sistema pronto para instalação de pacotes adicionais!"

echo "Configuração de repositórios concluída em: $(date)" >> "$LOG_FILE"

# Opcional: sugerir instalação de pacotes essenciais
echo -e "\n${BLUE}💡 DICA:${NC} Execute o seguinte comando para instalar pacotes essenciais:"
echo -e "${CYAN}yum groupinstall 'Development Tools' && yum install vim htop wget curl git${NC}"