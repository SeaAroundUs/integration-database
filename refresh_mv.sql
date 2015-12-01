(select 'vacuum analyze;')
union all
(select 'refresh materialized view master.' || table_name || ';' from matview_v('master') where table_name not like 'TOTALS%')
union all
(select 'refresh materialized view log.' || table_name || ';' from matview_v('log') where table_name not like 'TOTALS%')
union all
(select 'vacuum analyze;');
