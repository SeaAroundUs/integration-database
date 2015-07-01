psql -h pb-p1.corp.vnw.com -c "\copy %1 to temp/%1" sau sau
psql -c "\copy %1 from temp/%1" sau_int sau_int
psql -c "vacuum analyze %1" sau_int sau_int
