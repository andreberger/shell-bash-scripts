#!/bin/bash

# Este script "pinga" dois endereços e analisa os resultados.

ENDERECO1=$1
ENDERECO2=$2
QUANTIDADE=$3

echo "Pingando $ENDERECO1..."
ping -c "$QUANTIDADE" "$ENDERECO1" > "$ENDERECO1.txt"

echo "Pingando $ENDERECO2..."
ping -c "$QUANTIDADE" "$ENDERECO2" > "$ENDERECO2.txt"

# a) Quantidade de pacotes enviados
ENVIADOS1=$(grep "packets transmitted" "$ENDERECO1.txt" | awk '{print $1}')
ENVIADOS2=$(grep "packets transmitted" "$ENDERECO2.txt" | awk '{print $1}')

echo "Quantidade de pacotes enviados para $ENDERECO1: $ENVIADOS1"
echo "Quantidade de pacotes enviados para $ENDERECO2: $ENVIADOS2"

# b) Quantidade de pacotes recebidos
RECEBIDOS1=$(grep "packets received" "$ENDERECO1.txt" | awk '{print $4}')
RECEBIDOS2=$(grep "packets received" "$ENDERECO2.txt" | awk '{print $4}')

echo "Quantidade de pacotes recebidos de $ENDERECO1: $RECEBIDOS1"
echo "Quantidade de pacotes recebidos de $ENDERECO2: $RECEBIDOS2"

# c) Menor perda percentual
PERDA1=$(grep "packet loss" "$ENDERECO1.txt" | awk '{print $6}' | tr -d '%')
PERDA2=$(grep "packet loss" "$ENDERECO2.txt" | awk '{print $6}' | tr -d '%')

if [ "$PERDA1" -lt "$PERDA2" ]
then
    MENOR_PERDA="$ENDERECO1"
else
    MENOR_PERDA="$ENDERECO2"
fi

echo "Endereço com menor perda percentual: $MENOR_PERDA"

# d) Menor tempo de RTT
MIN_RTT1=$(grep "rtt" "$ENDERECO1.txt" | awk -F'/' '{print $4}')
MIN_RTT2=$(grep "rtt" "$ENDERECO2.txt" | awk -F'/' '{print $4}')

if [ "$(echo "$MIN_RTT1 < $MIN_RTT2" | bc -l)" -eq 1 ]
then
    MENOR_RTT="$ENDERECO1"
else
    MENOR_RTT="$ENDERECO2"
fi

echo "Endereço com menor tempo de RTT: $MENOR_RTT"

rm "$ENDERECO1.txt" "$ENDERECO2.txt"