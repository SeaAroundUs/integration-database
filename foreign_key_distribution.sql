-- distribution.taxon_distribution
ALTER TABLE distribution.taxon_distribution ADD CONSTRAINT taxon_key_fk
FOREIGN KEY (taxon_key) REFERENCES master.taxon(taxon_key) ON DELETE CASCADE;

ALTER TABLE distribution.taxon_distribution ADD CONSTRAINT cell_id_fk
FOREIGN KEY (cell_id) REFERENCES master.cell(cell_id) ON DELETE CASCADE;
