/* Stable master tables, no tracking log tables needed */
CREATE TABLE master.time(
  time_key int PRIMARY KEY,
  year int NOT NULL
);

CREATE TABLE master.marine_layer(
  marine_layer_id serial PRIMARY KEY,
  remarks varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  bread_crumb_name varchar(50) NOT NULL,
  show_sub_areas boolean DEFAULT false NOT NULL,
  last_report_year int NOT NULL
);

CREATE TABLE master.catch_type(
  catch_type_id smallint primary key,
  name varchar(50) not null                        
);

CREATE TABLE master.sector_type(
  sector_type_id smallint primary key,
  name varchar(50) not null
);

CREATE TABLE master.taxon_level(
  taxon_level_id int PRIMARY KEY,
  name VARCHAR(100),
  description TEXT
);

CREATE TABLE master.taxon_group(
  taxon_group_id int PRIMARY KEY,
  name VARCHAR(100),
  description TEXT
);

CREATE TABLE master.fao_area(
  fao_area_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  alternate_name varchar(50) NOT NULL
);

CREATE TABLE master.lme(
  lme_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  profile_url varchar(255) DEFAULT 'http://www.lme.noaa.gov/' NOT NULL
);

CREATE TABLE master.rfmo(
  rfmo_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  long_name varchar(255) NOT NULL,
  profile_url varchar(255) NULL
);

/* Master tables that need to have corresponding log tables to track changes */
CREATE TABLE master.taxon(
  taxon_key int PRIMARY KEY,
  scientific_name varchar(255) NOT NULL,
  common_name varchar(255) NOT NULL,
  commercial_group_id smallint NOT NULL,
  functional_group_id smallint NOT NULL,
  sl_max int NOT NULL,
  tl decimal(50,20) NOT NULL,
  taxon_level_id int NULL,
  taxon_group_id int NULL,
  isscaap_id int NULL,
  lat_north int NULL,
  lat_south int NULL,
  min_depth int NULL,
  max_depth int NULL,
  loo decimal(50,20) NULL,
  woo decimal(50,20) NULL,
  k decimal(50,20) NULL,
  x_min int NULL,
  x_max int NULL,
  y_min int NULL,
  y_max int NULL,
  has_habitat_index boolean NOT NULL,
  has_map boolean NOT NULL,
  is_baltic_only boolean NOT NULL
);


CREATE TABLE master.eez(
  eez_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  alternate_name varchar(500) NULL,
  geo_entity_id int NOT NULL,
  area_status_id int DEFAULT 2 NOT NULL,
  legacy_c_number int NOT NULL,
  legacy_count_code varchar(4) NOT NULL,
  fishbase_id varchar(4) NOT NULL,
  coords varchar(400) NULL,
  can_be_displayed_on_web boolean DEFAULT true NOT NULL,
  is_currently_used_for_web boolean DEFAULT false NOT NULL,
  is_currently_used_for_reconstruction boolean DEFAULT false NOT NULL,
  declaration_year int DEFAULT 1982 NOT NULL,
  earliest_access_agreement_date int NULL,
  is_home_eez_of_fishing_entity_id smallint NOT NULL,
  allows_coastal_fishing_for_layer2_data boolean DEFAULT true NOT NULL,
  ohi_link VARCHAR(400)
);

COMMENT ON COLUMN master.eez.alternate_name IS 'semicolon separated: alt_name1;alt_name2;alt_name3';
COMMENT ON COLUMN master.eez.coords IS 'coords of the map on this page: http://www.seaaroundus.org/eez/';

CREATE SEQUENCE master.fishing_entity_fishing_entity_id_seq START 1 MAXVALUE 32767;

CREATE TABLE master.fishing_entity(
  fishing_entity_id smallint DEFAULT nextval('master.fishing_entity_fishing_entity_id_seq') PRIMARY KEY,
  name varchar(100) NOT NULL,
  geo_entity_id int NULL,
  date_allowed_to_fish_other_eEZs int NOT NULL,
  date_allowed_to_fish_high_seas int NOT NULL,
  legacy_c_number int NULL,
  is_currently_used_for_web boolean DEFAULT true NOT NULL,
  is_currently_used_for_reconstruction boolean DEFAULT true NOT NULL,
  remarks varchar(50) NULL
);

ALTER SEQUENCE master.fishing_entity_fishing_entity_id_seq OWNED BY master.fishing_entity.fishing_entity_iD;

CREATE TABLE master.functional_groups(
  functional_group_id smallint PRIMARY KEY,
  target_grp int NULL,
  name varchar(20) NULL,
  description varchar(50) NULL
);

CREATE TABLE master.gear(
  gear_id smallint PRIMARY KEY,
  name varchar(50) NOT NULL,
  super_code varchar(20) NOT NULL                              
);

CREATE TABLE master.geo_entity(
  geo_entity_id int PRIMARY KEY,      
  name varchar(50) NOT NULL,
  admin_geo_entity_id int NOT NULL,             
  jurisdiction_id int NULL,
  started_eez_at varchar(50) NULL,
  Legacy_c_number int NOT NULL,
  legacy_admin_c_number int NOT NULL
);

CREATE TABLE master.sub_geo_entity(
  sub_geo_entity_id serial PRIMARY KEY,
  c_number int NOT NULL,
  name varchar(255) NOT NULL,
  geo_entity_id int NOT NULL
);

CREATE TABLE master.mariculture_entity(
  mariculture_entity_id serial PRIMARY KEY,
  name varchar(50) NOT NULL,
  legacy_c_number int NOT NULL,
  fao_link varchar(255) NULL
);

CREATE TABLE master.mariculture_sub_entity(
  mariculture_sub_entity_id serial PRIMARY KEY,
  name varchar(100) NOT NULL,
  mariculture_entity_id int NOT NULL
);

CREATE TABLE master.habitat_index(
  taxon_key serial PRIMARY KEY,
  taxon_name varchar(50) NULL,
  common_name varchar(50) NULL,
  sl_max int NULL,
  habitat_diversity_index decimal(50,20) NULL,
  effective_d decimal(50,20) NULL,
  estuaries decimal(50,20) NULL,
  coral decimal(50,20) NULL,
  seagrass decimal(50,20) NULL,
  seamount decimal(50,20) NULL,
  others decimal(50,20) NULL,
  shelf decimal(50,20) NULL,
  slope decimal(50,20) NULL,
  abyssal decimal(50,20) NULL,
  inshore decimal(50,20) NULL,
  offshore decimal(50,20) NULL,
  offshore_back decimal(50,20) NULL
);

CREATE TABLE master.cell (
    cell_id integer PRIMARY KEY,
    lon double precision,
    lat double precision,
    cell_row int,  -- "row" is a reserved word in pgplsql
    cell_col int,  -- renamed for consistency
    t_area double precision,
    area double precision,
    p_water double precision,
    p_land double precision,
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
    pprod double precision,
    ice_con double precision,
    sst double precision,
    eez_count int,
    sst_2001 double precision,
    bt_2001 double precision,
    pp_10yr_avg double precision,
    sst_avg double precision,
    pp_annual double precision
);
