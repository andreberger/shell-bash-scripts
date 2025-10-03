#!/bin/bash

#=============================================================================
# Script de Instalação LAMP para CentOS 7
#=============================================================================
# Descrição: Script automatizado para instalação e configuração completa
#            da stack LAMP (Linux, Apache, MySQL/MariaDB, PHP) em sistemas
#            CentOS 7, incluindo configurações de segurança e otimizações.
#
# Autor: Andre Berger
# Data: $(date +%d/%m/%Y)
# Versão: 2.0
# Compatibilidade: CentOS 7, RHEL 7
#
# COMPONENTES INSTALADOS:
#   • Apache HTTP Server
#   • MariaDB Server
#   • PHP 7.3 (via repositório Remi)
#   • phpMyAdmin
#   • Utilitários essenciais
#
# ATENÇÃO: Este script requer privilégios de administrador (root)
#          e conectividade com a internet
#
#=============================================================================
# PASSO A PASSO PARA EXECUÇÃO:
#=============================================================================
# 1. Torne o script executável: chmod +x lamp-centos7.sh
# 2. Execute como root: sudo ./lamp-centos7.sh
# 3. Acompanhe o processo de instalação
# 4. Configure as senhas quando solicitado
# 5. Acesse http://seu-servidor/phpMyAdmin para testar
#
# CONFIGURAÇÕES IMPORTANTES:
#   • Firewall será desabilitado
#   • Apache configurado com virtual hosts
#   • MariaDB com configuração segura
#   • PHP 7.3 com extensões essenciais
#=============================================================================

# Configurações globais
set -e  # Sair em caso de erro
LOG_FILE="/var/log/lamp-installation-$(date +%Y%m%d_%H%M%S).log"

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

# Função para verificar versão do CentOS
check_centos_version() {
    if [ ! -f /etc/centos-release ]; then
        print_message "$RED" "Este script é específico para CentOS!"
        exit 1
    fi
    
    local version=$(cat /etc/centos-release | grep -oP '(?<=release )\d+')
    if [ "$version" != "7" ]; then
        print_message "$YELLOW" "⚠ Aviso: Este script foi testado apenas no CentOS 7"
        print_message "$YELLOW" "Versão detectada: CentOS $version"
        read -p "Deseja continuar? (s/N): " continue_install
        case $continue_install in
            [sS]|[sS][iI][mM])
                print_message "$YELLOW" "Continuando instalação..."
                ;;
            *)
                print_message "$BLUE" "Instalação cancelada"
                exit 0
                ;;
        esac
    fi
}

#=============================================================================
# INÍCIO DO SCRIPT
#=============================================================================

print_message "$BLUE" "Iniciando instalação LAMP para CentOS 7..."
print_message "$YELLOW" "Log será salvo em: $LOG_FILE"

# Verificações iniciais
check_root
check_centos_version

echo "Instalação LAMP iniciada em: $(date)" >> "$LOG_FILE"

#=============================================================================
# 1. CONFIGURAÇÃO INICIAL DO FIREWALL
#=============================================================================

print_section "1. CONFIGURANDO FIREWALL"

print_message "$YELLOW" "Verificando status do firewall..."
systemctl status firewalld || true

print_message "$YELLOW" "Parando e desabilitando firewall..."
systemctl stop firewalld
systemctl disable firewalld
check_command "Configuração do firewall"

#=============================================================================
# 2. CONFIGURAÇÃO DE REPOSITÓRIOS
#=============================================================================

print_section "2. CONFIGURANDO REPOSITÓRIOS"

print_message "$YELLOW" "Instalando plugin de prioridades..."
yum install -y yum-plugin-priorities
check_command "Instalação yum-plugin-priorities"

print_message "$YELLOW" "Configurando prioridades do repositório base..."
sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
check_command "Configuração prioridade repositório base"

print_message "$YELLOW" "Instalando repositório EPEL..."
yum install -y epel-release
sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo
check_command "Configuração repositório EPEL"

print_message "$YELLOW" "Instalando repositórios SCL..."
yum install -y centos-release-scl-rh centos-release-scl
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
check_command "Configuração repositórios SCL"

