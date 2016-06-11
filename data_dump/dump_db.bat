@ECHO OFF
IF [%1]==[] (
  SET DbServer=localhost
) ELSE (
  SET DbServer=%1
)

IF [%2]==[] (
  SET DbPort=5432
) ELSE (
  SET DbPort=%2
)

IF EXIST db_dump GOTO DumpOutDB
mkdir db_dump

:DumpOutDB
IF EXIST db_dump\toc.dat DEL db_dump\*
echo Password for user sau_int
pg_dump -h %DbServer% -p %DbPort% -f db_dump -T recon.django_migrations -Fd -E UTF8 -j 8 -O --no-unlogged-table-data -U sau_int -n admin -n master -n recon -n distribution -n allocation -n geo -n validation_partition -n log -n catalog sau_int

@ECHO OFF

