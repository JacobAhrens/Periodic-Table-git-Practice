#!/bin/bash

# Define the PSQL variable for querying
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Function to query the database
get_element_info() {
  local query_result=$($PSQL "$1")
  
  if [[ -z $query_result ]]; then
    echo "I could not find that element in the database."
  else
    echo "$query_result" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
}

# Determine if the argument is a number or text
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Argument is a number
  query="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.atomic_number = $1"
elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]
then
  # Argument is a chemical symbol
  query="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.symbol = '$1'"
else
  # Argument is a name
  query="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.name = '$1'"
fi

# Execute the query and get the result
get_element_info "$query"
