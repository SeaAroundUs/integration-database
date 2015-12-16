CREATE OR REPLACE VIEW master.v_taxon AS
SELECT * FROM master.taxon WHERE NOT is_retired;

CREATE OR REPLACE VIEW master.v_retired_taxon AS
SELECT * FROM master.taxon WHERE is_retired;
