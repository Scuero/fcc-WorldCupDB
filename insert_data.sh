#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games,teams")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")#inicializa siempre en 1
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")

cat games.csv | while IFS="," read ANIO RONDA GANADOR OPONENTE GOLES_GANADOR GOLES_OPONENTE
do
  if [[ $ANIO != "year" ]]
  then
    ID_GANADOR=$($PSQL "SELECT team_id FROM teams WHERE name='$GANADOR'")
    ID_OPONENTE=$($PSQL "SELECT team_id FROM teams WHERE name='$OPONENTE'")
    if [[ -z $ID_GANADOR ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$GANADOR')"
      ID_GANADOR=$($PSQL "SELECT team_id FROM teams WHERE name='$GANADOR'")
    fi
    if [[ -z $ID_OPONENTE ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPONENTE')"
      ID_OPONENTE=$($PSQL "SELECT team_id FROM teams WHERE name='$OPONENTE'")
    fi
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($ANIO, '$RONDA', $ID_GANADOR, $ID_OPONENTE, $GOLES_GANADOR, $GOLES_OPONENTE)"
  fi
done
