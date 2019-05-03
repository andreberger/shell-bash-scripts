#!/bin/bash

function monitSockets () 
{
	NEWSOCK=1
	rm -rf /tmp/newsock.txt
	rm -rf /tmp/newport.txt
	rm -rf /tmp/respmonit.txt
	rm -rf /tmp/resperrmonit.txt
	
	HASPORTS=false;
	
	 while [ ! -z $NEWSOCK ]  
                do
                        NEWSOCK=$(dialog --stdout                                       \
                                         --title 'Lista de IPs a serem monitorados:'    \
                                         --inputbox 'Digite o IP:' 			\
                                         0 0)
			if [ ! -z $NEWSOCK ]
			  then
				NEWPORT=$(dialog --stdout                               \
		                         --title 'Lista de Portas a serem monitoradas:' \
                		         --inputbox 'Digite a porta:'      		\
                         		 0 0)
				if [ ! -z $NEWPORT  ]
				then
					echo $NEWSOCK >> /tmp/newsock.txt
	                        	echo $NEWPORT >> /tmp/newport.txt
					HASPORTS=true;
				fi
			fi
                done
}
function execMonit() 
{

		dialog --yesno "Você quer executar o monitoramento agora? aperte yes. Agendar um monitoramento único aperte no" 10 75 ;
                  if [ "$?" -eq '1' ]
                        then
                                NEWMONIT=$(dialog --stdout                                                	\
                                                --title 'Novo monitoramento único:'                     	\
                                                --inputbox 'Digite quando devo executar o monitoramento:'      	\
                                                0 0)
                                echo "$ScriptMonitName $NEWMONIT"
                                at -f $ScriptMonitName -v $NEWMONIT
                        else
                                ./monitor_exec.bash
                        fi
}
function statusMonit () {
	
	if [ -f /tmp/respmonit.txt ]
		then
		 dialog                                        		\
   			--title 'Sockets que responderam com sucesso!' 	\
   			--textbox /tmp/respmonit.txt		  	\
   			0 80
	else
		dialog                                                  \
                	--title 'Sockets que responderam com sucesso!'  \
                	--textbox 'Nenhum socket respondeu'             \
                	0 0
	fi
	sleep 1
	if [ -f /tmp/resperrmonit.txt ]
		then
		  dialog                                                \
                	--title 'Sockets que responderam sem sucesso!'  \
                	--textbox /tmp/resperrmonit.txt                 \
                	0 80
	else
		dialog                                                  \
                        --title 'Sockets que responderam com sucesso!'  \
                        --textbox 'Nenhum socket gerou erro'            \
                        0 0
	fi
}
function verLogs() 
{

	dialog                                          \
   		--title 'Visualizando Arquivo de Log'  	\
   		--textbox $FILE_LOG_MONIT                 \
   		0 0

}
