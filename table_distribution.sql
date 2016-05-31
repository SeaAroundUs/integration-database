CREATE TABLE distribution.taxon_extent (
    gid serial primary key,
    taxon_key integer not null,
    is_extended boolean not null default false,
    is_rolled_up boolean not null default false,
    geom geometry(Multipolygon, 4326) not null,
    is_reversed_engineered boolean not null default false
);

CREATE TABLE distribution.taxon_distribution (
    taxon_distribution_id serial primary key,
    taxon_key integer not null,
    cell_id integer not null,
    relative_abundance double precision not null,
    is_backfilled boolean not null default false
);

CREATE TABLE distribution.taxon_distribution_log (
    taxon_key integer primary key,
    modified_timestamp timestamp not null default now()
);

CREATE TABLE distribution.taxon_distribution_substitute(
  original_taxon_key int primary key,
  use_this_taxon_key_instead int not null,
  is_manual_override boolean not null default false
);

CREATE TABLE distribution.grid (
    id serial primary key,
    "row" integer,
    col integer,
    geom geometry(MultiPolygon,4326)
);

CREATE TABLE distribution.taxon_habitat (
    taxon_key int primary key,
    taxon_name character varying(255),
    common_name character varying(255),
    cla_code integer,
    ord_code integer,
    fam_code integer,
    gen_code integer,
    spe_code integer,
    effective_distance double precision,
    habitat_diversity_index double precision,
    estuaries double precision,
    coral double precision,
    sea_grass double precision,
    sea_mount double precision,
    others double precision,
    slope double precision,
    shelf double precision,
    abyssal double precision,
    inshore double precision,
    offshore double precision,
    max_depth integer,
    min_depth integer,
    lat_north integer,
    lat_south integer,
    found_in_fao_area_id int[],
    fao_limits smallint,
    sl_max double precision,
    intertidal boolean,
    temperature double precision
);

/* And here we create the dependent habitat_index view in the 'master' schema */
CREATE OR REPLACE VIEW master.habitat_index AS
SELECT taxon_key,
       taxon_name,
       common_name,
       sl_max,
       cla_code,
       ord_code,
       fam_code,
       gen_code,
       spe_code,
       habitat_diversity_index,
       effective_distance as effective_d,
       estuaries,
       coral,
       sea_grass as seagrass,
       sea_mount as seamount,
       others,
       shelf,
       slope,
       abyssal,
       inshore,
       offshore,
       temperature
  FROM distribution.taxon_habitat;

CREATE TABLE distribution.taxon_extent_rollup(
    taxon_key int primary key,
    children_distributions_found int,
    children_taxon_keys int[],
    last_modified timestamp not null default current_timestamp
);

CREATE UNLOGGED TABLE distribution.taxon_extent_rollup_polygon(
    taxon_key int,
    seq int,
    geom geometry(Polygon, 4326)
);
