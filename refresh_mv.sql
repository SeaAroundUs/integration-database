(select 'refresh materialized view master.' || table_name || ';' from view_v('master') where table_name not like 'TOTALS%')
union all
(select 'refresh materialized view log.' || table_name || ';' from view_v('log') where table_name not like 'TOTALS%');
