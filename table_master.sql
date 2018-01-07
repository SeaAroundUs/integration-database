/* Stable master tables, no tracking log tables needed */
CREATE TABLE master.time(
  time_key smallserial PRIMARY KEY,
  year int NOT NULL,
  is_used_for_allocation BOOLEAN NOT NULL DEFAULT TRUE,
  is_used_for_web BOOLEAN NOT NULL DEFAULT TRUE
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
  name varchar(50) not null,
  abbreviation char(1) not null
);

CREATE TABLE master.reporting_status(
  reporting_status_id smallint primary key,
  name varchar(50) not null,                        
  abbreviation char(1) not null
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
  fao_area_id smallserial PRIMARY KEY,
  name varchar(50) NOT NULL,
  alternate_name varchar(50) NOT NULL
);

CREATE TABLE master.high_seas(
  fao_area_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  alternate_name varchar(50)
);

CREATE TABLE master.lme(
  lme_id smallserial PRIMARY KEY,
  name varchar(50) NOT NULL,
  profile_url varchar(255) DEFAULT 'http://www.lme.noaa.gov/' NOT NULL
);

CREATE TABLE master.meow(
	meow_id int PRIMARY KEY,
	name varchar(70) NOT NULL,
	profile_url varchar(255) DEFAULT 'https://www.worldwildlife.org/publications/marine-ecoregions-of-the-world-a-bioregionalization-of-coastal-and-shelf-areas' NOT NULL
);	

CREATE TABLE master.rfmo(
  rfmo_id smallserial PRIMARY KEY,
  name varchar(50) NOT NULL,
  long_name varchar(255) NOT NULL,
  profile_url varchar(255)
);

CREATE TABLE master.rfmo_managed_taxon(
  rfmo_id int PRIMARY KEY,
  primary_taxon_keys int[],
  secondary_taxon_keys int[],
  taxon_check_required boolean default true,
  modified timestamp NOT NULL DEFAULT now()
);

CREATE TABLE master.rfmo_procedure_and_outcome (
    rfmo_id integer PRIMARY KEY,
    name character varying(50) NOT NULL,
    contracting_parties text NOT NULL,
    area text NOT NULL,
    date_entered_into_force integer,
    fao_association boolean NOT NULL,
    fao_statistical_area character varying(50),
    objectives text NOT NULL,
    primary_species text NOT NULL,
    content text NOT NULL
);

CREATE TABLE master.isscaap(
  isscaap_id int PRIMARY KEY,
  name varchar(255),
  is_excluded_group BOOLEAN DEFAULT FALSE
);

/* Master tables that need to have corresponding log tables to track changes */
CREATE TABLE master.taxon(
  taxon_key int PRIMARY KEY,
  scientific_name varchar(255) NOT NULL,
  common_name varchar(255) NOT NULL,
  phylum varchar(255),
  sub_phylum varchar(255),
  super_class varchar(255),
  class varchar(255),
  super_order varchar(255),
  "order" varchar(255),
  suborder_infraorder varchar(255),
  family varchar(255),
  genus varchar(255),
  species varchar(255),
  comments_names text,
  is_retired boolean not null default false,
  taxon_group_id int,
  taxon_level_id int,
  functional_group_id smallint NOT NULL,
  commercial_group_id smallint NOT NULL,
  commercial smallint,
  isscaap_id int,
  cell_id int,
  super_target smallint,
  fb_spec_code int,
  slb_spec_code int,  
  cla_code int,
  ord_code int,
  fam_code int,
  gen_code int,
  spe_code int,
  slb_cla_code int,
  slb_ord_code int,
  slb_fam_code int,
  slb_gen_code int,
  is_use boolean,
  is_taxa_used boolean,
  is_mariculture_only boolean,
  is_baltic_only boolean NOT NULL,
  sl_max float,
  slbl_max_type varchar(10),	  
  sl_max_2 float,
  comments_sl_max text,
  tl float,
  se_tl float,
  comments_tl text,
  lat_north int,
  lat_south int,                                        
  min_depth int,
  max_depth int,
  loo float,
  woo float,
  k float,
  a float,
  b float,
  comments_growth text,
  has_habitat_index boolean NOT NULL,
  has_map boolean NOT NULL,
  map_year smallint,
  vulnerability	text,
  resilience text,
  updated_by varchar(255),
  date_updated date,
  lineage ltree
);

