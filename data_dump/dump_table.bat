@ECHO OFF
IF [%2]==[] (
  SET DbHost=localhost
) ELSE (
  SET DbHost=%2
)

IF [%3]==[] (
  SET DbPort=5432
) ELSE (
  SET DbPort=%3
)

echo Password for user sau_int
pg_dump -h %DbHost% -p %DbPort% -f %1 -Fc -a -E UTF8 -U sau_int -t %1 sau_int
@ECHO ON
