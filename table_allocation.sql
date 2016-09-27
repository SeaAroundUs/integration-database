CREATE TABLE allocation.ices_area(  
  ices_division varchar(255),
  ices_subdivision varchar(255),
  ices_area_id varchar(255) not null  
);

CREATE TABLE allocation.allocation_area_type (
  allocation_area_type_id smallint DEFAULT 0 PRIMARY KEY,
  name character varying(50) NOT NULL,
  remarks character varying(255) NOT NULL
);

CREATE TABLE allocation.layer (
  layer_id smallint DEFAULT 0 PRIMARY KEY,
  name character varying(255) NOT NULL
);

CREATE TABLE allocation.catch_by_taxon(
  taxon_key integer primary key,
  total_catch numeric,
  total_value double precision
);

CREATE TABLE allocation.taxon_distribution_old (
  taxon_key integer NOT NULL,
  cell_id integer NOT NULL,
  relative_abundance integer NOT NULL,
  taxon_distribution_id serial PRIMARY KEY
);

CREATE TABLE allocation.log_import_raw(
  row_id int NOT NULL primary key,
  table_name varchar(50) NOT NULL,
  data_row_id int NOT NULL,
  original_row_id int NOT NULL,
  log_time timestamp NOT NULL,
  message text NOT NULL
);