print_message "$YELLOW" "Atualizando sistema..."
yum update -y && yum upgrade -y
check_command "Atualização do sistema"

#=============================================================================
# 3. INSTALAÇÃO DE UTILITÁRIOS ESSENCIAIS
#=============================================================================

print_section "3. INSTALANDO UTILITÁRIOS ESSENCIAIS"

print_message "$YELLOW" "Instalando ferramentas de administração..."
yum install -y vim glances htop wget curl net-tools
check_command "Instalação utilitários essenciais"

#=============================================================================
# 4. INSTALAÇÃO E CONFIGURAÇÃO DO APACHE
#=============================================================================

print_section "4. INSTALANDO APACHE HTTP SERVER"

print_message "$YELLOW" "Instalando Apache..."
yum install -y httpd
check_command "Instalação Apache"

print_message "$YELLOW" "Iniciando e habilitando Apache..."
systemctl start httpd
systemctl enable httpd
check_command "Configuração serviço Apache"

print_message "$YELLOW" "Criando backup da configuração original..."
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.backup

print_message "$YELLOW" "Configurando Apache..."
# Configurar ServerName
echo "ServerName localhost:80" >> /etc/httpd/conf/httpd.conf

# Configurar DirectoryIndex
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php index.cgi/' /etc/httpd/conf/httpd.conf

# Configurar AllowOverride
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Adicionar configurações de segurança
cat >> /etc/httpd/conf/httpd.conf << 'EOF'

# Configurações de segurança e performance
ServerTokens Prod
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 15

# Ocultar informações do servidor
ServerSignature Off

# Configurações de diretório seguras
<Directory "/var/www/html">
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF

check_command "Configuração Apache"

print_message "$YELLOW" "Reiniciando Apache..."
systemctl restart httpd
check_command "Reinicialização Apache"

#=============================================================================
# 5. INSTALAÇÃO DO PHP 7.3
#=============================================================================

print_section "5. INSTALANDO PHP 7.3"

print_message "$YELLOW" "Adicionando repositório Remi..."
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils
check_command "Instalação repositório Remi"

print_message "$YELLOW" "Habilitando repositório PHP 7.3..."
yum-config-manager --enable remi-php73
check_command "Habilitação PHP 7.3"

print_message "$YELLOW" "Instalando PHP e extensões básicas..."
yum install -y php php-opcache
check_command "Instalação PHP básico"

print_message "$YELLOW" "Instalando extensões PHP adicionais..."
yum install -y php-mysqlnd php-pdo php-gd php-ldap php-odbc php-pear \
               php-xml php-xmlrpc php-mbstring php-soap php-zip \
               php-curl php-json php-common
check_command "Instalação extensões PHP"

print_message "$YELLOW" "Configurando PHP..."
# Backup da configuração original
cp /etc/php.ini /etc/php.ini.backup

# Configurações básicas de segurança
sed -i 's/expose_php = On/expose_php = Off/' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = America\/Sao_Paulo/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php.ini

check_command "Configuração PHP"

print_message "$YELLOW" "Reiniciando Apache para carregar PHP..."
systemctl restart httpd
check_command "Reinicialização Apache com PHP"

#=============================================================================
# 6. INSTALAÇÃO E CONFIGURAÇÃO DO MARIADB
#=============================================================================

print_section "6. INSTALANDO MARIADB SERVER"

print_message "$YELLOW" "Instalando MariaDB..."
yum install -y mariadb-server mariadb
check_command "Instalação MariaDB"

print_message "$YELLOW" "Iniciando e habilitando MariaDB..."
systemctl start mariadb
systemctl enable mariadb
check_command "Configuração serviço MariaDB"

print_message "$YELLOW" "Configurando segurança do MariaDB..."
print_message "$BLUE" "IMPORTANTE: Você será solicitado a configurar a segurança do MariaDB"
print_message "$BLUE" "Recomendações:"
print_message "$BLUE" "  • Definir senha para root"
print_message "$BLUE" "  • Remover usuários anônimos: Y"
print_message "$BLUE" "  • Desabilitar login root remoto: Y"
print_message "$BLUE" "  • Remover banco de dados test: Y"
print_message "$BLUE" "  • Recarregar tabelas de privilégios: Y"

