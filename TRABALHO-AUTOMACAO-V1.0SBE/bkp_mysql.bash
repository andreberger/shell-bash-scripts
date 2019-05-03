#!/bin/bash

IPSERVER=192.168.251.100
BKPDIR=/opt
BKPDATA=`date +%d%m%Y-%H%M%S`
BKP_LOG=/var/log/backupMySQL.log
NomeScriptBackupMySql=/opt/scripts/Backup_MySql.bash
DATA=`date +%d%m%Y-%H%M%S`

	if [ ! -w $BKP_LOG]
	then
		touch $BKP_LOG
	fi

	PCT=0
	(	
		while test $PCT != 10
		do
			echo "XXX"
			echo $PCT
			echo "Realizando backup dos arquivos\nAproveite para ir tomar um café\n$PCT % concluído!"
			echo "XXX"
			PCT=`expr $PCT + 1`
			sleep 3
		done
	) | 
	dialog							\
		--title 'Gerenciamento de Backup' 		\
		--gauge 'Iniciando o backup das bases de dados' \
		8 40 0 

	mysqldump -u root -p lasalle --all-databases > /opt/backup/bkp.databases$BKPDATA.db 
	tar -zcvf mysql-$BKPDATA.tar.gz /opt/backup
	scp mysql-$BKPDATA.tar.gz root@$IPSERVER:/opt > out
	
	if [ ! -w ssh root@$IPSERVER "cat /opt/backup/mysql-$BKPDATA.tar.gz"]
	then
		RESPOSTA=$( echo "OPS - Tivemos um erro ai rapaz o backup não foi realizado " )
	else
		RESPOSTA=$( echo "\0/ - Backup Realizado com Sucesso!!!!" )
	fi

	dialog                                      \
   		--title '- RESULTADO DO BACKUP -'   \
   		--msgbox "$RESPOSTA."  		    \
   		6 60

	sleep 3

	function_tela_backup
	
	BKPDATA2=`date +%d/%m/%Y-%H:%M:%S`

	echo "Resultado do Backup: $RESPOSTA" >> $BKP_LOG
	echo "Hora do fim do backup : $BKPDATA2" >> $BKP_LOG
	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ " >> $BKP_LOG
exit 0
