CREATE INDEX taxon_key_idx ON distribution.taxon_distribution(taxon_key);
CREATE INDEX cell_id_idx ON distribution.taxon_distribution(cell_id);

CREATE INDEX grid_geom_idx ON distribution.grid USING gist (geom);
