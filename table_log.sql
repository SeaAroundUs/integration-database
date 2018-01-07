CREATE TABLE log.table_edits(
  id serial primary key,
  auth_user_id int not null,
  table_name varchar(256),
  notes text,
  created timestamp not null default now()
);

CREATE TABLE log.adhoc_query(
  id serial primary key,
  description text not null,
  query text not null,
  requested_by varchar(100) not null,
  notes text,
  estimated_duration interval,
  is_active boolean not null default true,
  is_allocated boolean not null default false,
  created_by_auth_user_id int not null,
  reviewed_by_auth_user_id int,
  grantee_auth_user_id int[],
  last_executed_by_auth_user_id int,
  last_executed timestamp,
  created timestamp not null default now(),
  last_modified timestamp
);

-- Not to be confused with the taxon substitution table, which is used only by allocation for distribution purposes
-- This table here is to keep track of taxon keys that has been superseeded by a new key
CREATE TABLE log.taxon_replacement(
  old_taxon_key int not null,	
  new_taxon_key int,	
  taxon_name text,
  type text,
  phylum_subphylum text,	
  class_subclass text,
  superorder_order_suborder	text,
  genus text,
  species text,
  comments_names text,
  replaced_timestamp timestamp
);

CREATE TABLE log.taxon_catalog(
  taxon_key int PRIMARY KEY,
  taxon_name varchar(255) NOT NULL,
  common_name varchar(255),
  type varchar(255),
  comments_names text,
  is_retired boolean not null default false,
  taxon_group_id int,
  taxon_level_id int,
  functional_group_id int NOT NULL,
  commercial_group_id int NOT NULL,
  commercial varchar(255),
  isscaap_id varchar(255),
  cell_id varchar(255),
  super_target varchar(255),
  fb_spec_code varchar(255),
  slb_spec_code varchar(255),  
  cla_code varchar(255),
  ord_code varchar(255),
  fam_code varchar(255),
  gen_code varchar(255),
  spe_code varchar(255),
  slb_cla_code varchar(255),
  slb_ord_code varchar(255),
  slb_fam_code varchar(255),
  SLB_Gen_Code varchar(255),
  phylum varchar(255),
  subphylum varchar(255),
  Superclass varchar(255),
  Class varchar(255),
  SuperOrder varchar(255),
  "order" varchar(255),
  SubOrder_Infraorder varchar(255),
  Family varchar(255),
  Genus varchar(255),
  Species varchar(255),
  lineage ltree
);
