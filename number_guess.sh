#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Función para obtener un número entero aleatorio entre 1 y 1000
generate_random_number() {
  echo $(( RANDOM % 1000 + 1 ))
}