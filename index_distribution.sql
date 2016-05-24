CREATE UNIQUE INDEX taxon_extent_taxon_key_idx ON distribution.taxon_extent(taxon_key);
CREATE INDEX taxon_extent_geom_idx ON distribution.taxon_extent USING gist (geom);

CREATE INDEX taxon_key_idx ON distribution.taxon_distribution(taxon_key);
CREATE UNIQUE INDEX cell_id_taxon_key_uk ON distribution.taxon_distribution(cell_id, taxon_key);

CREATE INDEX grid_geom_idx ON distribution.grid USING gist (geom);

CREATE INDEX found_in_fao_area_id_idx ON distribution.taxon_habitat(found_in_fao_area_id);

CREATE INDEX v_taxon_with_extent_taxon_key_ids ON distribution.v_taxon_with_extent(taxon_key);

CREATE INDEX v_taxon_with_distribution_taxon_key_ids ON distribution.v_taxon_with_distribution(taxon_key);

--CREATE UNIQUE INDEX v_cell_fao_cell_id_uk ON distribution.v_cell_fao(cell_id);
