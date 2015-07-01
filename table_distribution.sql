CREATE TABLE distribution.taxon_distribution (
    taxon_distribution_id serial PRIMARY KEY,
    taxon_key integer NOT NULL,
    cell_id integer NOT NULL,
    relative_abundance double precision NOT NULL
);
