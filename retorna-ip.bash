#!/bin/bash

# Este script retorna o endereço IP de todos os usuários logados no sistema.

who -u | awk '{print $5}' | sort -u