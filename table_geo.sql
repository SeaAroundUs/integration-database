CREATE TABLE geo.fao (
  gid serial primary key,
  fao_area_id int not null,
  f_level character varying(254),
  ocean character varying(254),
  sub_ocean character varying(254),
  label text,
  alternate_name varchar(50) NOT NULL,
  geom public.geometry(MultiPolygon, 4326)
);

CREATE TABLE geo.fao_simplified (
  gid serial primary key,
  fao_area_id int not null,
  geom public.geometry(MultiPolygon, 4326)
);

CREATE TABLE geo.eez (
  ogc_fid serial primary key,
  eez_id integer,
  shape_length double precision,
  shape_area double precision,
  wkb_geometry geometry(MultiPolygon, 4326)
);


CREATE TABLE geo.lme (
  gid serial primary key,
  object_id integer,
  lme_number integer,
  lme_name character varying(70),
  shape_leng numeric,
  shape_area numeric,
  profile_url varchar(255) NOT NULL,
  geom public.geometry(MultiPolygon, 4326)
);


CREATE TABLE geo.rfmo (  
  gid          serial PRIMARY KEY,
  name         character varying(15), 
  rfmo_id      int not null,
  area_km2     numeric,
  shape_length numeric,
  shape_area   numeric,
  geom         geometry(MultiPolygon, 4326) 
);


CREATE TABLE geo.ifa (
  gid        serial primary key,               
  object_id   integer,               
  eez_id      integer,               
  c_name     varchar(50), 
  a_name     varchar(50),
  a_num      integer,               
  area_km2   numeric,                                                       
  shape_leng numeric,               
  shape_area numeric,               
  ifa_is_located_in_this_fao int NULL,
  geom       geometry(MultiPolygon, 4326)
);


CREATE TABLE geo.mariculture(
  gid      integer PRIMARY KEY,
  id       integer,                     
  c_number  smallint,                    
  taxon_key integer,                   
  sub_unit  character varying(50),       
  y1965    numeric,
  y1966    numeric,
  y1967    numeric,
  y1968    numeric,
  y1969    numeric,
  y1970    numeric,
  y1971    numeric,
  y1972    numeric,
  y1973    numeric,
  y1974    numeric,
  y1975    numeric,
  y1976    numeric,
  y1977    numeric,
  y1978    numeric,
  y1979    numeric,
  y1980    numeric,
  y1981    numeric,
  y1982    numeric,
  y1983    numeric,
  y1984    numeric,
  y1985    numeric,
  y1986    numeric,
  y1987    numeric,
  y1988    numeric,
  y1989    numeric,
  y1990    numeric,
  y1991    numeric,
  y1992    numeric,
  y1993    numeric,
  y1994    numeric,
  y1995    numeric,
  y1996    numeric,
  y1997    numeric,
  y1998    numeric,
  y1999    numeric,
  y2000    numeric,                                      
  y2001    numeric,
  y2002    numeric,
  y2003    numeric,
  y2004    numeric,
  y2005    numeric,
  y2006    numeric,
  y2007    numeric,
  y1964    numeric,
  y1963    numeric,
  y1962    numeric,
  y1961    numeric,
  y1960    numeric,
  y1959    numeric,
  y1958    numeric,
  y1957    numeric,
  y1956    numeric,
  y1955    numeric,
  y1954    numeric,
  y1953    numeric,
  y1952    numeric,
  y1951    numeric,
  y1950    numeric,
  y2008    numeric,
  geom     geometry(MultiPolygon,4326) 
); 

