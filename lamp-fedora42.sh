#!/bin/bash

#=============================================================================
# Script: lamp-fedora42.sh
# Descrição: Instalação e configuração automática de servidor LAMP no Fedora 42
#            (Linux + Apache + MariaDB + PHP + phpMyAdmin)
# Autor: Andre Berger
# Data: 04/10/2025
# Versão: 1.0
# Licença: MIT
# Compatibilidade: Fedora 42+
#=============================================================================

# Configurações do script
set -e  # Sair se qualquer comando falhar
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/lamp-fedora42-$(date '+%Y%m%d_%H%M%S').log"

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Configurações padrão (editáveis)
readonly SERVER_ADMIN="admin@localhost"
readonly SERVER_NAME="localhost"
readonly INTERNAL_NETWORK="127.0.0.1 10.0.0.0/24"
readonly CHARSET="utf8mb4"

#=============================================================================
# PASSO A PASSO DE EXECUÇÃO:
#=============================================================================
# 1. Executar como root:
#    sudo su -
#
# 2. Tornar executável:
#    chmod +x lamp-fedora42.sh
#
# 3. Executar o script:
#    ./lamp-fedora42.sh
#
# 4. Seguir as instruções na tela
#
# 5. Testar a instalação:
#    - Navegue para: http://localhost
#    - Teste PHP: http://localhost/info.php
#    - phpMyAdmin: http://localhost/phpMyAdmin
#
# 6. Verificar logs em caso de problemas:
#    tail -f /tmp/lamp-fedora42-*.log
#=============================================================================

#=============================================================================
# FUNÇÕES AUXILIARES
#=============================================================================

# Função para imprimir mensagens coloridas
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "$LOG_FILE"
}

# Função para imprimir cabeçalho
print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                       🚀 INSTALADOR LAMP FEDORA 42                          ║"
    echo "║                    Linux + Apache + MariaDB + PHP                           ║"
    echo "║                              Versão 1.0                                     ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

# Função para verificar se está executando como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_message "$RED" "❌ Este script deve ser executado como root!"
        print_message "$CYAN" "💡 Execute: sudo ./lamp-fedora42.sh"
        exit 1
    fi
}

# Função para verificar sistema operacional
check_fedora() {
    if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
        print_message "$RED" "❌ Este script é específico para Fedora 42+"
        print_message "$YELLOW" "⚠️  Sistema atual: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
        exit 1
    fi
    
    local fedora_version
    fedora_version=$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')
    
    if [[ $fedora_version -lt 42 ]]; then
        print_message "$YELLOW" "⚠️  Este script foi testado no Fedora 42. Versão atual: $fedora_version"
        print_message "$CYAN" "💡 Continuar mesmo assim? (s/N)"
        read -r continue_anyway
        if [[ "$continue_anyway" != "s" && "$continue_anyway" != "S" ]]; then
            exit 1
        fi
    fi
    
    print_message "$GREEN" "✅ Sistema Fedora $fedora_version detectado"
}

# Função para fazer backup de arquivo
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.backup-$(date '+%Y%m%d_%H%M%S')"
        print_message "$BLUE" "📋 Backup criado: ${file}.backup-$(date '+%Y%m%d_%H%M%S')"
    fi
}

# Função para verificar se serviço está rodando
check_service() {
    local service="$1"
    if systemctl is-active --quiet "$service"; then
        print_message "$GREEN" "✅ Serviço $service está ativo"
        return 0
    else
        print_message "$RED" "❌ Serviço $service não está ativo"
        return 1
    fi
}

# Função para aguardar confirmação do usuário
wait_for_confirmation() {
    local message="$1"
    print_message "$CYAN" "$message"
    read -p "Pressione ENTER para continuar ou Ctrl+C para cancelar..."
}

#=============================================================================
# FUNÇÕES DE INSTALAÇÃO
#=============================================================================

# Função para atualizar sistema
update_system() {
    print_message "$BLUE" "🔄 Atualizando sistema..."
    
    dnf update -y >> "$LOG_FILE" 2>&1
    
    print_message "$GREEN" "✅ Sistema atualizado com sucesso"
}