read -p "Pressione Enter para continuar com mysql_secure_installation..."
mysql_secure_installation

check_command "Configuração segurança MariaDB"

#=============================================================================
# 7. INSTALAÇÃO DO PHPMYADMIN
#=============================================================================

print_section "7. INSTALANDO PHPMYADMIN"

print_message "$YELLOW" "Instalando phpMyAdmin..."
yum --enablerepo=epel install -y phpMyAdmin
check_command "Instalação phpMyAdmin"

print_message "$YELLOW" "Configurando phpMyAdmin..."
# Backup da configuração original
cp /etc/httpd/conf.d/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf.backup

# Configurar acesso ao phpMyAdmin
cat > /etc/httpd/conf.d/phpMyAdmin.conf << 'EOF'
# phpMyAdmin - Web based MySQL browser written in php
# 
# Allows only localhost by default
#
# But allowing phpMyAdmin to anyone other than localhost should be considered
# dangerous unless properly secured by SSL

Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin

<Directory /usr/share/phpMyAdmin/>
   AddDefaultCharset UTF-8

   <IfModule mod_authz_core.c>
     # Apache 2.4
     <RequireAny>
       Require ip 127.0.0.1
       Require ip ::1
       # Permitir acesso da rede local (ajuste conforme necessário)
       Require ip 192.168.0.0/16
       Require ip 10.0.0.0/8
       Require ip 172.16.0.0/12
     </RequireAny>
   </IfModule>
   <IfModule !mod_authz_core.c>
     # Apache 2.2
     Order Deny,Allow
     Deny from All
     Allow from 127.0.0.1
     Allow from ::1
     # Permitir acesso da rede local
     Allow from 192.168.0.0/16
     Allow from 10.0.0.0/8
     Allow from 172.16.0.0/12
   </IfModule>
</Directory>

<Directory /usr/share/phpMyAdmin/setup/>
   <IfModule mod_authz_core.c>
     # Apache 2.4
     Require ip 127.0.0.1
     Require ip ::1
   </IfModule>
   <IfModule !mod_authz_core.c>
     # Apache 2.2
     Order Deny,Allow
     Deny from All
     Allow from 127.0.0.1
     Allow from ::1
   </IfModule>
</Directory>
EOF

check_command "Configuração phpMyAdmin"

print_message "$YELLOW" "Reiniciando Apache..."
systemctl restart httpd
check_command "Reinicialização final Apache"

#=============================================================================
# 8. CRIAÇÃO DE PÁGINA DE TESTE
#=============================================================================

print_section "8. CRIANDO PÁGINAS DE TESTE"

print_message "$YELLOW" "Criando página de informações PHP..."
cat > /var/www/html/info.php << 'EOF'
<?php
phpinfo();
?>
EOF

print_message "$YELLOW" "Criando página de teste de conexão com banco..."
cat > /var/www/html/dbtest.php << 'EOF'
<?php
$servername = "localhost";
$username = "root";
// Substitua pela senha que você definiu durante mysql_secure_installation
$password = "";