CREATE TABLE master.rare_taxon(
  taxon_key int PRIMARY KEY,
  scientific_name varchar(255) NOT NULL,
  common_name varchar(255) NOT NULL,
  created_timestamp TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE master.layer3_taxon(
  taxon_key int PRIMARY KEY,
  scientific_name varchar(255) NOT NULL,
  common_name varchar(255) NOT NULL,
  created_timestamp TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE master.excluded_taxon(
  taxon_key int PRIMARY KEY,
  scientific_name varchar(255) NOT NULL,
  common_name varchar(255) NOT NULL,
  created_timestamp TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE master.country(
  c_number int PRIMARY KEY,
  count_code varchar(4) NOT NULL,
  un_name varchar(10),
  admin varchar(4),
  fish_base varchar(4),
  a_code varchar(4),
  cia varchar(2),
  fao_fisheries varchar(4),
  country varchar(50),
  eez_area decimal(50,20),
  sea_mount decimal(50,20),
  per_sea_mount decimal(50,20),
  area_reef decimal(50,20),
  per_reef decimal(50,20),
  shelf_area decimal(50,20),
  avg_pprate decimal(50,20),
  eez_ppr bigint,
  has_estuary smallint,
  has_mpa smallint,
  has_survey smallint,
  territory smallint,
  has_saup_profile smallint,
  fao_profile_url_direct_link varchar(100),
  is_active boolean NOT NULL,
  fao_profile_url_v1 varchar(255),
  fao_profile_url varchar(255),
  fao_code varchar(50),
  admin_c_number int
);

CREATE TABLE master.eez(
  eez_id int PRIMARY KEY,
  name varchar(50) NOT NULL,
  alternate_name varchar(500),
  geo_entity_id int NOT NULL,
  area_status_id int DEFAULT 2 NOT NULL,
  legacy_c_number int NOT NULL,
  legacy_count_code varchar(4) NOT NULL,
  fishbase_id varchar(4) NOT NULL,
  coords varchar(400),
  can_be_displayed_on_web boolean DEFAULT true NOT NULL,
  is_currently_used_for_web boolean DEFAULT false NOT NULL,
  is_currently_used_for_reconstruction boolean DEFAULT false NOT NULL,
  declaration_year int DEFAULT 1982 NOT NULL,
  earliest_access_agreement_date int,
  is_home_eez_of_fishing_entity_id smallint NOT NULL,
  allows_coastal_fishing_for_layer2_data boolean DEFAULT true NOT NULL,
  ohi_link VARCHAR(400),
  is_retired BOOLEAN NOT NULL DEFAULT false,
  gsi_link VARCHAR(400),
  issf_link VARCHAR(400)
);

COMMENT ON COLUMN master.eez.alternate_name IS 'semicolon separated: alt_name1;alt_name2;alt_name3';
COMMENT ON COLUMN master.eez.coords IS 'coords of the map on this page: http://www.seaaroundus.org/eez/';

CREATE TABLE master.fishing_entity(
  fishing_entity_id smallserial PRIMARY KEY,
  name varchar(100) NOT NULL,
  geo_entity_id int,
  date_allowed_to_fish_other_eEZs int NOT NULL,
  date_allowed_to_fish_high_seas int NOT NULL,
  legacy_c_number int,
  is_currently_used_for_web boolean DEFAULT true NOT NULL,
  is_currently_used_for_reconstruction boolean DEFAULT true NOT NULL,
  is_allowed_to_fish_pre_eez_by_default boolean DEFAULT true NOT NULL,
  remarks varchar(50)
);

CREATE TABLE master.commercial_groups(
  commercial_group_id smallint PRIMARY KEY,
  name varchar(100) NOT NULL
);

CREATE TABLE master.functional_groups(
  functional_group_id smallint PRIMARY KEY,
  target_grp int,
  name varchar(20),
  description varchar(50),
  include_in_depth_adjustment_function BOOLEAN NOT NULL,
  size_range numrange,
  fgi_block int[]
);

CREATE TABLE master.gear(
  gear_id smallint PRIMARY KEY,
  name varchar(50) NOT NULL,
  super_code varchar(20) NOT NULL                              
);

CREATE TABLE master.jurisdiction(
  jurisdiction_id smallserial PRIMARY KEY,
  name varchar(50) NOT NULL,
  legacy_c_number int NOT NULL
);

CREATE TABLE master.geo_entity(
  geo_entity_id smallserial PRIMARY KEY,      
  name varchar(50) NOT NULL,
  admin_geo_entity_id int NOT NULL,             
  jurisdiction_id int,
  started_eez_at varchar(50),
  legacy_c_number int NOT NULL,
  legacy_admin_c_number int NOT NULL,
  continent_code CHAR(2)
);

CREATE TABLE master.sub_geo_entity(
  sub_geo_entity_id smallserial PRIMARY KEY,
  c_number int NOT NULL,
  name varchar(255) NOT NULL,
  geo_entity_id int NOT NULL
);

CREATE TABLE master.mariculture_entity(
  mariculture_entity_id smallserial PRIMARY KEY,
  name varchar(50) NOT NULL,
  legacy_c_number int NOT NULL,
  fao_link varchar(255)
);

CREATE TABLE master.mariculture_sub_entity(
  mariculture_sub_entity_id smallserial PRIMARY KEY,
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
  id smallserial primary key,  
  fishing_entity_id int not null CHECK(fishing_entity_id > 0 AND fishing_entity_id != 213),
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
  source_link text,
  pdf varchar(255),
  correct_pdf varchar(255),
  verified varchar(255),
  farisis_cd_agreement varchar(255),
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
  change_log text,
  checked_by_vl varchar(255),
  status_of_the_records varchar(255),
  old_id int,
  old_source_id int,
  old_c_number int,
  old_area_code varchar(255),
  old_start_year int,
  old_end_year int,
  old_target_grp_sum bigint,
  old_ref_id varchar(255),
  old_source varchar(255),
  old_assumed_end boolean,
  old_use boolean,
  old_reason_not_used varchar(255)
);

CREATE TABLE master.country_fishery_profile(
  profile_id serial PRIMARY KEY,
  c_number int NULL,
  count_code varchar(4) NOT NULL,
  country_name varchar(50) NULL,
  fish_mgt_plan text NULL,
  url_fish_mgt_plan text NULL,
  gov_marine_fish text NULL,
  major_law_plan text NULL,
  url_major_law_plan text NULL,
  gov_protect_marine_env text NULL,
  url_gov_protect_marine_env text NULL
);

CREATE TABLE master.price(
	year int not null,
	fishing_entity_id int not null,
	taxon_key int not null,
	price float not null,
    CONSTRAINT price_pkey PRIMARY KEY (year, fishing_entity_id, taxon_key)
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

CREATE TABLE master.data_layer
(
    data_layer_id SMALLINT PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE master.uncertainty_time_period(
  period_id smallint primary key,
  begin_year smallint,
  end_year smallint
);

CREATE TABLE master.uncertainty_score(
  score_id smallint primary key,
  score_name varchar(30),
  tolerance smallint,
  ipcc_criteria text
);

CREATE TABLE master.uncertainty_eez(
	row_id serial primary key,
    eez_id int not null,
    eez_name text,
    sector_type_id smallint,
    sector text,
    period_id smallint,
    score_id smallint,
    CONSTRAINT uncertainty_eez_uk UNIQUE (eez_id, sector_type_id, period_id)
);

CREATE TABLE master.area_invisible(
  area_invisible_id serial PRIMARY KEY,
  marine_layer_id int NOT NULL,
  main_area_id int NOT NULL,
  sub_area_id int NOT NULL DEFAULT 0
);

CREATE TABLE master.continent(
  code char(2) primary key,
  name varchar(128) not null,
  geo_name_id int not null        
);