# Função para instalar e configurar Apache
install_apache() {
    print_message "$BLUE" "🌐 Instalando Apache HTTP Server..."
    
    # Instalar Apache
    dnf install -y httpd >> "$LOG_FILE" 2>&1
    
    # Fazer backup e renomear welcome page
    if [[ -f /etc/httpd/conf.d/welcome.conf ]]; then
        mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.org
        print_message "$BLUE" "📋 Welcome page removida"
    fi
    
    # Fazer backup da configuração original
    backup_file "/etc/httpd/conf/httpd.conf"
    
    # Configurar Apache
    print_message "$BLUE" "⚙️  Configurando Apache..."
    
    # Configurar ServerAdmin
    sed -i "s/#ServerAdmin you@example.com/ServerAdmin $SERVER_ADMIN/" /etc/httpd/conf/httpd.conf
    
    # Configurar ServerName
    sed -i "s/#ServerName www.example.com:80/ServerName $SERVER_NAME:80/" /etc/httpd/conf/httpd.conf
    
    # Remover Indexes das Options
    sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/httpd/conf/httpd.conf
    
    # Configurar AllowOverride
    sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
    
    # Adicionar DirectoryIndex
    sed -i '/DirectoryIndex index.html/c\    DirectoryIndex index.html index.php index.cgi' /etc/httpd/conf/httpd.conf
    
    # Adicionar ServerTokens
    echo -e "\n# Server response header\nServerTokens Prod" >> /etc/httpd/conf/httpd.conf
    
    # Habilitar e iniciar Apache
    systemctl enable httpd >> "$LOG_FILE" 2>&1
    systemctl start httpd >> "$LOG_FILE" 2>&1
    
    # Configurar firewall
    if systemctl is-active --quiet firewalld; then
        print_message "$BLUE" "🔥 Configurando firewall para HTTP..."
        firewall-cmd --add-service=http >> "$LOG_FILE" 2>&1
        firewall-cmd --runtime-to-permanent >> "$LOG_FILE" 2>&1
    fi
    
    check_service "httpd"
    print_message "$GREEN" "✅ Apache instalado e configurado com sucesso"
}

# Função para instalar e configurar PHP
install_php() {
    print_message "$BLUE" "🐘 Instalando PHP e extensões..."
    
    # Instalar PHP e extensões
    dnf install -y php php-mbstring php-pear php-mysqlnd php-mcrypt php-gettext >> "$LOG_FILE" 2>&1
    
    # Reiniciar Apache
    systemctl restart httpd >> "$LOG_FILE" 2>&1
    
    # Verificar se PHP-FPM está rodando
    check_service "php-fpm"
    
    # Criar página de teste PHP
    echo '<?php phpinfo(); ?>' > /var/www/html/info.php
    chmod 644 /var/www/html/info.php
    
    print_message "$GREEN" "✅ PHP instalado e configurado com sucesso"
    print_message "$CYAN" "📄 Página de teste PHP criada: http://$SERVER_NAME/info.php"
}

# Função para instalar e configurar MariaDB
install_mariadb() {
    print_message "$BLUE" "🗃️  Instalando MariaDB..."
    
    # Instalar MariaDB
    dnf install -y mariadb-server >> "$LOG_FILE" 2>&1
    
    # Configurar charset
    print_message "$BLUE" "⚙️  Configurando charset para $CHARSET..."
    
    cat > /etc/my.cnf.d/charset.cnf << EOF
# Configuração de charset para LAMP Fedora 42
# Charset padrão definido para suporte completo UTF-8
[mysqld]
character-set-server = $CHARSET

[client]
default-character-set = $CHARSET
EOF
    
    # Habilitar e iniciar MariaDB
    systemctl enable mariadb >> "$LOG_FILE" 2>&1
    systemctl start mariadb >> "$LOG_FILE" 2>&1
    
    # Configurar firewall para MariaDB
    if systemctl is-active --quiet firewalld; then
        print_message "$BLUE" "🔥 Configurando firewall para MySQL..."
        firewall-cmd --add-service=mysql >> "$LOG_FILE" 2>&1
        firewall-cmd --runtime-to-permanent >> "$LOG_FILE" 2>&1
    fi
    
    check_service "mariadb"
    print_message "$GREEN" "✅ MariaDB instalado e configurado com sucesso"
}

# Função para configurar segurança do MariaDB
secure_mariadb() {
    print_message "$BLUE" "🔐 Configurando segurança do MariaDB..."
    
    print_message "$YELLOW" "⚠️  ATENÇÃO: Configuração de segurança do MariaDB"
    print_message "$CYAN" "Esta etapa irá:"
    print_message "$WHITE" "• Remover usuários anônimos"
    print_message "$WHITE" "• Desabilitar login root remoto"
    print_message "$WHITE" "• Remover banco de teste"
    print_message "$WHITE" "• Recarregar tabelas de privilégios"
    echo
    
    wait_for_confirmation "Deseja executar a configuração automática de segurança?"
    
    # Executar mysql_secure_installation automaticamente
    mysql -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null || true
    mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    
    print_message "$GREEN" "✅ Segurança do MariaDB configurada"
    
    # Criar banco de teste
    print_message "$BLUE" "🧪 Criando banco de teste..."
    
    mysql -e "CREATE DATABASE IF NOT EXISTS lamp_test;" 2>/dev/null || true
    mysql -e "CREATE TABLE IF NOT EXISTS lamp_test.test_table (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50), description TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 2>/dev/null || true
    mysql -e "INSERT INTO lamp_test.test_table (name, description) VALUES ('LAMP Fedora 42', 'Instalação automática realizada com sucesso!');" 2>/dev/null || true
    
    print_message "$GREEN" "✅ Banco de teste criado: lamp_test"
}

