#! /bin/bash

if [[ $1 == "test" ]]
then
PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi 



# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $YEAR != "year" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    WINNER_ID=$(echo $WINNER_ID | xargs)

    if [[ -z $WINNER_ID ]]
    then
      WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') RETURNING team_id" | head -n 1)
      WINNER_ID=$(echo $WINNER_ID | xargs)
    fi

    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    OPPONENT_ID=$(echo $OPPONENT_ID | xargs)

    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') RETURNING team_id" | head -n 1)
      OPPONENT_ID=$(echo $OPPONENT_ID | xargs)
    fi

    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OGOALS)")
  fi
done