CREATE TABLE geo.mariculture_points (
  gid serial primary key,
  object_id integer,
  c_number double precision,
  taxon_key integer,
  sub_unit character varying(254),
  long double precision,
  lat double precision,
  f2010 double precision,            
  f2009 double precision,
  f2008 double precision,
  f2007 double precision,
  f2006 double precision,
  f2005 double precision,
  f2004 double precision,
  f2003 double precision,
  f2002 double precision,
  f2001 double precision,
  f2000 double precision,
  f1999 double precision,
  f1998 double precision,
  f1997 double precision,
  f1996 double precision,
  f1995 double precision,
  f1994 double precision,
  f1993 double precision,
  f1992 double precision,
  f1991 double precision,
  f1990 double precision,
  f1989 double precision,
  f1988 double precision,
  f1987 double precision,
  f1986 double precision,
  f1985 double precision,
  f1984 double precision,
  f1983 double precision,
  f1982 double precision,
  f1981 double precision,
  f1980 double precision,
  f1979 double precision,
  f1978 double precision,
  f1977 double precision,
  f1976 double precision,
  f1975 double precision,
  f1974 double precision,
  f1973 double precision,
  f1972 double precision,
  f1971 double precision,
  f1970 double precision,
  f1969 double precision,
  f1968 double precision,
  f1967 double precision,
  f1966 double precision,
  f1965 double precision,
  f1964 double precision,
  f1963 double precision,
  f1962 double precision,
  f1961 double precision,
  f1960 double precision,
  f1959 double precision,
  f1958 double precision,
  f1957 double precision,
  f1956 double precision,
  f1955 double precision,
  f1954 double precision,
  f1953 double precision,
  f1952 double precision,
  f1951 double precision,
  f1950 double precision,
  eez_id integer, 
  eez_name character varying(254), 
  entity_id smallint, 
  sub_entity_id smallint,
  geom public.geometry(Point,4326)
);


CREATE TABLE geo.mariculture_entity (
  gid serial primary key,
  object_id integer,
  join_count integer,
  target_fid integer,
  join_fid integer,
  eez_id smallint,
  sub_unit character varying(50),
  taxon_key numeric,
  sub_unit_1 character varying(254),
  f2010 numeric,
  f2009 numeric,
  f2008 numeric,
  f2007 numeric,
  f2006 numeric,
  f2005 numeric,
  f2004 numeric,
  f2003 numeric,
  f2002 numeric,
  f2001 numeric,
  f2000 numeric,
  f1999 numeric,
  f1998 numeric,
  f1997 numeric,
  f1996 numeric,
  f1995 numeric,
  f1994 numeric,
  f1993 numeric,
  f1992 numeric,
  f1991 numeric,
  f1990 numeric,
  f1989 numeric,
  f1988 numeric,
  f1987 numeric,
  f1986 numeric,
  f1985 numeric,
  f1984 numeric,
  f1983 numeric,
  f1982 numeric,
  f1981 numeric,
  f1980 numeric,
  f1979 numeric,
  f1978 numeric,
  f1977 numeric,
  f1976 numeric,
  f1975 numeric,
  f1974 numeric,
  f1973 numeric,
  f1972 numeric,
  f1971 numeric,
  f1970 numeric,
  f1969 numeric,
  f1968 numeric,
  f1967 numeric,
  f1966 numeric,
  f1965 numeric,
  f1964 numeric,
  f1963 numeric,
  f1962 numeric,
  f1961 numeric,
  f1960 numeric,
  f1959 numeric,
  f1958 numeric,
  f1957 numeric,
  f1956 numeric,
  f1955 numeric,
  f1954 numeric,
  f1953 numeric,
  f1952 numeric,
  f1951 numeric,
  f1950 numeric,
  shape_leng numeric,
  shape_area numeric,
  geom public.geometry(MultiPolygon,4326)
);     
        
CREATE TABLE geo.big_cell(
  big_cell_id SERIAL PRIMARY KEY,
  big_cell_type_id int NOT NULL,
  x float NOT NULL,
  y float NOT NULL,
  is_land_locked boolean NOT NULL DEFAULT false,
  is_in_med boolean nOT NULL DEFAULT false,
  is_in_pacific boolean NOT NULL DEFAULT false,
  is_in_indian boolean NOT NULL DEFAULT false
);

CREATE TABLE geo.big_cell_type(
  big_cell_type_id int NOT NULL,
  type_desc varchar(255) NOT NULL
);

CREATE TABLE geo.cell(
  cell_id int PRIMARY KEY,
  total_area float NOT NULL,
  water_area float NOT NULL
);