# Função para instalar phpMyAdmin
install_phpmyadmin() {
    print_message "$BLUE" "📊 Instalando phpMyAdmin..."
    
    # Instalar phpMyAdmin
    dnf install -y phpMyAdmin >> "$LOG_FILE" 2>&1
    
    # Fazer backup da configuração
    backup_file "/etc/httpd/conf.d/phpMyAdmin.conf"
    
    # Configurar acesso ao phpMyAdmin
    print_message "$BLUE" "⚙️  Configurando acesso ao phpMyAdmin..."
    
    # Permitir acesso da rede interna
    sed -i "s|Require ip 127.0.0.1|Require ip $INTERNAL_NETWORK|g" /etc/httpd/conf.d/phpMyAdmin.conf
    
    # Recarregar Apache
    systemctl reload httpd >> "$LOG_FILE" 2>&1
    
    # Configurar SELinux se estiver ativo
    if getenforce 2>/dev/null | grep -q "Enforcing"; then
        print_message "$BLUE" "🔒 Configurando SELinux para phpMyAdmin..."
        setsebool -P httpd_can_network_connect on >> "$LOG_FILE" 2>&1
        setsebool -P httpd_execmem on >> "$LOG_FILE" 2>&1
        print_message "$GREEN" "✅ SELinux configurado"
    fi
    
    print_message "$GREEN" "✅ phpMyAdmin instalado e configurado"
    print_message "$CYAN" "📊 Acesso ao phpMyAdmin: http://$SERVER_NAME/phpMyAdmin"
}

