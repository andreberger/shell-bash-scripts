#!/bin/bash

source /opt/scripts/functionBkpMysql.bash
source /opt/scripts/functionMonitoramento.bash
source /opt/scripts/functionUsers.bash

function tela_menu_user() 
{
	while : ; do

        # Mostra o menu na tela, com as ações disponíveis
        resposta=$(dialog --stdout                      \
                        --title 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v1.SBE'          \
                        --menu 'Manutenção de usuário:' \
                        0 0 0                           \
                        1 'Listar usuários'             \
                        2 'Adicionar usuário'           \
                        3 'Excluir usuário'             \
                        4 'Buscar usuário'              \
                        5 'Alterar usuário'             \
                        0 'Sair'
        )

        # Ela apertou CANCELAR ou ESC, então vamos sair...
        [ $? -ne 0 ] && break

        # De acordo com a opção escolhida, dispara programas
        case "$resposta" in
                1) listarUsuario ;;
                2) adicionarUsuario ;;
                3) deletaUsuario ;;
                4) buscarUsuario ;;
                5) alteraUsuario ;;
                0) break ;;
        esac
	done
}

function tela_backup_mysql () {

	while : ; do

        # Mostra o menu na tela, com as aÃ§Ãµes disponÃ­veis
        resposta=$(dialog --stdout                      		\
                        --title 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v1.SBE'          		\
                        --menu 'Backup Data Bases:' 			\
                        0 0 0                           		\
                        1 'Realizar backup'            			\
                        2 'Editar agendamento de backup periÃ³dicos'	\
			3 'Lista agendamentos atuais'			\
                        4 'Vizualizar arquivo de Log'   		\
                        0 'Sair'
        )

        # Ela apertou CANCELAR ou ESC, entÃ£o vamos sair...
        [ $? -ne 0 ] && break

	#source `pwd`/bkp_mysql.bash

        case "$resposta" in
                1) backup_mysql ;;
                2) agendaBKP ;;
		3) listaAgendaBKP ;;
                4) verLog ;;
                0) break ;;
        esac
	done
}

function tela_monitor_server () {
	
	DATEMONIT=`date +%d%m%Y-%H%M%S`
	FILE_LOG_MONIT=/var/log/monitExec.log

	while : ; do
        resposta=$(dialog --stdout                      		\
                        --title 'SISTEMA DE CONTROLE DE AUTOMAÇÃO PARA O TUX v1.SBE'          		\
                        --menu 'Monitoramento de Serviços:' 		\
                        0 0 0                           		\
                        1 'Inserir IPs a serem monitorados'   		\
                        2 'Executar monitoramento'         		\
                        3 'Resultado do monitoramento'    		\
			4 'Editar agendamento de backup periódicos'     \
                        5 'Lista agendamentos atuais'                   \
			6 'Visualizar arquivo de Log'			\
                        0 'Sair'
        )

        [ $? -ne 0 ] && break

        case "$resposta" in
                1) monitSockets ;;
                2) execMonit ;;
                3) statusMonit ;;
                4) agendaBKP ;;
                5) listaAgendaBKP ;;
		6) verLogs ;;
                0) break ;;
        esac
	done
}
