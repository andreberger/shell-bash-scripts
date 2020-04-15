#!/bin/bash

echo "DESABILITANDO FIREWALL"
systemctl status firewalld
systemctl stop firewalld
systemctl disable firewalld

echo "INSTALANDO REPOSITÓRIOS"
yum -y install yum-plugin-priorities
sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo

yum -y install epel-release
sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo

yum -y install centos-release-scl-rh centos-release-scl
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

yum -y update && yum -y upgarde
  
echo "INSTALANDO FRESCURAS ESSENCIAIS"
yum -y install vim glances htop

#################### SERVIDOR APACHE #################
# vi /etc/httpd/conf/httpd.conf
# line 86: change to admin's email address
# ServerAdmin root@srv.world
# line 95: change to your server's name
# ServerName www.srv.world:80
# line 151: change
# AllowOverride All
# line 164: add file name that it can access only with directory's name
# DirectoryIndex index.html index.cgi index.php
# add follows to the end
# server's response header
# ServerTokens Prod
# keepalive is ON
# KeepAlive On
################### DEPOIS SÓ REISTARTAR O APACHE #####################

echo "INSTALANDO APACHE"
yum -y install httpd
systemctl start httpd
systemctl enable httpd


############## PHP 7.3 ################################################

rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum update -y

yum-config-manager --enable remi-php73
yum -y install php php-opcache


systemctl restart httpd.service


############## SERVIDOR MYSQL/MARIADB #################################
#[root@server1 ~]# mysql_secure_installation
#
#NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
 #     SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!
#
#In order to log into MariaDB to secure it, we'll need the current
#password for the root user.  If you've just installed MariaDB, and
##you haven't set the root password yet, the password will be blank,
#so you should just press enter here.
#
#Enter current password for root (enter for none): <--ENTER
#OK, successfully used password, moving on...
#
#Setting the root password ensures that nobody can log into the MariaDB
#root user without the proper authorisation.

#Set root password? [Y/n] 
#New password: <--yourmariadbpassword
##Re-enter new password: <--yourmariadbpassword
#Password updated successfully!
#Reloading privilege tables..
# ... Success!


#By default, a MariaDB installation has an anonymous user, allowing anyone
##to log into MariaDB without having to have a user account created for
#them.  This is intended only for testing, and to make the installation
##go a bit smoother.  You should remove them before moving into a
#production environment.

#Remove anonymous users? [Y/n] <--ENTER
# ... Success!

#Normally, root should only be allowed to connect from 'localhost'.  This
#ensures that someone cannot guess at the root password from the network.

#Disallow root login remotely? [Y/n] <--ENTER
# ... Success!

#By default, MariaDB comes with a database named 'test' that anyone can
#access.  This is also intended only for testing, and should be removed
#before moving into a production environment.

#Remove test database and access to it? [Y/n] <--ENTER
# - Dropping test database...
# ... Success!
 #- Removing privileges on test database...
 #... Success!

#Reloading the privilege tables will ensure that all changes made so far
#will take effect immediately.

#Reload privilege tables now? [Y/n] <--ENTER
# ... Success!

#Cleaning up...

#All done!  If you've completed all of the above steps, your MariaDB
#installation should now be secure.

#Thanks for using MariaDB!
#[root@server1 ~]#
#######################################################################

yum -y install mariadb-server mariadb
systemctl start mariadb.service
systemctl enable mariadb.service

mysql_secure_installation


yum -y install php-mysqlnd php-pdo
yum -y install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-soap curl curl-devel

systemctl restart httpd.service

################### phpmyadmin ##############################
# install from EPEL
#[root@www ~]# yum --enablerepo=epel -y install phpMyAdmin php-mysql php-mcrypt
#[root@www ~]# vi /etc/httpd/conf.d/phpMyAdmin.conf
# line 15: IP address you permit to access
#Require ip 127.0.0.1 10.0.0.0/24
# line 32: IP address you permit to access
#Require ip 127.0.0.1 10.0.0.0/24
#[root@www ~]# systemctl restart httpd

yum -y install phpMyAdmin
systemctl restart  httpd.service





