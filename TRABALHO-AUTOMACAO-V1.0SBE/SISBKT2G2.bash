#!/bin/bash

# SISBKT2G2.bash
# Tourinho
#
# Created by Andre Kroetz Berger
#			 Daniel Meyer
#			 Edivaldo Cezar
#			 Felipe Matias
# on 09/11/13.
# Copyright 2013 __ADEF- Company developer/SA__. All rights reserved.

source /opt/scripts/functionUsers.bash
source /opt/scripts/functionBkpMySql.bash
source /opt/scripts/functionMonitoramento.bash
source /opt/scripts/telasSistema.bash

if [ "$(id -u)" != "0" ]
then
	dialog								\
		--title 'AVISO!'					\
		--msgbox 'Voce deve executar esta software como Root'	\
		6 40
	exit 0
else
	while : ; do


        	resposta=$(dialog --stdout                 \
                        		--title 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v1.0SBE'     \
                        		--menu 'BEM-VINDO(A) AO NOSSO SISTEMA DIZ AE O QUE VOCÊS QUER FAZER?'     \
                        		0 0 0                      \
                        		1 'Manutenção de Usuários' \
                        		2 'Backup Mysql'           \
                        		3 'Monitoramento'          \
                        		0 'Sair'
        				)

        		[ $? -ne 0 ] && break
        		
				case "$resposta" in
                		1) tela_menu_user  ;;
                		2) tela_backup_mysql ;;
                		3) tela_monitor_server ;;
                		0) break ;;
        		esac
	done
	clear
fi
