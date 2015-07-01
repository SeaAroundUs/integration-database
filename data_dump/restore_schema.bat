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

echo Password for user sau_int
pg_restore -h %DbHost% -Fc -j 4 -a -d sau_int -U sau_int %DumpFile%

