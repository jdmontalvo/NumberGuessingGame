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
# Función para pedir una adivinanza
guess_number() {
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  # Validar que la adivinanza sea un número entero
  while ! [[ $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done

  ((NUMBER_OF_GUESSES++))

  # Comprobar la adivinanza
  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi

    read GUESS
    while ! [[ $GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read GUESS
    done
    ((NUMBER_OF_GUESSES++))
  done

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

# Llamar a la función para adivinar el número
guess_number
 
# Actualizar la base de datos con los resultados del juego
echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
do
  NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
  if [[ -z $BEST_GAME ]] || [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    NEW_BEST_GAME=$NUMBER_OF_GUESSES
  else
    NEW_BEST_GAME=$BEST_GAME
  fi
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE user_id=$USER_ID;")
done
# Validar que la adivinanza sea un número entero
while ! [[ $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done