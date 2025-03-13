#!/bin/bash

# Este script permite o gerenciamento de usuários através de menus interativos.

while true
do
    echo "Menu de Gerenciamento de Usuários"
    echo "1. Adicionar Usuário"
    echo "2. Listar Usuários"
    echo "3. Remover Usuário"
    echo "4. Sair"
    read -p "Escolha uma opção: " OPCAO

    case $OPCAO in
        1)
            read -p "Digite o nome do usuário a ser adicionado: " NOVO_USUARIO
            sudo useradd "$NOVO_USUARIO"
            echo "Usuário $NOVO_USUARIO adicionado com sucesso."
            ;;
        2)
            echo "Lista de Usuários:"
            cat /etc/passwd | cut -d: -f1
            ;;
        3)
            read -p "Digite o nome do usuário a ser removido: " USUARIO_REMOVER
            sudo userdel -r "$USUARIO_REMOVER"
            echo "Usuário $USUARIO_REMOVER removido com sucesso."
            ;;
        4)
            echo "Saindo..."
            break
            ;;
        *)
            echo "Opção inválida."
            ;;
    esac
done