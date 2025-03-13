#!/bin/bash

# Este script verifica se um usuário está logado a partir de um endereço IP.

IP=$1
USUARIO=$2

if who | grep "$USUARIO" | grep "$IP" > /dev/null
then
    echo "O usuário $USUARIO está logado no IP $IP."
else
    echo "O usuário $USUARIO não está logado no IP $IP."
fi