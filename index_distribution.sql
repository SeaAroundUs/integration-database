CREATE INDEX taxon_key_idx ON distribution.taxon_distribution(taxon_key);
CREATE INDEX cell_id_idx ON distribution.taxon_distribution(cell_id);

CREATE INDEX grid_geom_idx ON distribution.grid USING gist (geom);

CREATE INDEX found_in_fao_area_id_idx ON distribution.taxon_habitat(found_in_fao_area_id);
