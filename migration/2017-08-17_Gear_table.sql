select * into log.gear_table_2017_08_17 from master.gear;

ALTER TABLE master.gear ADD COLUMN notes text;

truncate master.gear;

\copy master.gear from 'gear_final_2017_08_17.txt' with (format csv, header, delimiter E'\t')

VACUUM FULL ANALYZE master.gear;

select admin.grant_access();
