#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# truncate tables
echo "$($PSQL "TRUNCATE TABLE games, teams;")"
# loop through games and insert into teams table
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #ignore the first row in insertion
  if [[ $YEAR != year ]]
  then
    # get winner team id
    WINNER_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    # winner team id not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert winner team id
      INSERT_WINNER_TEAM_ID_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
      if [[ $INSERT_WINNER_TEAM_ID_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted a new team: $WINNER"
      fi
      # get new winner team id
      WINNER_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    fi
    # get opponent team id
    OPPONENT_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    # opponent team id not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert opponent team id
      INSERT_OPPONENT_TEAM_ID_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
      if [[ $INSERT_OPPONENT_TEAM_ID_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted a new team: $OPPONENT"
      fi
      # get new opponent team id
      OPPONENT_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    fi
    # insert game
    INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID);")"
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo "Inserted a game with $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, and $OPPONENT_GOALS"
    fi
  fi
done
