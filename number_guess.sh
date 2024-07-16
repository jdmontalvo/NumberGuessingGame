#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Función para obtener un número entero aleatorio entre 1 y 1000
generate_random_number() {
  echo $(( RANDOM % 1000 + 1 ))
}
# Obtener el nombre de usuario
echo "Enter your username:"
read USERNAME

# Buscar el usuario en la base de datos
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")

# Si el usuario no existe
if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")
else
  # Si el usuario existe, mostrar información
  echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Generar el número secreto
SECRET_NUMBER=$(generate_random_number)
NUMBER_OF_GUESSES=0