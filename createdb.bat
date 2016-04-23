@ECHO OFF
SET CurrentDir=%~dp0
PUSHD %CurrentDir%

SET DATABASE_NAME=sau_int
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Process command line parameter(s)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET DbHost=%1
SET DbPort=%2
SET RestoreThreadCount=%3

IF /i "%DbHost%"=="" SET DbHost=localhost
IF /i "%DbPort%"=="" SET DbPort=5432
IF /i "%RestoreThreadCount%"=="" SET RestoreThreadCount=8

:::::::::::::::::::::::::
:: Deleting any previous log files
:::::::::::::::::::::::::
IF EXIST log GOTO LogDirExists
mkdir log

:LogDirExists
IF EXIST log\*.log del /Q .\log\*.log
       
:CreateSauUsers
:: Only get to this point if we didn't find a database with the name 'sau_int' in the code immediately above
SET SQLINPUTFILE=create_user_and_db
psql -h %DbHost% -p %DbPort% -U postgres -f %SQLINPUTFILE%.sql -L .\log\%SQLINPUTFILE%.log
IF ERRORLEVEL 1 GOTO ErrorLabel

:SetUsersSearchPath
SET SQLINPUTFILE=set_users_search_path
psql -h %DbHost% -p %DbPort% -U postgres -f %SQLINPUTFILE%.sql -L .\log\%SQLINPUTFILE%.log
IF ERRORLEVEL 1 GOTO ErrorLabel

:create_extension
SET SQLINPUTFILE=create_extensions
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
SET SQLINPUTFILE=initialize
psql -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -U postgres -f %SQLINPUTFILE%.sql -L .\log\%SQLINPUTFILE%.log
IF ERRORLEVEL 1 GOTO ErrorLabel

set schemas[0]="admin.schema"
set schemas[1]="master.schema"
set schemas[2]="recon.schema"
set schemas[3]="distribution.schema"
set schemas[4]="catalog.schema"
set schemas[5]="log.schema"

FOR /F "tokens=2 delims==" %%s in ('set schemas[') DO (
  ECHO Restoring %%s schema. Please enter password for user sau_int
  IF EXIST data_dump/%%s pg_restore -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -Fc -a -j %RestoreThreadCount% -U sau_int data_dump/%%s
  IF ERRORLEVEL 1 GOTO ErrorLabel
)

:: Clear previous content or create anew
ECHO vacuum analyze; > rmv.sql
ECHO select update_all_sequence('sau_int'::text); >> rmv.sql

:: Adding foreign keys
type index_master.sql >> rmv.sql
type foreign_key_master.sql >> rmv.sql
type index_recon.sql >> rmv.sql
type foreign_key_recon.sql >> rmv.sql
type index_distribution.sql >> rmv.sql
type foreign_key_distribution.sql >> rmv.sql
type index_allocation.sql >> rmv.sql
type index_log.sql >> rmv.sql
type foreign_key_log.sql >> rmv.sql

:: Adding commands to refresh materialized views 
psql -h %DbHost% -p %DbPort% -d %DATABASE_NAME% -U sau_int -t -f refresh_mv.sql >> rmv.sql 
IF ERRORLEVEL 1 GOTO ErrorLabel

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

