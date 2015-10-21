@ECHO OFF
IF [%1]==[] (
  SET /p DumpFile=Enter schema dump file name:
) ELSE (
  SET DumpFile=%1
)

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
pg_restore -h %DbHost% -p %DbPort% -Fc -j 4 -a -d sau_int -U sau_int %DumpFile%

