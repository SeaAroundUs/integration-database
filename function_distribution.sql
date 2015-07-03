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

