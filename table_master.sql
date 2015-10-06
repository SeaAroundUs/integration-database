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

CREATE TABLE master.country(
  c_number int PRIMARY KEY,
  count_code varchar(4) NOT NULL,
  un_name varchar(10) NULL,
  admin varchar(4) NULL,
  fish_base varchar(4) NULL,
  a_code varchar(4) NULL,
  cia varchar(2) NULL,
  fao_fisheries varchar(4) NULL,
  country varchar(50) NULL,
  eez_area decimal(50,20) NULL,
  sea_mount decimal(50,20) NULL,
  per_sea_mount decimal(50,20) NULL,
  area_reef decimal(50,20) NULL,
  per_reef decimal(50,20) NULL,
  shelf_area decimal(50,20) NULL,
  avg_pprate decimal(50,20) NULL,
  eez_ppr bigint NULL,
  has_estuary smallint NULL,
  has_mpa smallint NULL,
  has_survey smallint NULL,
  territory smallint NULL,
  has_saup_profile smallint NULL,
  fao_profile_url_direct_link varchar(100) NULL,
  is_active boolean NOT NULL,
  fao_profile_url_v1 varchar(255) NULL,
  fao_profile_url varchar(255) NULL,
  fao_code varchar(50) NULL,
  admin_c_number int NULL
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

CREATE TABLE master.commercial_groups(
  commercial_group_id smallint PRIMARY KEY,
  name varchar(100) NOT NULL
);

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

CREATE TABLE master.jurisdiction(
  jurisdiction_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  legacy_c_number int NOT NULL
);

CREATE TABLE master.geo_entity(
  geo_entity_id int PRIMARY KEY,      
  name varchar(50) NOT NULL,
  admin_geo_entity_id int NOT NULL,             
  jurisdiction_id int NULL,
  started_eez_at varchar(50) NULL,
  legacy_c_number int NOT NULL,
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

CREATE TABLE master.input_type(
  input_type_id smallint primary key,
  name text
);

CREATE TABLE master.access_type(
  id INT PRIMARY KEY,
  description TEXT
);

CREATE TABLE master.agreement_type(
  id INT PRIMARY KEY,
  description TEXT
);

CREATE TABLE master.access_agreement(
  id integer primary key,  
  fishing_entity_id int not null,
  fishing_entity varchar(255),
  eez_id int not null,
  eez_name varchar(255),
  title_of_agreement varchar(255),
  access_category varchar(255) not null,
  access_type_id int not null,
  agreement_type_id int not null,
  start_year int not null,
  end_year int not null,
  duration_type varchar(255),
  duration_details varchar(255),
  functional_group_id varchar(255),
  functional_group_details varchar(255),
  fees varchar(255),
  quotas varchar(255),
  other_restrictions varchar(255),
  notes_on_agreement text,
  ref_id int,
  source_link varchar(255),
  pdf varchar(255),
  verified varchar(255),
  reference_original varchar(255),
  location_reference_original varchar(255),
  reference varchar(255),
  title_of_reference varchar(255),
  location_reference varchar(255),
  reference_type varchar(255),
  pages varchar(255),
  number_of_boats varchar(255),
  gear varchar(255),
  notes_on_the_references text,
  change_log text
);

CREATE TABLE master.fao_rfb(
  fid smallint primary key,
  acronym varchar(20) not null unique,
  name text,
  profile_url text,
  raw_data_hash bigint not null,
  figis_raw_data_hash bigint,
  modified_timestamp timestamp not null default now()
);

CREATE TABLE master.fao_country_rfb_membership(
  id serial primary key,
  country_iso3 char(3) not null,
  rfb_fid smallint not null,
  membership_type varchar(100) not null,
  modified_timestamp timestamp not null default now(),
  CONSTRAINT fao_country_rfb_membership_uk UNIQUE(country_iso3, rfb_fid, membership_type)
);

CREATE TABLE master.fao_country_rfmo_membership(
  id serial primary key,
  rfmo_id int not null,
  country_iso3 char(3) not null,
  country_name varchar(256) not null,
  country_facp_url text,
  modified_timestamp timestamp not null default now(),
  CONSTRAINT fao_country_rfmo_membership_uk UNIQUE(rfmo_id, country_iso3)
);
