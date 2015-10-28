CREATE OR REPLACE FUNCTION distribution.st_create_fishnet(nrow integer, ncol integer, xsize float8, ysize float8)
RETURNS TABLE("seq" integer, "row" integer, col integer, geom geometry) AS
$body$
  SELECT (i*ncol + j + 1) as seq, i+1 AS row, j+1 AS col, ST_Translate(cell, -180 + j * $3, 90 - i * $4) AS geom
    FROM generate_series(0, $1-1 ) AS i,
         generate_series(0, $2-1 ) AS j,
         (
           SELECT ST_SETSRID(('POLYGON((0 0, 0 '||(-1*$4)||', '||$3||' '||(-1*$4)||', '||$3||' 0,0 0))')::geometry, 4326) AS cell
         ) AS foo;
$body$ 
LANGUAGE sql;

create or replace function distribution.load_taxon_extent(i_shape_table text) returns setof smallint as
$body$
declare
  ins_sql text;
  rtn_val smallint;                            
begin
  ins_sql := format(
    'with dat as (
      insert into distribution.taxon_extent(taxon_key,geom)
      select %s, d.geom
        from taxon_dis.%s d
      returning 1
    )
    select count(*)::smallint from dat', replace(i_shape_table, 'te_', '')::int, i_shape_table);

  return query execute ins_sql;
end;
$body$
language plpgsql;
