create or replace function generate_schema_truncate_cmd(i_schema text) returns text as
$body$
  select 'truncate table ' || array_to_string(array_agg(i_schema || '.' || table_name), ',') || ';' from schema_v(i_schema) where table_name not like 'TOTALS%';
$body$
language sql;

