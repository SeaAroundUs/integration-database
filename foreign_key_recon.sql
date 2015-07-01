-- recon.catch
ALTER TABLE recon.catch ADD CONSTRAINT fishing_entity_id_fk
FOREIGN KEY (fishing_entity_id) REFERENCES master.fishing_entity(fishing_entity_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT eez_id_fk
FOREIGN KEY (eez_id) REFERENCES master.eez(eez_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT fao_area_id_fk
FOREIGN KEY (fao_area_id) REFERENCES master.fao_area(fao_area_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT taxon_key_fk
FOREIGN KEY (taxon_key) REFERENCES master.taxon(taxon_key) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_type_id_fk
FOREIGN KEY (catch_type_id) REFERENCES master.catch_type(catch_type_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT year_fk
FOREIGN KEY (year) REFERENCES master.time(year) ON DELETE CASCADE;

-- recon.template
ALTER TABLE recon.template ADD CONSTRAINT fao_area_fk
FOREIGN KEY (fao_area) REFERENCES master.fao_area(fao_area_id) ON DELETE CASCADE;
