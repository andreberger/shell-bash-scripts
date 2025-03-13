#!/bin/bash

# Este script avalia quantas vezes um usuário tentou logar sem sucesso.

read -p "Digite o nome do usuário: " USUARIO
read -p "Digite o número máximo de falhas permitidas: " MAX_FALHAS

FALHAS=$(grep "authentication failure" /var/log/auth.log | grep "$USUARIO" | wc -l)

if [ $FALHAS -gt $MAX_FALHAS ]
then
    echo "Aviso: O usuário $USUARIO ultrapassou o limite de $MAX_FALHAS falhas de login. Falhas: $FALHAS"
else
    echo "O usuário $USUARIO teve $FALHAS falhas de login, dentro do limite de $MAX_FALHAS."
fi