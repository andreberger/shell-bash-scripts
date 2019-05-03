#!/bin/bash

zenity --forms --title="Add Friend" \
	--text="Enter information about your friend." \
	--separator="," \
	--add-entry="First Name" \
	--add-entry="Family Name" \
	--add-entry="Email" \
	--add-calendar="Birthday" >> addr.csv

case $? in
    0)
		zenity --title "Add Friend"  --info --text="Amigo adicionado com sucesso"

		zenity --notification\
    --window-icon="info" \
    --text="Finalizamos com sucesso esse software!"        
	;;
    1)
		zenity --title "Add Friend"  --error --text="No friend added."

		zenity --notification\
    --window-icon="info" \
    --text="Finalizamos com sucesso esse software!"  
	;;
    -1)
		zenity --title "Add Friend"  --error --text="An unexpected error has occurred."

		zenity --notification\
    --window-icon="info" \
    --text="Finalizamos com sucesso esse software!"  
	;;
esac


