@ECHO OFF
IF [%1]==[] (
  SET DbHost=localhost
) ELSE (
  SET DbHost=%1
)

IF [%2]==[] (
  SET DbPort=5432
) ELSE (
  SET DbPort=%2
)

IF EXIST db_dump GOTO EmptyDirCheck
ECHO No prior database dump directory exists. Please execute dump_db before executing this script.
GOTO End

:EmptyDirCheck
IF EXIST db_dump\toc.dat GOTO RestoreDB
ECHO Database dump directory (db_dump) is empty. Please execute dump_db before executing this script.
GOTO End

:RestoreDB
ECHO Password for user sau_int
psql -h %DbHost% -p %DbPort% -c "DROP SCHEMA IF EXISTS master,admin,catalog,allocation,validation_partition,log,recon,distribution,geo CASCADE" sau_int sau_int
ECHO Password for user sau_int
pg_restore -h %DbHost% -p %DbPort% -Fd -j 8 -d sau_int -O --disable-triggers -U sau_int db_dump

:End
SET DbHost=
SET DbPort=
POPD
GOTO:EOF
