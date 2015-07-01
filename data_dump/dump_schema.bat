@ECHO OFF
IF [%2]==[] (
  SET DbServer=localhost
) ELSE (
  SET DbServer=%2
)

IF [%3]==[] (
  SET DbPort=5432
) ELSE (
  SET DbPort=$3
)
echo Password for user sau_int
pg_dump -h %DbServer% -p %DbPort% -f %1.schema -T web.django_migrations -Fc -a -E UTF8 -U sau_int -n %1 sau_int
@ECHO OFF

