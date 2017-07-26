select * into log.eez_table_2017_07_25 from master.eez;

ALTER TABLE master.eez
ADD COLUMN gsi_link VARCHAR(400);

ALTER TABLE master.eez
DROP CONSTRAINT IF EXISTS geo_entity_id_fk;

ALTER TABLE master.access_agreement
DROP CONSTRAINT IF EXISTS eez_id_fk;

ALTER TABLE master.uncertainty_eez
DROP CONSTRAINT IF EXISTS uncertainty_eez_eez_id_fk;

ALTER TABLE recon.catch
DROP CONSTRAINT IF EXISTS eez_id_fk;

truncate master.eez;

\copy master.eez from 'eez_gsi_links_2017_07_25.txt' with (format csv, header, delimiter E'\t')

ALTER TABLE master.eez ADD CONSTRAINT geo_entity_id_fk
FOREIGN KEY (geo_entity_id) REFERENCES master.geo_entity(geo_entity_id) ON DELETE CASCADE;

ALTER TABLE master.access_agreement ADD CONSTRAINT eez_id_fk
FOREIGN KEY (eez_id) REFERENCES master.eez(eez_id) ON DELETE CASCADE;

ALTER TABLE master.uncertainty_eez ADD CONSTRAINT uncertainty_eez_eez_id_fk
FOREIGN KEY (eez_id) REFERENCES master.eez(eez_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT eez_id_fk
FOREIGN KEY (eez_id) REFERENCES master.eez(eez_id) ON DELETE CASCADE;

VACUUM FULL ANALYZE master.eez;

SELECT admin.grant_access();
