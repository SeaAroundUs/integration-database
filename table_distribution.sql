CREATE TABLE distribution.taxon_extent (
    gid integer primary key,
    taxon_key integer,
    num_polygon integer,
    id integer,
    geom geometry(Multipolygon, 4326)
);

CREATE TABLE distribution.taxon_distribution (
    taxon_distribution_id serial primary key,
    taxon_key integer not null,
    cell_id integer not null,
    relative_abundance double precision not null 
);

CREATE TABLE distribution.taxon_distribution_log (
    taxon_key integer primary key,
    modified_timestamp timestamp not null default now()
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
    habitat_diversity_index double precision,
    effective_distance double precision,
    estuaries double precision,
    coral double precision,
    sea_grass double precision,
    sea_mount double precision,
    others double precision,
    shelf double precision,
    slope double precision,
    abyssal double precision,
    inshore double precision,
    offshore double precision,
    offshore_back double precision,
    max_depth integer,
    min_depth integer,
    lat_north integer,
    lat_south integer,
    found_in_fao_area_id int[],
    fao_limits smallint,
    sl_max integer,
    intertidal boolean
);

/* And here we create the dependent habitat_index view in the 'master' schema */
CREATE OR REPLACE VIEW master.habitat_index AS
SELECT taxon_key,
       taxon_name,
       common_name,
       sl_max,
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
       offshore_back
  FROM distribution.taxon_habitat;