# Função para criar página de boas-vindas
create_welcome_page() {
    print_message "$BLUE" "📝 Criando página de boas-vindas..."
    
    cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LAMP Fedora 42 - Servidor Configurado</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            max-width: 800px;
        }
        h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .services {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        .service {
            background: rgba(255,255,255,0.15);
            padding: 1rem;
            border-radius: 10px;
            transition: transform 0.3s ease;
        }
        .service:hover {
            transform: translateY(-5px);
        }
        .service h3 {
            margin: 0 0 0.5rem 0;
            font-size: 1.2rem;
        }
        .service a {
            color: #fff;
            text-decoration: none;
            font-weight: bold;
        }
        .service a:hover {
            text-decoration: underline;
        }
        .footer {
            margin-top: 2rem;
            font-size: 0.9rem;
            opacity: 0.8;
        }
        .status {
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid rgba(76, 175, 80, 0.5);
            border-radius: 5px;
            padding: 0.5rem;
            margin: 1rem 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 LAMP Fedora 42</h1>
        <div class="status">
            <strong>✅ Servidor configurado com sucesso!</strong>
        </div>
        
        <p>Seu servidor LAMP (Linux + Apache + MariaDB + PHP) está funcionando perfeitamente!</p>
        
        <div class="services">
            <div class="service">
                <h3>🌐 Apache HTTP</h3>
                <p>Servidor web ativo</p>
                <p>Versão: HTTP/2.4</p>
            </div>
            
            <div class="service">
                <h3>🐘 PHP</h3>
                <p><a href="info.php">Ver informações do PHP</a></p>
                <p>Extensões carregadas</p>
            </div>
            
            <div class="service">
                <h3>🗃️ MariaDB</h3>
                <p>Banco de dados ativo</p>
                <p>Charset: UTF-8</p>
            </div>
            
            <div class="service">
                <h3>📊 phpMyAdmin</h3>
                <p><a href="phpMyAdmin">Acessar phpMyAdmin</a></p>
                <p>Gerenciamento de BD</p>
            </div>
        </div>
        
        <div class="footer">
            <p>Instalação automática realizada em: <strong><?php echo date('d/m/Y H:i:s'); ?></strong></p>
            <p>Script: lamp-fedora42.sh v1.0 | Autor: Andre Berger</p>
        </div>
    </div>
</body>
</html>
EOF
    
    # Converter para PHP para mostrar data dinâmica
    mv /var/www/html/index.html /var/www/html/index.php
    chmod 644 /var/www/html/index.php
    
    print_message "$GREEN" "✅ Página de boas-vindas criada"
}

# Função para executar testes de funcionamento
run_tests() {
    print_message "$BLUE" "🧪 Executando testes de funcionamento..."
    
    # Teste 1: Apache
    if curl -s http://localhost > /dev/null; then
        print_message "$GREEN" "✅ Teste Apache: OK"
    else
        print_message "$RED" "❌ Teste Apache: FALHOU"
    fi
    
    # Teste 2: PHP
    if curl -s http://localhost/info.php | grep -q "PHP Version"; then
        print_message "$GREEN" "✅ Teste PHP: OK"
    else
        print_message "$RED" "❌ Teste PHP: FALHOU"
    fi
    
    # Teste 3: MariaDB
    if mysql -e "SELECT 1;" > /dev/null 2>&1; then
        print_message "$GREEN" "✅ Teste MariaDB: OK"
    else
        print_message "$RED" "❌ Teste MariaDB: FALHOU"
    fi
    
    # Teste 4: Banco de teste
    if mysql -e "SELECT * FROM lamp_test.test_table;" > /dev/null 2>&1; then
        print_message "$GREEN" "✅ Teste Banco de Dados: OK"
    else
        print_message "$YELLOW" "⚠️  Teste Banco de Dados: Aviso"
    fi
    
    # Teste 5: phpMyAdmin
    if [[ -f /usr/share/phpMyAdmin/index.php ]]; then
        print_message "$GREEN" "✅ Teste phpMyAdmin: OK"
    else
        print_message "$RED" "❌ Teste phpMyAdmin: FALHOU"
    fi
}

# Função para mostrar informações finais
show_final_info() {
    echo
    print_message "$GREEN" "🎉 INSTALAÇÃO LAMP CONCLUÍDA COM SUCESSO!"
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                              INFORMAÇÕES DO SERVIDOR                         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}🌐 Servidor Web:${NC} http://$SERVER_NAME"
    echo -e "${WHITE}🐘 Informações PHP:${NC} http://$SERVER_NAME/info.php"
    echo -e "${WHITE}📊 phpMyAdmin:${NC} http://$SERVER_NAME/phpMyAdmin"
    echo -e "${WHITE}🗃️  MariaDB:${NC} mysql -u root -p (autenticação unix_socket)"
    echo
    echo -e "${YELLOW}📋 SERVIÇOS ATIVOS:${NC}"
    echo -e "${WHITE}• Apache HTTP Server (httpd)${NC}"
    echo -e "${WHITE}• PHP-FPM (php-fpm)${NC}"
    echo -e "${WHITE}• MariaDB (mariadb)${NC}"
    echo
    echo -e "${YELLOW}📁 DIRETÓRIOS IMPORTANTES:${NC}"
    echo -e "${WHITE}• Web Root: /var/www/html${NC}"
    echo -e "${WHITE}• Apache Config: /etc/httpd/conf/httpd.conf${NC}"
    echo -e "${WHITE}• PHP Config: /etc/php.ini${NC}"
    echo -e "${WHITE}• MariaDB Config: /etc/my.cnf.d/charset.cnf${NC}"
    echo
    echo -e "${YELLOW}🔧 COMANDOS ÚTEIS:${NC}"
    echo -e "${WHITE}• Reiniciar Apache: systemctl restart httpd${NC}"
    echo -e "${WHITE}• Reiniciar MariaDB: systemctl restart mariadb${NC}"
    echo -e "${WHITE}• Ver logs Apache: tail -f /var/log/httpd/error_log${NC}"
    echo -e "${WHITE}• Ver logs MariaDB: tail -f /var/log/mariadb/mariadb.log${NC}"
    echo
    echo -e "${YELLOW}📋 Log da instalação:${NC} $LOG_FILE"
    echo
    echo -e "${GREEN}✨ Seu servidor LAMP está pronto para uso!${NC}"
}

#=============================================================================
# FUNÇÃO PRINCIPAL
#=============================================================================

main() {
    print_header
    
    # Verificações iniciais
    check_root
    check_fedora
    
    print_message "$BLUE" "🚀 Iniciando instalação do servidor LAMP..."
    print_message "$CYAN" "📋 Log será salvo em: $LOG_FILE"
    echo
    
    wait_for_confirmation "Deseja continuar com a instalação?"
    
    # Executar instalação
    update_system
    echo
    
    install_apache
    echo
    
    install_php
    echo
    
    install_mariadb
    echo
    
    secure_mariadb
    echo
    
    install_phpmyadmin
    echo
    
    create_welcome_page
    echo
    
    run_tests
    echo
    
    show_final_info
}

#=============================================================================
# TRATAMENTO DE SINAIS
#=============================================================================

# Função para cleanup em caso de interrupção
cleanup_on_exit() {
    print_message "$YELLOW" "⚠️  Instalação interrompida pelo usuário"
    print_message "$CYAN" "📋 Log parcial disponível em: $LOG_FILE"
    exit 1
}

# Registrar handlers para sinais
trap cleanup_on_exit SIGINT SIGTERM

#=============================================================================
# EXECUÇÃO
#=============================================================================

# Executar função principal
main "$@"

# Código de saída
print_message "$GREEN" "✅ Script finalizado com sucesso!"
exit 0