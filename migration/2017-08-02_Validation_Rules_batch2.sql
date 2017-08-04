insert into recon.validation_rule(rule_id, rule_type, name, description)
values
(18, 'E', 'v_raw_catch_ices_combo_mismatch', 'ICES combo does not exist'),
(19, 'E', 'v_raw_catch_nafo_combo_mismatch', 'NAFO combo does not exist'),
(20, 'E', 'v_raw_catch_eez_ices_combo_ifa_mismatch', 'The EEZ and ICES combination for small-scale catch does not occur in an IFA area'),
(21, 'E', 'v_raw_catch_eez_nafo_combo_ifa_mismatch', 'The EEZ and NAFO combination for small-scale catch does not occur in an IFA area'),
(22, 'E', 'v_raw_catch_eez_ccamlr_combo_ifa_mismatch', 'The EEZ and CCAMLR combination for small-scale catch does not occur in an IFA area');

VACUUM FULL ANALYZE recon.validation_rule;

select * from recon.maintain_validation_result_partition();

-- ICES combo does not exist
CREATE OR REPLACE VIEW recon.v_raw_catch_ices_combo_mismatch AS
SELECT rc.id
  FROM recon.raw_catch rc
  LEFT JOIN geo.eez_ices_combo ic ON (ic.ices_area_id = rc.ices_area and ic.eez_id = rc.eez_id)
WHERE rc.fao_area_id = 27
  and rc.eez_id <> 999
  and rc.ices_area is not null
  and ic.ices_area_id is null
  and ic.eez_id is null;
  
select recon.refresh_validation_result_partition('v_raw_catch_ices_combo_mismatch');

-- NAFO combo does not exist
CREATE OR REPLACE VIEW recon.v_raw_catch_nafo_combo_mismatch AS
SELECT rc.id
  FROM recon.raw_catch rc
  LEFT JOIN geo.eez_nafo_combo nc ON (nc.nafo_division = rc.nafo_division and nc.eez_id = rc.eez_id)
WHERE rc.fao_area_id = 21
  and rc.eez_id <> 999
  and rc.nafo_division is not null
  and nc.nafo_division is null
  and nc.eez_id is null;
  
select recon.refresh_validation_result_partition('v_raw_catch_nafo_combo_mismatch');

-- The EEZ and ICES combination for small-scale catch does not occur in an IFA area
-- Note: the eez_ices_combo table contains two entries for certain eez and ices combos
-- i.e., for some combinations of ices and eez, there is an is_ifa set to both true and false (2 records)
-- This is a workaround for the current table's format, and replaces the (simpler) validation rule:

/*
SELECT rc.id
FROM recon.raw_catch rc
INNER JOIN geo.eez_ices_combo ic ON (ic.ices_area_id = rc.ices_area and ic.eez_id = rc.eez_id)
WHERE not ic.is_ifa and rc.sector_type_id in (2,3,4);
*/

CREATE OR REPLACE VIEW recon.v_raw_catch_eez_ices_combo_ifa_mismatch AS
WITH list(ices_area_id, eez_id) AS (
  SELECT ices_area_id, eez_id, count(*) 
  FROM geo.eez_ices_combo 
  GROUP BY ices_area_id, eez_id 
  HAVING count(*) < 2
)
SELECT rc.id
  FROM recon.raw_catch rc
    INNER JOIN list l ON (l.ices_area_id = rc.ices_area and l.eez_id = rc.eez_id)
    INNER JOIN geo.eez_ices_combo ic ON (ic.ices_area_id = rc.ices_area and ic.eez_id = rc.eez_id)
  WHERE not ic.is_ifa 
    and rc.sector_type_id in (2,3,4);
	
select recon.refresh_validation_result_partition('v_raw_catch_eez_ices_combo_ifa_mismatch');

    
-- The EEZ and NAFO combination for small-scale catch does not occur in an IFA area
-- Note: the eez_nafo_combo table contains two entries for certain eez and nafo combos
-- i.e., for some combinations of nafo and eez, there is an is_ifa set to both true and false (2 records)
-- This is a workaround for the current table's format, and replaces the (simpler) validation rule:

/*
SELECT rc.id
FROM recon.raw_catch rc
INNER JOIN geo.eez_nafo_combo nc ON (nc.nafo_division = rc.nafo_division and nc.eez_id = rc.eez_id)
WHERE not nc.is_ifa and rc.sector_type_id in (2,3,4);
*/

CREATE OR REPLACE VIEW recon.v_raw_catch_eez_nafo_combo_ifa_mismatch AS
WITH list(nafo_division, eez_id) AS (
  SELECT nafo_division, eez_id, count(*) 
  FROM geo.eez_nafo_combo 
  GROUP BY nafo_division, eez_id 
  HAVING count(*) < 2
)
SELECT rc.id
  FROM recon.raw_catch rc
    INNER JOIN list l ON (l.nafo_division = rc.nafo_division and l.eez_id = rc.eez_id)
    INNER JOIN geo.eez_nafo_combo nc ON (nc.nafo_division = rc.nafo_division and nc.eez_id = rc.eez_id)
  WHERE not nc.is_ifa 
    and rc.sector_type_id in (2,3,4);    
	
select recon.refresh_validation_result_partition('v_raw_catch_eez_nafo_combo_ifa_mismatch');

    
-- The EEZ and CCAMLR combination for small-scale catch does not occur in an IFA area
-- Note: the eez_ccamlr_combo table contains two entries for certain eez and ccamlr combos
-- i.e., for some combinations of ccamlr and eez, there is an is_ifa set to both true and false (2 records)
-- This is a workaround for the current table's format, and replaces the (simpler) validation rule:

/*
SELECT rc.id
FROM recon.raw_catch rc
INNER JOIN geo.eez_ccamlr_combo cc ON (cc.ccamlr_area_id = rc.ccamlr_area and cc.eez_id = rc.eez_id)
WHERE not cc.is_ifa and rc.sector_type_id in (2,3,4);
*/

CREATE OR REPLACE VIEW recon.v_raw_catch_eez_ccamlr_combo_ifa_mismatch AS
WITH list(ccamlr_area_id, eez_id) AS (
  SELECT ccamlr_area_id, eez_id, count(*) 
  FROM geo.eez_ccamlr_combo 
  GROUP BY ccamlr_area_id, eez_id 
  HAVING count(*) < 2
)
SELECT rc.id
  FROM recon.raw_catch rc
    INNER JOIN list l ON (l.ccamlr_area_id = rc.ccamlr_area and l.eez_id = rc.eez_id)
    INNER JOIN geo.eez_ccamlr_combo cc ON (cc.ccamlr_area_id = rc.ccamlr_area and cc.eez_id = rc.eez_id)
  WHERE not cc.is_ifa 
    and rc.sector_type_id in (2,3,4);
	
select recon.refresh_validation_result_partition('v_raw_catch_eez_ccamlr_combo_ifa_mismatch');

VACUUM FULL ANALYZE recon.raw_catch;

select admin.grant_access();
