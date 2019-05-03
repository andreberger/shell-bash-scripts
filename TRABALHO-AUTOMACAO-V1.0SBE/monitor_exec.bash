#!/bin/bash

DATE_MONIT=`date +%d%m%Y-%H%M%S`
FILE_LOG_MONIT=/var/log/monitExec.log


if [ ! -w $FILE_LOG_MONIT ]
        then
                touch $FILE_LOG_MONIT
fi

echo "Iniciando Monitoramento $DATE_MONIT " >> $FILE_LOG_MONIT


if [ -s /tmp/newsock.txt ]
        then
                if [ -s /tmp/newport.txt ]
                        then
                                HASPORTS=true
                else
                        echo "Arquivo /tmp/newport.txt não encontrado!" >> $FILE_LOG_MONIT
                fi
else
        echo "Arquivo /tmp/newsock.txt não encontrado!" >> $FILE_LOG_MONIT
fi

if [ $HASPORTS ]
        then

                cat /tmp/newsock.txt | grep . >/tmp/newsock2.txt

                cat /tmp/newport.txt | grep . >/tmp/newport2.txt

                LINECOUNT=$(sed -n -e '$=' /tmp/newsock2.txt)

                COUNTER=0

                while [ $COUNTER -lt $LINECOUNT ]; do
                        let COUNTER=COUNTER+1

                        IP=$(sed -n -e "$COUNTER"'p' /tmp/newsock2.txt)
                        PORT=$(sed -n -e "$COUNTER"'p' /tmp/newport2.txt)

                        nc -z $IP $PORT >> $FILE_LOG_MONIT
                        if [ $? -eq 0 ]
                        	then
                                	echo "$IP:$PORT Ok" >> /tmp/respmonit.txt
					echo "$IP:$PORT Ok" >> $FILE_LOG_MONIT
                        else
                                echo "$IP:$PORT não respondeu" >> /tmp/resperrmonit.txt
				echo "$IP:$PORT não respondeu" >> $FILE_LOG_MONIT
                        fi
                done
fi
DATEMONIT2=`date +%d%m%Y-%H%M%S`
echo "Fim do monitoramento $DATEMONIT2" >> $FILE_LOG_MONIT
echo " " >> $FILE_LOG_MONIT
exit 
