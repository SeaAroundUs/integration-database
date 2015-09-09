@ECHO OFF
SET CurrentDir=%~dp0
PUSHD %CurrentDir%

SET DATABASE_NAME=sau_int
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Process command line parameter(s)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET DbHost=%1
SET DbPort=%2

IF /i "%DbHost%"=="" SET DbHost=localhost
IF /i "%DbPort%"=="" SET DbPort=5432

:::::::::::::::::::::::::
:: Deleting any previous log files
:::::::::::::::::::::::::
IF EXIST log GOTO LogDirExists
mkdir log

:LogDirExists
IF EXIST log\*.log del /Q .\log\*.log
       
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check if there's already a "sau_int" database present. 
::   If not, create the "sau_int" database and the requisite db users, then proceed to invoke the initialize.sql script.
::   If yes, proceed to invoke initialize.sql script only.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
FOR /F "tokens=1 delims=| " %%A IN ('"psql -h %DbHost% -p %DbPort% -U postgres -A -t -c "select datname from pg_database""') DO (
  IF /i "%%A"=="%DATABASE_NAME%" GOTO CreateIntSchema
)

:: Only get to this point if we didn't find a database with the name 'sau_int' in the code immediately above
SET SQLINPUTFILE=create_user_and_db
psql -h %DbHost% -p %DbPort% -U postgres -f %SQLINPUTFILE%.sql -L .\log\%SQLINPUTFILE%.log
IF ERRORLEVEL 1 GOTO ErrorLabel

:CreateIntSchema
SET SQLINPUTFILE=initialize
psql -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -U postgres -f %SQLINPUTFILE%.sql -L .\log\%SQLINPUTFILE%.log
IF ERRORLEVEL 1 GOTO ErrorLabel

:: Check if we are creating a database in an RDS environment, then reconfigure the postgis package appropriately for user access
FOR /F "tokens=1 delims=| " %%A IN ('"psql -h %DbHost% -p %DbPort% -U postgres -A -t -c "select usename from pg_user""') DO (
  IF /i "%%A"=="rdsadmin" GOTO ConfigureForRDS
)
GOTO InitializeIntSchema

:ConfigureForRDS
ECHO Amazon RDS environment detected. Re-configuring postgis environment appropriately...
SET SQLINPUTFILE=rds_postgis_setup
psql -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -U postgres -f %SQLINPUTFILE%.sql -L .\log\%SQLINPUTFILE%.log
IF ERRORLEVEL 1 GOTO ErrorLabel

:InitializeIntSchema
ECHO Password for user sau_int
pg_restore -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -Fc -a -j 4 -U sau_int data_dump/master.schema
IF ERRORLEVEL 1 GOTO ErrorLabel

ECHO Password for user sau_int
pg_restore -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -Fc -a -j 4 -U sau_int data_dump/recon.schema
IF ERRORLEVEL 1 GOTO ErrorLabel

ECHO Password for user sau_int
pg_restore -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -Fc -a -j 4 -U sau_int data_dump/distribution.schema
IF ERRORLEVEL 1 GOTO ErrorLabel

::ECHO Password for user sau_int
::pg_restore -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -Fc -a -j 4 -U sau_int data_dump/log.schema
::IF ERRORLEVEL 1 GOTO ErrorLabel

:: Refreshing materialized views 
psql -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -U sau_int -t -f refresh_mv.sql -o rmv.sql 
IF ERRORLEVEL 1 GOTO ErrorLabel

:: Adding foreign keys
type index_master.sql >> rmv.sql
type foreign_key_master.sql >> rmv.sql
type index_recon.sql >> rmv.sql
type foreign_key_recon.sql >> rmv.sql
type index_distribution.sql >> rmv.sql
type foreign_key_distribution.sql >> rmv.sql
type index_log.sql >> rmv.sql
type foreign_key_log.sql >> rmv.sql

psql -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -U sau_int -f rmv.sql
IF ERRORLEVEL 1 GOTO ErrorLabel

GOTO Success

:Success
ECHO.
CD %CurrentDir%
ECHO #####
ECHO Successfully created %DATABASE_NAME% database
ECHO #####
GOTO End

:ErrorLabel
CD %CurrentDir%
ECHO "######"
ECHO Error encountered trying to create %DATABASE_NAME% db.
ECHO See .\log\%SQLINPUTFILE%.log for more details...
ECHO #####
GOTO End

:End
SET DbHost=
SET DbPort=
POPD
GOTO:EOF

