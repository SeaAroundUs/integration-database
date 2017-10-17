-- Drop Indeces
DROP INDEX simple_area_cell_assignment_raw_cell_id_idx;
DROP INDEX simple_area_cell_assignment_raw_marine_layer_id_idx;

DROP INDEX cell_fao_area_id_idx;
DROP INDEX cell_lme_id_idx;
DROP INDEX cell_meow_id_idx;

-- Drop table if exist then create table then copy data from csv
DROP TABLE IF EXISTS geo.meow;

CREATE TABLE geo.meow (
	gid serial primary key,
	meow_id integer,
	eco_id integer,
	ecoregion character varying(70),
	prov_id integer,
	province character varying(70),
	realm_id integer,
	realm character varying(70),
	lat_zone character varying(70),
	shape_area numeric,
	geom public.geometry(MultiPolygon, 4326)
);

\copy geo.meow from 'Sau_geo_meow.csv' with (format csv, header);

--
DROP TABLE IF EXISTS master.meow;

CREATE TABLE master.meow(
  meow_id smallserial PRIMARY KEY,
  name varchar(70) NOT NULL
);

\copy master.meow from 'Sau_web_meow.csv' with (format csv, header);

-- Simple_area_cell_assignment_raw exists already. Only need to truncate and copy new data
TRUNCATE geo.simple_area_cell_assignment_raw;

\copy geo.simple_area_cell_assignment_raw from 'Sau_allocation_area_cell_assignment_raw.csv' with (format csv, header);

--cell table appears twice. geo.world and master.cell
DROP TABLE IF EXISTS geo.world;

CREATE TABLE geo.world(
   cell_id integer PRIMARY KEY,
  lon double precision,
  lat double precision,
  cell_row int,  -- "row" is a reserved word in pgplsql
  cell_col int,  -- renamed for consistency
  total_area double precision,
  water_area double precision,
  percent_water double precision,
  ele_min int,
  ele_max int,
  ele_avg int,
  elevation_min int,
  elevation_max int,
  elevation_mean int,
  bathy_min int,
  bathy_max int,
  bathy_mean int,
  fao_area_id int,
  lme_id int,
  bgcp double precision,
  distance double precision,
  coastal_prop double precision,
  shelf double precision,
  slope double precision,
  abyssal double precision,
  estuary double precision,
  mangrove double precision,
  seamount_saup double precision,
  seamount double precision,
  coral double precision,
  front double precision,
  pprod double precision,
  ice_con double precision,
  sst double precision,
  eez_count int,
  sst_2001 double precision,
  bt_2001 double precision,
  pp_10yr_avg double precision,
  sst_avg double precision,
  pp_annual double precision,
  meow_id double precision
);

\copy geo.world from 'Sau_web_cell.csv' with (format csv, header);

DROP TABLE IF EXISTS master.cell CASCADE;

CREATE TABLE master.cell (                   
  cell_id integer PRIMARY KEY,
  lon double precision,
  lat double precision,
  cell_row int,  -- "row" is a reserved word in pgplsql
  cell_col int,  -- renamed for consistency
  total_area double precision,
  water_area double precision,
  percent_water double precision,
  ele_min int,
  ele_max int,
  ele_avg int,
  elevation_min int,
  elevation_max int,
  elevation_mean int,
  bathy_min int,
  bathy_max int,
  bathy_mean int,
  fao_area_id int,
  lme_id int,
  bgcp double precision,
  distance double precision,
  coastal_prop double precision,
  shelf double precision,
  slope double precision,
  abyssal double precision,
  estuary double precision,
  mangrove double precision,
  seamount_saup double precision,
  seamount double precision,
  coral double precision,
  front double precision,
  pprod double precision,
  ice_con double precision,
  sst double precision,
  eez_count int,
  sst_2001 double precision,
  bt_2001 double precision,
  pp_10yr_avg double precision,
  sst_avg double precision,
  pp_annual double precision,
  meow_id double precision
);

\copy master.cell from 'Sau_web_cell.csv' with (format csv, header);

--
TRUNCATE master.marine_layer;

\copy master.marine_layer from 'Sau_web_marine_layer.csv' with (format csv, header);

-- Recreate dropped view
CREATE OR REPLACE VIEW geo.v_test_cell_assigned_water_area_exceeds_entire_cell_area AS 
SELECT rw.marine_layer_id,                      
       rw.area_id,
       rw.fao_area_id,
       rw.cell_id,
       rw.water_area AS this_cell_assignment_water_area,
       c.water_area AS entire_water_area_of_this_cell
  FROM (simple_area_cell_assignment_raw rw
  JOIN cell c ON ((rw.cell_id = c.cell_id)))
 WHERE ((rw.water_area > (c.water_area * (1.02)::double precision))
       -- 1.02 is used instead of 1.0 to allow some tolerance
   AND (rw.marine_layer_id <> 0)); 

-- Recreate indexes
CREATE INDEX simple_area_cell_assignment_raw_cell_id_idx ON geo.simple_area_cell_assignment_raw(cell_id);
CREATE INDEX simple_area_cell_assignment_raw_marine_layer_id_idx ON geo.simple_area_cell_assignment_raw(marine_layer_id);

CREATE INDEX cell_fao_area_id_idx ON master.cell(fao_area_id);
CREATE INDEX cell_lme_id_idx ON master.cell(lme_id);
CREATE INDEX cell_meow_id_idx ON master.cell(meow_id);

select admin.grant_access();

