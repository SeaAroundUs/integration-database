insert into recon.validation_rule(rule_id, rule_type, name, description)
values
(10, 'E', 'v_raw_catch_antarctic_ccamlr_null', 'CCAMLR null for FAO 48, 58 or 88'),
(11, 'E', 'v_raw_catch_outside_antarctic_ccamlr_not_null', 'CCAMLR not null for catch outside of the Antarctic'),
(12, 'E', 'v_raw_catch_ccamlr_combo_mismatch', 'CCAMLR combo does not exist'),
(13, 'E', 'v_raw_catch_high_seas_mismatch', 'High Seas ID mismatch'),
(208, 'E', 'v_catch_antarctic_ccamlr_null', 'CCAMLR null for FAO 48, 58 or 88'),
(209, 'E', 'v_catch_outside_antarctic_ccamlr_not_null', 'CCAMLR not null for catch outside of the Antarctic'),
(210, 'E', 'v_catch_ccamlr_combo_mismatch', 'CCAMLR combo does not exist'),
(413, 'E', 'v_distribution_taxa_has_no_distribution_low_raw_catch', 'Distribution.taxon_distribution record unavailable, but raw catch <= 1000 (add taxa to substitute table)'),
(414, 'E', 'v_distribution_taxa_has_no_distribution_high_raw_catch', 'Distribution.taxon_distribution record unavailable and raw catch > 1000 (create extent/distribution)'),
(415, 'E', 'v_distribution_taxa_has_substitute_high_raw_catch', 'Distribution.taxon_distribution_substitute available and raw catch > 1000 (create extent/distribution)');

UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with lat_north is null' WHERE rule_id = 400;
UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with lat_south is null' WHERE rule_id = 401;
UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with min_depth is null' WHERE rule_id = 402;
UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with max_depth is null' WHERE rule_id = 403;

VACUUM FULL ANALYZE recon.validation_rule;

CREATE OR REPLACE VIEW recon.v_raw_catch_antarctic_ccamlr_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id in (48, 58, 88) and ccamlr_area is null;

CREATE OR REPLACE VIEW recon.v_raw_catch_outside_antarctic_ccamlr_not_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id not in (48, 58, 88) and ccamlr_area is not null;

CREATE OR REPLACE VIEW recon.v_raw_catch_ccamlr_combo_mismatch AS
SELECT rc.id 
  FROM recon.raw_catch rc
  LEFT JOIN geo.eez_ccamlr_combo cc ON (cc.ccamlr_area_id = rc.ccamlr_area and cc.eez_id = rc.eez_id)
 WHERE rc.fao_area_id in (48, 58, 88)
   and rc.eez_id <> 999 
   and rc.ccamlr_area is not null 
   and cc.ccamlr_area_id is null
   and cc.eez_id is null;

CREATE OR REPLACE VIEW recon.v_raw_catch_high_seas_mismatch AS
SELECT id FROM recon.raw_catch WHERE eez_id = 0 and eez <> 'High Seas';

CREATE OR REPLACE VIEW recon.v_catch_antarctic_ccamlr_null AS
SELECT id FROM recon.catch WHERE fao_area_id in (48, 58, 88) and ccamlr_area is null;

CREATE OR REPLACE VIEW recon.v_catch_outside_antarctic_ccamlr_not_null AS
SELECT id FROM recon.catch WHERE fao_area_id not in (48, 58, 88) and ccamlr_area is not null;

CREATE OR REPLACE VIEW recon.v_catch_ccamlr_combo_mismatch AS
SELECT c.id 
  FROM recon.catch c
  LEFT JOIN geo.eez_ccamlr_combo cc ON (cc.ccamlr_area_id = c.ccamlr_area and cc.eez_id = c.eez_id)
 WHERE c.fao_area_id in (48, 58, 88)
   and c.eez_id <> 999
   and c.ccamlr_area is not null 
   and cc.ccamlr_area_id is null
   and cc.eez_id is null;

CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_no_distribution_low_raw_catch AS
WITH distributions(taxon_key) as (
  select distinct taxon_key from distribution.taxon_distribution
),
substitutions(taxon_key) as (
  select distinct original_taxon_key from distribution.taxon_distribution_substitute
)
SELECT rc.taxon_key as id, sum(amount) 
  FROM recon.raw_catch rc
  LEFT JOIN distributions d on (rc.taxon_key = d.taxon_key)
  LEFT JOIN substitutions s on (rc.taxon_key = s.taxon_key)
 WHERE d.taxon_key is null
   and s.taxon_key is null
 GROUP BY rc.taxon_key 
HAVING sum(amount) <= 1000;


CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_no_distribution_high_raw_catch AS
WITH distributions(taxon_key) as (
  select distinct taxon_key from distribution.taxon_distribution
),
substitutions(taxon_key) as (
  select distinct original_taxon_key from distribution.taxon_distribution_substitute
)
SELECT rc.taxon_key as id, sum(amount) 
  FROM recon.raw_catch rc
  LEFT JOIN distributions d on (rc.taxon_key = d.taxon_key)
  LEFT JOIN substitutions s on (rc.taxon_key = s.taxon_key)
 WHERE d.taxon_key is null
   and s.taxon_key is null
 GROUP BY rc.taxon_key 
HAVING sum(amount) > 1000;


CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_substitute_high_raw_catch AS
WITH distributions(taxon_key) as (
  select distinct taxon_key from distribution.taxon_distribution
),
substitutions(taxon_key) as (
  select distinct original_taxon_key from distribution.taxon_distribution_substitute
)
SELECT rc.taxon_key as id, sum(amount) 
  FROM recon.raw_catch rc
  LEFT JOIN distributions d on (rc.taxon_key = d.taxon_key)
  LEFT JOIN substitutions s on (rc.taxon_key = s.taxon_key)
 WHERE d.taxon_key is null
   and s.taxon_key is not null
 GROUP BY rc.taxon_key 
HAVING sum(amount) > 1000;

select * from recon.maintain_validation_result_partition();

select admin.grant_access();