try {
    $pdo = new PDO("mysql:host=$servername", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<h2>Conexão com MariaDB realizada com sucesso!</h2>";
    echo "<p>Data/Hora: " . date('d/m/Y H:i:s') . "</p>";
    
    // Mostrar versão do MySQL/MariaDB
    $stmt = $pdo->query('SELECT VERSION()');
    $version = $stmt->fetchColumn();
    echo "<p>Versão do MariaDB: $version</p>";
    
} catch(PDOException $e) {
    echo "<h2>Erro na conexão: " . $e->getMessage() . "</h2>";
}
?>
EOF

print_message "$YELLOW" "Criando página inicial personalizada..."
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LAMP Stack - CentOS 7</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; }
        .info { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .success { color: #27ae60; font-weight: bold; }
        a { color: #3498db; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .footer { text-align: center; margin-top: 30px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 LAMP Stack Instalado com Sucesso!</h1>
        
        <div class="info">
            <h3>Stack LAMP Configurada:</h3>
            <ul>
                <li><span class="success">✓ Linux:</span> CentOS 7</li>
                <li><span class="success">✓ Apache:</span> HTTP Server</li>
                <li><span class="success">✓ MariaDB:</span> Database Server</li>
                <li><span class="success">✓ PHP:</span> 7.3 with Extensions</li>
            </ul>
        </div>
        
        <div class="info">
            <h3>Links Úteis:</h3>
            <ul>
                <li><a href="/info.php">Informações do PHP (phpinfo)</a></li>
                <li><a href="/dbtest.php">Teste de Conexão com Banco</a></li>
                <li><a href="/phpMyAdmin">phpMyAdmin</a></li>
            </ul>
        </div>
        
        <div class="info">
            <h3>Localizações Importantes:</h3>
            <ul>
                <li><strong>DocumentRoot:</strong> /var/www/html/</li>
                <li><strong>Configuração Apache:</strong> /etc/httpd/conf/httpd.conf</li>
                <li><strong>Configuração PHP:</strong> /etc/php.ini</li>
                <li><strong>Logs Apache:</strong> /var/log/httpd/</li>
            </ul>
        </div>
        
        <div class="footer">
            <p>Instalação realizada em: <?php echo date('d/m/Y H:i:s'); ?></p>
            <p>Script LAMP para CentOS 7 - Versão 2.0</p>
        </div>
    </div>
</body>
</html>
EOF

check_command "Criação páginas de teste"

#=============================================================================
# 9. CONFIGURAÇÕES FINAIS
#=============================================================================

print_section "9. CONFIGURAÇÕES FINAIS"

print_message "$YELLOW" "Definindo permissões corretas..."
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/
check_command "Configuração permissões"

print_message "$YELLOW" "Configurando SELinux para desenvolvimento..."
setsebool -P httpd_can_network_connect on 2>/dev/null || true
setsebool -P httpd_can_network_connect_db on 2>/dev/null || true
check_command "Configuração SELinux"

#=============================================================================
# FINALIZAÇÃO
#=============================================================================

print_section "INSTALAÇÃO CONCLUÍDA"

print_message "$GREEN" "✓ Stack LAMP instalada com sucesso!"

echo -e "${YELLOW}📋 RESUMO DA INSTALAÇÃO:${NC}"
echo -e "   • Apache HTTP Server: ✓ Instalado e configurado"
echo -e "   • MariaDB Server: ✓ Instalado e configurado"
echo -e "   • PHP 7.3: ✓ Instalado com extensões"
echo -e "   • phpMyAdmin: ✓ Instalado e configurado"

echo -e "\n${BLUE}🌐 ACESSO AOS SERVIÇOS:${NC}"
echo -e "   • Página inicial: http://$(hostname -I | awk '{print $1}')/"
echo -e "   • phpMyAdmin: http://$(hostname -I | awk '{print $1}')/phpMyAdmin"
echo -e "   • Informações PHP: http://$(hostname -I | awk '{print $1}')/info.php"

echo -e "\n${CYAN}🔧 PRÓXIMOS PASSOS:${NC}"
echo -e "   1. Configure a senha do MySQL no arquivo /var/www/html/dbtest.php"
echo -e "   2. Configure um firewall adequado se necessário"
echo -e "   3. Configure SSL/HTTPS para produção"
echo -e "   4. Ajuste as configurações de rede do phpMyAdmin conforme necessário"

echo -e "\n${YELLOW}📄 ARQUIVOS DE LOG:${NC}"
echo -e "   • Log da instalação: $LOG_FILE"
echo -e "   • Logs do Apache: /var/log/httpd/"
echo -e "   • Logs do MariaDB: /var/log/mariadb/"

print_message "$GREEN" "🎉 Instalação LAMP finalizada com sucesso!"

echo "Instalação LAMP concluída em: $(date)" >> "$LOG_FILE"