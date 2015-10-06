CREATE TABLE catalog.fao_rfb_catalog(
  rfb_fid smallint primary key,
  raw_data xml,
  raw_data_hash bigint not null,
  last_modified timestamp not null default now()
);

CREATE TABLE catalog.fao_country_membership_catalog(
  country_iso3 char(3) primary key,
  raw_data xml,
  raw_data_hash bigint not null,
  last_modified timestamp not null default now()
);

CREATE TABLE catalog.fao_rfmo_membership_catalog(
  rfmo_id int not null,
  country_iso3 char(3) not null,
  country_name varchar(256) not null,
  country_facp_url text,
  last_modified timestamp not null default now()
);
