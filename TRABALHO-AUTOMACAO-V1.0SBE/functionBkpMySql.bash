#!/bin/bash

BKP_LOG=/var/log/backupMySQL.log

function backup_mysql () {

	dialog --yesno "Eae Rapaz voce quer executar o backup agora? selecione YES. Se quiser agendar um backup automatico selecione NO" 10 75 ;
                  if [ "$?" -eq '1' ]
                        then
				NEWBKP=$(dialog --stdout                                                \
                                                --title 'Novo backup único:'                            \
                                                --inputbox 'Digite quando devo executar o backup:'    	\
                                                0 0)
				echo "$ScriptBkpName $NEWBKP"
				at -f $ScriptBkpName -v $NEWBKP
			else
				./bkp_mysql.bash
			fi
}
function verLog () {

dialog                                        	\
   --title 'Visualizando Arquivo de Log'      	\
   --textbox $BKP_LOG			\
   0 0

}
function agendaBKP () {

 	crontab -l > /tmp/agendarBKP.txt
	sleep 1
	vi /tmp/agendarBKP.txt
	crontab /tmp/agendarBKP.txt
}
function listaAgendaBKP () {

	crontab -l > /tmp/agendarBKP.txt
        sleep 1
	textBox '/tmp/agendarBKP.txt' 'Agendamentos atuais cron' 6 70
	at -l > /tmp/agendarBKP2.txt
        sleep 1
        textBox '/tmp/agendarBKP2.txt' 'Agendamentos atuais at' 6 70
}
