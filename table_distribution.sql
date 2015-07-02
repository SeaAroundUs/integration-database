CREATE TABLE distribution.taxon_distribution (
    taxon_distribution_id serial primary key,
    taxon_key integer not null,
    cell_id integer not null,
    relative_abundance double precision not null 
);

CREATE TABLE distribution.grid (
    id serial primary key,
    "row" integer,
    col integer,
    geom geometry
);

CREATE TABLE distribution.taxon_habitat (
    taxon_key int primary key,
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
    offshore_back double precision
);
