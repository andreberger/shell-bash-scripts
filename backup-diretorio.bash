#!/bin/bash

# Este script efetua o backup de um diretório.

read -p "Digite o caminho do diretório a ser feito backup: " DIRETORIO

DATA=$(date +%Y%m%d)
USUARIO=$(whoami)
ARQUIVO_BACKUP="$DATA-$USUARIO.tar.gz"

if [ -f "$ARQUIVO_BACKUP" ]
then
    echo "O backup já foi executado hoje."
else
    tar -czvf "$ARQUIVO_BACKUP" "$DIRETORIO"
    echo "Backup realizado com sucesso. Arquivo: $ARQUIVO_BACKUP"
fi