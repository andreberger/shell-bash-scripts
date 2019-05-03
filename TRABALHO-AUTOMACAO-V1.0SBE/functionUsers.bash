#!/bin/bash

function selectUser() 
{
		getent passwd | egrep '(/bin/bash|/bin/sh)' | cut -d ':' -f 1,6 | tr ':' ' ' > /tmp/deletausuario.txt
	        DEL=$(dialog --stdout                                                          		\
	                --menu 'Selecione o usuário a ser excluído:'                                    \
        	        10 40 0                                                                         \
               		`cat /tmp/deletausuario.txt`)
}
function textBox() 
{
	dialog 	--title " $2"	\
        	--textbox $1    \
        	25 50
		rm $1	
}
function listarUsuario() 
{  
	getent passwd | egrep '(/bin/bash|/bin/sh)' | cut -d ':' -f1 > /tmp/listausuario.txt
  	textBox '/tmp/listausuario.txt' 'Usuários do sistema'
}
function adicionarUsuario() 
{  
  	NOME_USUARIO=$(dialog --stdout				\
			--title 'Adicionando usuário:'          \
                        --inputbox 'Digite o nome do usuário:'  \
                        0 0
        )
  	SENHA=$(dialog --stdout					\
		 --title 'Insira a nova senha:'              	\
                 --passwordbox 'Insira a senha do usuário:'    	\
                 0 0
        )
	SENHAR=$(dialog --stdout                                \
                                --title 'Repita a nova senha:'                 \
                                --passwordbox 'Repita a senha do usuário:'     \
                                0 0
	)
	if [ $SENHA == $SENHAR ]
                                then
                                        pass=$(perl -e 'print crypt($ARGV[0], "password")' $SENHA)
                                        useradd -p $pass $NOME_USUARIO
                                        dialog                                          			\
                                                --title 'Senha atualizada'                        		\
                                                --msgbox 'A nova senha informada foi atualizada com sucesso.'   \
                                                6 60

                        else
                                dialog                                          		\
                                        --title 'Senhas não conferem'                        	\
                                        --msgbox 'As senhas informadas não coincedem.'   	\
                                        6 60
                        fi
}
function buscarUsuario() 
{
	NOMEUSUARIO=$(dialog --stdout                           \
        		--title 'Busque um usuário:'            \
                        --inputbox 'Digite o nome do usuário:'  \
                        0 0
	)
  	getent passwd | egrep ^$NOMEUSUARIO | egrep '(/bin/bash|/bin/sh)' | cut -d ':' -f 1,5,6,7 | tr ':' '  ' > /tmp/finduser.txt
	RESULTADO_BUSCA=$(cat '/tmp/finduser.txt')
	if [ -s /tmp/finduser.txt ]
		then
                	textBox '/tmp/finduser.txt' ' Lista usuário selecionado'
	else
		dialog                                          	\
                       --title 'Usuário não encontrado'         	\
                       --msgbox 'Usuário não encontrado no sistema.'   	\
                       6 60
	fi
}
function alteraUsuario() {
	ALTER_MENU=$(dialog --stdout				\
        		--title 'ALTERAÇÂO'            		\
        		--menu 'Alteração de usuário:' 		\
        		0 0 0                           	\
        		1 'Alterar nome de login do usuário'    \
        		2 'Alterar descrição do usuário'        \
        		3 'Alterar shell do usuário'            \
        		4 'Alterar senha do usuário'		\
        		0 'Sair' 
			)
		
		altlog () {
			selectUser
			if [ $DEL != ' ' ]
		            then
			    dialog --yesno "Você está alterando o nome de login do usuário "$DEL". Tem certeza que quer continuar agora?" \
					10 75 ;
			               if [ "$?" -eq '0' ]
                       				then
							NEWLOG=$(dialog --stdout                           		\
                        						--title 'Novo Nome:' 				\
                        						--inputbox 'Digite o novo nome do usuário:'  	\
                        						0 0)
        	                                        usermod -l $NEWLOG $DEL
                                                	dialog                                  	\
								--title 'Login alterado'		\
                                                        	--msgbox 'Login alterado com sucesso.'  \
                                                        	6 60

                  			fi
        		fi
		}

		altdesc () {
			selectUser
                        if [ $DEL != ' ' ]
                            then
                            dialog --yesno "Você está alterando a descrição do usuário "$DEL". Tem certeza que quer continuar agora?" \
                                        10 75 ;
                                       if [ "$?" -eq '0' ]
                                                then
                                                        NEWCOM=$(dialog --stdout                                        	\
                                                                        --title 'Novo comentário:'                            	\
                                                                        --inputbox 'Digite o novo comentário do usuário:'   	\
                                                                        0 0)
                                                        usermod -c "$NEWCOM" $DEL
                                                        dialog                                          	\
                                                                --title 'Comentário alterado'                   \
                                                                --msgbox 'Comentário alterado com sucesso.'   	\
                                                                6 60

                                        fi
                        fi

		}
		
		altshell () {
			selectUser
                        if [ $DEL != ' ' ]
                            then
                            dialog --yesno "Você está alterando o Interpretador padrão do usuário "$DEL". Tem certeza que quer continuar agora?" \
                                        10 75 ;
                                       if [ "$?" -eq '0' ]
                                                then
                                                        NEWINT=$(dialog --stdout                                                \
                                                                        --title 'Novo interpretador:'                           \
                                                                        --inputbox 'Digite o novo Interpretador do usuário:'   	\
                                                                        0 0)
                                                        usermod -s "$NEWINT" $DEL
                                                        dialog                                          	\
                                                                --title 'Interpretador alterado'                \
                                                                --msgbox 'Interpretador alterado com sucesso.'  \
                                                                6 60

                                        fi
                        fi
	
		}

		altsenha () {
			selectUser	

			SENHA=$(dialog --stdout                                \
		                --title 'Insira a nova senha:'                 \
               			--passwordbox 'Insira a senha do usuário:'     \
                 		0 0
        		)

			SENHAR=$(dialog --stdout                               \
                                --title 'Repita a nova senha:'                 \
                                --passwordbox 'Repita a senha do usuário:'     \
                                0 0
                        )
			if [ $SENHA == $SENHAR ]
				then
		        		pass=$(perl -e 'print crypt($ARGV[0], "password")' $SENHA)
        				usermod -p $pass $DEL
					dialog                                          			\
                                        	--title 'Senha atualizada'                        		\
                                        	--msgbox 'A nova senha informada foi atualizada com sucesso.'   \
                                        	6 60

			else
				dialog                                          		\
                                	--title 'Senhas não conferem'                        	\
                                        --msgbox 'As senhas informadas não coincedem.'   	\
                                        6 60
			fi

		}

    		# Ela apertou CANCELAR ou ESC, então vamos sair...
    		[ $? -ne 0 ] && break

    		# De acordo com a opção escolhida, dispara programas
    		case "$ALTER_MENU" in
         		1) altlog   ;;
         		2) altdesc  ;;
         		3) altshell ;;
			4) altsenha ;;
         		0) break ;;
    		esac
}

function deletaUsuario () {

	selectUser
	if [ $DEL != ' ' ]
		then
	   	  dialog --yesno "Você está excluíndo o usuário "$DEL". Tem certeza que quer continuar agora?" 10 75 ;
        	  if [ "$?" -eq '0' ]
               		then
		  		dialog --yesno 'Você gostaria de remover o diretório home do Usuário agora?' 10 70 ;
		  		if [ "$?" -eq '0' ]
                			then
                        			userdel -r $DEL
						groupdel $DEL
						dialog                                            			\
   							--title 'Usuário excluído!'                      		\
   							--msgbox 'Usuário e diretório pessoal excluídos com sucesso.'  	\
   							6 60	
        	  		else
					userdel $DEL
					groupdel $DEL
					dialog							\
						--title 'Usuário excluído!'                     \
                        			--msgbox 'Usuário excluído com sucesso.'   	\
                        			6 50
		  		fi

	  	  fi
	fi
}
