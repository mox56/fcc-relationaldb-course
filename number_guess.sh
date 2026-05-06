#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'" | xargs)

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)" >/dev/null
else
  GAMES_PLAYED=$(echo $USER_DATA | cut -d'|' -f1)
  BEST_GAME=$(echo $USER_DATA | cut -d'|' -f2)

  if [[ $BEST_GAME == "" || $BEST_GAME == " " ]]
  then
    BEST_GAME=0
  fi

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi

  ((GUESS_COUNT++))
  read GUESS
done

((GUESS_COUNT++))

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"


if [[ -z $USER_DATA ]]
then
  $PSQL "UPDATE users SET games_played=1, best_game=$GUESS_COUNT WHERE username='$USERNAME'" >/dev/null
else
  BEST_GAME=$(echo $BEST_GAME | xargs)

  if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
  then
    $PSQL "UPDATE users SET games_played = games_played + 1, best_game=$GUESS_COUNT WHERE username='$USERNAME'" >/dev/null
  else
    $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'" >/dev/null
  fi
fi

#handle invalid input guesses