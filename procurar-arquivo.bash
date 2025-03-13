#!/bin/bash

# Este script procura um arquivo e exibe o resultado.

read -p "Digite o nome do arquivo a ser procurado: " ARQUIVO

RESULTADO=$(find / -name "$ARQUIVO" 2>/dev/null)

if [ -z "$RESULTADO" ]
then
    echo "Arquivo $ARQUIVO não encontrado."
else
    echo "Arquivo $ARQUIVO encontrado em:"
    echo "$RESULTADO"
fi