CREATE TABLE geo.cell_is_coastal(
  cell_id int PRIMARY KEY
);                 

CREATE TABLE geo.depth_adjustment_row_cell(
  local_depth_adjustment_row_id int NOT NULL,
  eez_id int NOT NULL,
  cell_id int NOT NULL,
  CONSTRAINT depth_adjustment_row_cell_pkey PRIMARY KEY(local_depth_adjustment_row_id, eez_id, cell_id)
);

CREATE TABLE geo.eez_big_cell_combo(
  eez_big_cell_combo_id int PRIMARY KEY,
  eez_id int NOT NULL,
  fao_area_id int NOT NULL,
  big_cell_id int NOT NULL,
  is_ifa boolean NOT NULL DEFAULT false    
);                                  

CREATE TABLE geo.eez_ccamlr_combo(
  eez_ccamlar_combo_id int PRIMARY KEY,
  eez_id int NOT NULL,
  fao_area_id smallint NOT NULL,
  ccamlr_area_id varchar(50) NOT NULL,
  is_ifa boolean NOT NULL DEFAULT false 
);

CREATE TABLE geo.eez_fao_combo(
  eez_fao_area_id SERIAL PRIMARY KEY,
  reconstruction_eez_id int NOT NULL,
  fao_area_id int NOT NULL
);

CREATE TABLE geo.eez_ices_combo(
  eez_ices_combo_id int PRIMARY KEY,
  eez_id int NOT NULL,
  fao_area_id smallint NOT NULL,
  ices_area_id varchar(50) NOT NULL,
  is_ifa boolean NOT NULL DEFAULT false
);

CREATE TABLE geo.eez_nafo_combo(
  eez_nafo_combo_id int PRIMARY KEY,             
  eez_id int NOT NULL,
  fao_area_id smallint NOT NULL,
  nafo_division varchar(50) NOT NULL,
  is_ifa boolean NOT NULL DEFAULT false
);

CREATE TABLE geo.fao_cell(
  fao_area_id smallint NOT NULL,
  cell_id int NOT NULL
);

CREATE TABLE geo.fao_map(
  fao_area_id smallint PRIMARY KEY,
  upper_left_cell_cell_id int NOT NULL,
  scale smallint NOT NULL DEFAULT 10
);

CREATE TABLE geo.ices_area(
  ices_division varchar(255) NULL,
  ices_subdivision varchar(255) NULL,
  ices_area_id varchar(255) NOT NULL
);
                  
CREATE TABLE geo.simple_area_cell_assignment_raw(
  id SERIAL PRIMARY KEY,
  marine_layer_id smallint NULL,
  area_id smallint NULL,
  fao_area_id smallint NULL,
  cell_id int NULL,
  water_area float NULL,
  CONSTRAINT simple_area_cell_assignment_raw_uk UNIQUE (marine_layer_id, area_id, fao_area_Id, cell_id)
);

CREATE TABLE geo.world(
  cell_id int PRIMARY KEY,
  lon float NOT NULL,
  lat float NOT NULL,
  row int NOT NULL,
  col int NOT NULL,
  t_area float NOT NULL,
  water_area float NOT NULL,
  p_water float,
  ele_min float,
  ele_max float,
  ele_avg float,
  elevation_min float,
  elevation_max float,
  elevation_mean float,
  bathy_min float,
  bathy_max float,
  bathy_mean float,
  bgcp float,
  distance float,
  coastal_prop float,
  shelf float,
  slope float,
  abyssal float,
  estuary float,
  mangrove varchar(255),
  seamount_saup float,
  seamount float,
  coral float,
  p_prod float,
  ice_con float,
  sst float,
  eez_count float,
  sst_2001 float,
  bt_2001 float,
  pp_10_yr_avg float,
  sst_avg float,
  pp_annual varchar(255)
);

CREATE TABLE geo.worldsq(
  gid serial primary key,
  seq integer unique, 
  lat numeric not null,
  lon numeric not null, 
  geom geometry(MultiPolygon,4326) not null
);

CREATE TABLE geo.ifa_fao(
  eez_id int,
  ifa_is_located_in_this_fao int
);
