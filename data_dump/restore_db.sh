#!/bin/sh

###########################################################
## Function to call when error is encountered
###########################################################
ExitWithError () {
  echo
  exit 1            
}

if [ -z "$1" ]; then
  DbHost=localhost
else
  DbHost=$1
fi

if [ -z "$2" ]; then
  DbPort=5432
else
  DbPort=$2
fi

if [ -d db_dump ]; then
  if [ ! -f db_dump/toc.dat ]; then
    echo Database dump directory (db_dump) is empty. Please execute dump_db before executing this script.
    ExitWithError
  fi
else
  echo No prior database dump directory exists. Please execute dump_db before executing this script.
  ExitWithError
fi

echo Password for user sau_int
psql -h $DbHost -p $DbPort -c "DROP SCHEMA IF EXISTS master,admin,catalog,allocation,validation_partition,log,recon,distribution,geo CASCADE" sau_int sau_int
echo Password for user sau_int
pg_restore -h $DbHost -p $DbPort -Fd -j 8 -O --disable-triggers -U sau_int -d sau_int db_dump
