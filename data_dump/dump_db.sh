#!/bin/sh

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
  if [ -f db_dump/toc.dat ]; then
    rm -f db_dump/*
  fi
else
  mkdir db_dump
fi

echo Password for user sau_int
pg_dump -h $DbHost -p $DbPort -f db_dump -T recon.django_migrations -Fd -E UTF8 -j 8 -O --no-unlogged-table-data -U sau_int -n admin -n master -n allocation -n geo -n recon -n distribution -n validation_partition -n log -n catalog sau_int
