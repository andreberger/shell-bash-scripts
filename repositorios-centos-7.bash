#!/bin/bash

echo "INSTALANDO - yum-plugin-priorities"

yum -y install yum-plugin-priorities

# set [priority=1] to official repository

sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo

sleep 1

echo "INSTALANDO - epel-release"

yum -y install epel-release

# set [priority=5]

sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo

# for another way, change to [enabled=0] and use it only when needed

sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo

sleep 1

echo "ISNTALANDO REPOSITÓRIOS - centos-release-scl-rh centos-release-scl"

yum -y install centos-release-scl-rh centos-release-scl

# set [priority=10]

sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

# for another way, change to [enabled=0] and use it only when needed

sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

sleep 1

yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# set [priority=10]

sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/remi-safe.repo

# for another way, change to [enabled=0] and use it only when needed

sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/remi-safe.repo

sleep 1 

echo "VAMOS ATUALIZAR AS COISAS"

yum update -y && yum upgrade -y

sleep 1

echo "VOU INSTALAR O HTOP VIM E GLANCES"

yum -y install htop vim glances
