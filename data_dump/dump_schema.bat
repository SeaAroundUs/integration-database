@ECHO OFF
IF [%2]==[] (
  SET DbServer=localhost
) ELSE (
  SET DbServer=%2
)

IF [%3]==[] (
  SET DbPort=5432
) ELSE (
  SET DbPort=%3
)
echo Password for user sau_int
pg_dump -h %DbServer% -p %DbPort% -f %1.schema -T recon.django_migrations -Fc -a -E UTF8 -U sau_int -n %1 %4 %5 %6 %7 %8 %9 sau_int 
@ECHO OFF

