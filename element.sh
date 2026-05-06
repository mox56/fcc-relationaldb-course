#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

RESULT=$($PSQL "
SELECT e.atomic_number, e.name, e.symbol, t.type,
       p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t USING(type_id)
WHERE e.atomic_number::TEXT = '$1'
OR e.symbol = '$1'
OR e.name = '$1'
")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  echo "$RESULT" | while IFS="|" read AN NAME SYMBOL TYPE MASS MP BP
  do
    echo "The element with atomic number $AN is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
  done
fi

# implement element lookup script