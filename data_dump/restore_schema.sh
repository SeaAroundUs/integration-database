#!/bin/sh

if [ -z "$1" ]; then
  echo -n "Enter schema dump file name: "
  read DumpFile
else
  DumpFile=$1
fi

if [ -z "$2" ]; then
  DbHost=localhost
else
  DbHost=$2
fi

echo Password for user sau_int
pg_restore -h $DbHost -Fc -j 4 -a -d sau_int -U sau_int $DumpFile
