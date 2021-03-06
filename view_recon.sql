--
-- raw_catch warnings (non-blocking)
--
   
-- Year greater than the max year
CREATE OR REPLACE VIEW recon.v_raw_catch_year_max AS
SELECT id FROM recon.raw_catch WHERE year > (SELECT max(year) FROM time);

-- Original taxon name is not null
CREATE OR REPLACE VIEW recon.v_raw_catch_original_taxon_not_null  AS
SELECT id FROM recon.raw_catch WHERE original_taxon_name IS NOT NULL; 

-- Original country fishing is not null
CREATE OR REPLACE VIEW recon.v_raw_catch_original_country_fishing_not_null AS
SELECT id FROM recon.raw_catch WHERE original_country_fishing IS NOT NULL; 

-- Original sector is not null
CREATE OR REPLACE VIEW recon.v_raw_catch_original_sector_not_null AS
SELECT id FROM recon.raw_catch WHERE original_sector IS NOT NULL; 

-- Catch amount greater than 15e6 for Peru
CREATE OR REPLACE VIEW recon.v_raw_catch_peru_catch_amount_greater_than_threshold AS
SELECT id FROM recon.raw_catch WHERE amount > 15e6 AND eez_id IS NOT DISTINCT FROM 604; 

-- Catch amount greater than 5e6 for others
CREATE OR REPLACE VIEW recon.v_raw_catch_amount_greater_than_threshold AS
SELECT id FROM recon.raw_catch WHERE amount > 5e6 AND eez_id IS DISTINCT FROM 604;

-- FAO is 27 and ICES is null
CREATE OR REPLACE VIEW recon.v_raw_catch_fao_27_ices_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id = 27 AND ices_area_id IS NULL; 

-- FAO is 21 and NAFO is null
CREATE OR REPLACE VIEW recon.v_raw_catch_fao_21_nafo_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id = 21 AND nafo_division_id IS NULL; 

-- Sector is subsistence and Layer is not 1
CREATE OR REPLACE VIEW recon.v_raw_catch_subsistence_and_layer_not_1 AS
SELECT id FROM recon.raw_catch WHERE sector_type_id = 2 AND layer != 1; 

-- Layer is 2 or 3 and sector is not industrial
CREATE OR REPLACE VIEW recon.v_raw_catch_layer_2_or_3_and_sector_not_industrial AS
SELECT id FROM recon.raw_catch WHERE layer IN (2,3) AND sector_type_id != 1; 


--
-- raw_catch errors (blocking)
--

-- Fishing entity and EEZ rule for Layer
/*
CREATE OR REPLACE VIEW recon.v_raw_catch_fishing_entity_and_eez_not_aligned AS
WITH eez_fishing_entity AS (
  SELECT eez_id, is_home_eez_of_fishing_entity_id AS expected_fishing_entity FROM eez
) 
SELECT rc.id 
  FROM recon.raw_catch rc 
  LEFT JOIN eez_fishing_entity efe ON (rc.eez_id = efe.eez_id)
 WHERE coalesce(rc.eez_id, 0) !=0 
   AND fishing_entity_id != 0 
   AND ((expected_fishing_entity != fishing_entity_id AND layer = 1) OR (expected_fishing_entity = fishing_entity_id AND layer = 2));
*/

CREATE OR REPLACE VIEW recon.v_raw_catch_fishing_entity_and_eez_not_aligned AS
WITH eez_fishing_entity AS (
  SELECT eez.eez_id, eez.is_home_eez_of_fishing_entity_id AS expected_fishing_entity FROM eez
)
SELECT rc.id
  FROM recon.raw_catch rc
  LEFT JOIN eez_fishing_entity efe ON (rc.eez_id = efe.eez_id)
  LEFT JOIN layer3_taxon l3 ON (l3.taxon_key = rc.taxon_key)
 WHERE ((rc.eez_id IS DISTINCT FROM 0 AND rc.fishing_entity_id IS DISTINCT FROM 0) OR l3.taxon_key IS NOT NULL) 
   AND rc.layer 
       IS DISTINCT FROM
       CASE WHEN l3.taxon_key IS NOT NULL THEN 3
            WHEN rc.fishing_entity_id IS NOT DISTINCT FROM efe.expected_fishing_entity THEN 1
            ELSE 2
            END
   AND NOT (rc.layer = 1 AND rc.sector_type_id IS DISTINCT FROM 1)
;
/*
input type         | catch type | reporting status
reconstructed      | discards   | unreported
reconstructed      | landings   | unreported
FAO, national, etc | landings   | reported
FAO, national, etc | discards   | reported

input type         | reporting status | catch type 
reconstructed      | unreported       | landings   
reconstructed      | unreported       | discards   
FAO, national, etc | reported         | landings   
FAO, national, etc | reported         | discards   
*/

-- Input type is reconstructed and Reporting status is reported
CREATE OR REPLACE VIEW recon.v_raw_catch_input_reconstructed_reporting_status_reported AS
SELECT id FROM recon.raw_catch WHERE coalesce(input_type_id, 0) = 1 AND reporting_status_id = 1; 

-- Input type is not reconstructed and Reporting status unreported
CREATE OR REPLACE VIEW recon.v_raw_catch_input_not_reconstructed_reporting_status_unreported AS
SELECT id FROM recon.raw_catch WHERE coalesce(input_type_id, 0) != 1 AND reporting_status_id = 2; 

-- Layer is not 1, 2, or 3
CREATE OR REPLACE VIEW recon.v_raw_catch_layer_not_in_range AS
SELECT id FROM recon.raw_catch WHERE layer NOT IN (1,2,3); 

-- Catch amount is zero or negative
CREATE OR REPLACE VIEW recon.v_raw_catch_amount_zero_or_negative AS
SELECT id FROM recon.raw_catch WHERE amount <= 0; 

-- Lookup table mismatch
-- NOTE: this view heavily relies on the index raw_catch_lookup_mismatch_idx for its performance, 
--       so if you make any change to this view the index_recon.sql script should be reviewed as well to make sure the corresponding performance-related indexes are properly setup for this view.
--
CREATE OR REPLACE VIEW recon.v_raw_catch_lookup_mismatch AS
WITH tm AS (
  SELECT t.year FROM master.time AS t ORDER BY t.year
)
SELECT rc.id 
  FROM recon.raw_catch rc
 WHERE 0 = ANY(ARRAY[taxon_key, 
                     catch_type_id,
                     reporting_status_id,
                     fishing_entity_id, 
                     fao_area_id, 
                     sector_type_id, 
                     coalesce(input_type_id, -1), 
                     coalesce(reference_id, -1)]) 	
    OR eez_id IS NULL 	
UNION
SELECT rc.id 
  FROM recon.raw_catch rc
  LEFT JOIN tm ON (tm.year = rc.year)
 WHERE tm.year IS NULL;
    

-- Missing required field
-- NOTE: this view heavily relies on the two indexes raw_catch_required_field_idx and raw_catch_taxon_name_is_null_idx for its performance, 
--       so if you make any change to this view the index_recon.sql script should be reviewed as well to make sure the corresponding performance-related indexes are properly setup for this view.
--
CREATE OR REPLACE VIEW recon.v_raw_catch_missing_required_field AS
SELECT id                
  FROM recon.raw_catch rc
 WHERE (fishing_entity || eez || fao_area || layer || sector || catch_type || reporting_status || "year" || amount || input_type) IS NULL
UNION
SELECT id                
  FROM recon.raw_catch rc
  LEFT JOIN distribution.taxon_distribution_substitute ts ON (ts.original_taxon_key = rc.taxon_key)
 WHERE ts.original_taxon_key IS NULL AND rc.taxon_name IS NULL
;


-- Rare taxa should be excluded
CREATE OR REPLACE VIEW recon.v_raw_catch_taxa_is_rare AS
SELECT rc.id FROM recon.raw_catch rc, rare_taxon rt WHERE rc.taxon_key = rt.taxon_key;

-- CCAMLR null for FAO 48, 58 or 88
CREATE OR REPLACE VIEW recon.v_raw_catch_antarctic_ccamlr_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id in (48, 58, 88) and ccamlr_area is null;

-- CCAMLR not null for catch outside of the Antarctic
CREATE OR REPLACE VIEW recon.v_raw_catch_outside_antarctic_ccamlr_not_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id not in (48, 58, 88) and ccamlr_area is not null;

-- CCAMLR combo does not exist
-- As long as CCAMLR area is not null, then EEZ = 999 can be excluded; all combos have a corresponding HS shard
CREATE OR REPLACE VIEW recon.v_raw_catch_ccamlr_combo_mismatch AS
SELECT rc.id 
  FROM recon.raw_catch rc
  LEFT JOIN geo.eez_ccamlr_combo cc ON (cc.ccamlr_area_id = rc.ccamlr_area and cc.eez_id = rc.eez_id)
 WHERE rc.fao_area_id in (48, 58, 88)
   and rc.eez_id <> 999 
   and rc.ccamlr_area is not null 
   and cc.ccamlr_area_id is null
   and cc.eez_id is null;

-- ICES area null for FAO 27
CREATE OR REPLACE VIEW recon.v_raw_catch_ices_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id = 27 and ices_area is null;
   
-- ICES area not null for catch outside of FAO 27
CREATE OR REPLACE VIEW recon.v_raw_catch_outside_ices_not_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id <> 27 and ices_area is not null;

-- NAFO area null for FAO 21
CREATE OR REPLACE VIEW recon.v_raw_catch_nafo_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id = 21 and nafo_division is null;

-- NAFO area not null for catch outside of FAO 21
CREATE OR REPLACE VIEW recon.v_raw_catch_outside_nafo_not_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id <> 21 and nafo_division is not null;

-- High Seas ID mismatch
CREATE OR REPLACE VIEW recon.v_raw_catch_high_seas_mismatch AS
SELECT id FROM recon.raw_catch WHERE eez_id = 0 and eez <> 'High Seas';

-- ICES combo does not exist
CREATE OR REPLACE VIEW recon.v_raw_catch_high_seas_mismatch AS
SELECT rc.id
  FROM recon.raw_catch rc
  LEFT JOIN geo.eez_ices_combo ic ON (ic.ices_area_id = rc.ices_area and ic.eez_id = rc.eez_id)
WHERE rc.fao_area_id = 27
  and rc.eez_id <> 999
  and rc.ices_area is not null
  and ic.ices_area_id is null
  and ic.eez_id is null;

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

    
--
-- catch warnings
--

-- Year greater than the max year
CREATE OR REPLACE VIEW recon.v_catch_year_max AS
  SELECT id FROM recon.catch WHERE year > (SELECT max(year) FROM time);

-- Original taxon name is not null
CREATE OR REPLACE VIEW recon.v_catch_original_taxon_not_null  AS
  SELECT id FROM recon.catch WHERE original_taxon_name_id IS NOT NULL;

-- Original country fishing is not null
CREATE OR REPLACE VIEW recon.v_catch_original_country_fishing_not_null AS
  SELECT id FROM recon.catch WHERE original_country_fishing_id IS NOT NULL;

-- Original sector is not null
CREATE OR REPLACE VIEW recon.v_catch_original_sector_not_null AS
  SELECT id FROM recon.catch WHERE original_sector IS NOT NULL;

-- Catch amount greater than 15e6 for Peru
CREATE OR REPLACE VIEW recon.v_catch_peru_catch_amount_greater_than_threshold AS
  SELECT id FROM recon.catch WHERE amount > 15e6 AND eez_id = 604;

-- Catch amount greater than 5e6 for others
CREATE OR REPLACE VIEW recon.v_catch_amount_greater_than_threshold AS
  SELECT id FROM recon.catch WHERE amount > 5e6 AND eez_id != 604;

-- Sector is subsistence and Layer is not 1
CREATE OR REPLACE VIEW recon.v_catch_subsistence_and_layer_not_1 AS
  SELECT id FROM recon.catch WHERE sector_type_id = 2 AND layer != 1;

-- Layer is 2 or 3 and sector is not industrial
CREATE OR REPLACE VIEW recon.v_catch_layer_2_or_3_and_sector_not_industrial AS
  SELECT id FROM recon.catch WHERE layer IN (2,3) AND sector_type_id != 1; 
   

--
-- catch errors
--

CREATE OR REPLACE VIEW recon.v_catch_fishing_entity_and_eez_not_aligned AS
  WITH eez_fishing_entity AS (
      SELECT eez.eez_id, eez.is_home_eez_of_fishing_entity_id AS expected_fishing_entity FROM eez
  )
  SELECT c.id
    FROM recon.catch c
    LEFT JOIN eez_fishing_entity efe ON (c.eez_id = efe.eez_id)
    LEFT JOIN layer3_taxon l3 ON (l3.taxon_key = c.taxon_key)
  WHERE ((c.eez_id <> 0 AND c.fishing_entity_id <> 0) OR l3.taxon_key IS NOT NULL)
        AND c.layer
            IS DISTINCT FROM
            CASE WHEN l3.taxon_key IS NOT NULL THEN 3
            WHEN c.fishing_entity_id IS NOT DISTINCT FROM efe.expected_fishing_entity THEN 1
            ELSE 2
            END
   AND NOT (c.layer = 1 AND c.sector_type_id IS DISTINCT FROM 1)
;

-- Input type is reconstructed and Reporting status is reported
CREATE OR REPLACE VIEW recon.v_catch_input_reconstructed_reporting_status_reported AS
  SELECT id FROM recon.catch WHERE input_type_id = 1 AND reporting_status_id = 1;

-- Input type is not reconstructed and Reporting status is unreported
CREATE OR REPLACE VIEW recon.v_catch_input_not_reconstructed_reporting_status_unreported AS
  SELECT id FROM recon.catch WHERE input_type_id != 1 AND reporting_status_id = 2;

-- Layer is not 1, 2, or 3
CREATE OR REPLACE VIEW recon.v_catch_layer_not_in_range AS
  SELECT id FROM recon.catch WHERE layer NOT IN (1,2,3);

-- Catch amount is zero or negative
CREATE OR REPLACE VIEW recon.v_catch_amount_zero_or_negative AS
  SELECT id FROM recon.catch WHERE amount <= 0;

-- No access_agreement record found 
CREATE OR REPLACE VIEW recon.v_catch_no_corresponding_aa_found AS
  WITH fao AS (                                   
    SELEct fao_area_id, array_agg(distinct reconstruction_eez_id) eez_id
      FROM geo.eez_fao_combo 
     GROUP BY fao_area_id   
  ),                
  aa AS (
    SELECT a.eez_id, a.Fishing_Entity_ID, a.Start_Year, a.End_Year, string_to_array(a.Functional_Group_ID, ';')::int[] AS fgi 
      FROM master.Access_Agreement a
  )
  SELECT distinct c.id 
    FROM recon.catch c
    JOIN master.eez e ON (e.eez_id = c.eez_id and e.is_currently_used_for_reconstruction and e.eez_id not in (0, 999))
    JOIN master.fishing_entity fe ON (fe.fishing_entity_id = c.fishing_entity_id and not (fe.is_allowed_to_fish_pre_eez_by_default and c.year < e.declaration_year))
    JOIN master.taxon t ON (t.taxon_key = c.taxon_key)
    JOIN fao ON (fao.fao_area_id = c.fao_area_id)
    LEFT join aa ON (aa.fishing_entity_id = c.fishing_entity_id
                     and c.year between aa.Start_Year and aa.End_Year
                     and aa.eez_id = any(fao.eez_id)
                     and aa.eez_id = c.eez_id
                     and (aa.fgi is null or c.taxon_key = any(array[100039, 100139, 100239, 100339]) or t.functional_group_id = any(aa.fgi)))
   WHERE c.layer = 2
     AND aa.fishing_entity_id is null;  

-- Rare taxa should be excluded
CREATE OR REPLACE VIEW recon.v_catch_taxa_is_rare AS
  SELECT c.id FROM recon.catch c, rare_taxon rt WHERE c.taxon_key = rt.taxon_key;

-- CCAMLR null for FAO 48, 58 or 88
CREATE OR REPLACE VIEW recon.v_catch_antarctic_ccamlr_null AS
SELECT id FROM recon.catch WHERE fao_area_id in (48, 58, 88) and ccamlr_area IS NULL;

-- CCAMLR not null for catch outside of the Antarctic
CREATE OR REPLACE VIEW recon.v_catch_outside_antarctic_ccamlr_not_null AS
SELECT id FROM recon.catch WHERE fao_area_id not in (48, 58, 88) and ccamlr_area IS NOT NULL;

-- CCAMLR combo does not exist
-- As long as CCAMLR area is not null, then EEZ = 999 can be excluded; all combos have a corresponding HS shard
CREATE OR REPLACE VIEW recon.v_catch_ccamlr_combo_mismatch AS
SELECT c.id 
  FROM recon.catch c
  LEFT JOIN geo.eez_ccamlr_combo cc ON (cc.ccamlr_area_id = c.ccamlr_area and cc.eez_id = c.eez_id)
 WHERE c.fao_area_id in (48, 58, 88)
   and c.eez_id <> 999
   and c.ccamlr_area is not null 
   and cc.ccamlr_area_id is null
   and cc.eez_id is null;

-- ICES area null for FAO 27
CREATE OR REPLACE VIEW recon.v_catch_ices_null AS
SELECT id FROM recon.catch WHERE fao_area_id = 27 and ices_area_id IS NULL;
   
-- ICES area not null for catch outside of FAO 27
CREATE OR REPLACE VIEW recon.v_catch_outside_ices_not_null AS
SELECT id FROM recon.catch WHERE fao_area_id <> 27 and ices_area_id IS NOT NULL;

-- NAFO area null for FAO 21
CREATE OR REPLACE VIEW recon.v_catch_nafo_null AS
SELECT id FROM recon.catch WHERE fao_area_id = 21 and nafo_division_id IS NULL;

-- NAFO area not null for catch outside of FAO 21
CREATE OR REPLACE VIEW recon.v_catch_outside_nafo_not_null AS
SELECT id FROM recon.catch WHERE fao_area_id <> 21 and nafo_division_id IS NOT NULL;  

     
--
-- custom views
--
CREATE OR REPLACE VIEW recon.v_custom_eez_with_fishing_entity AS
  SELECT
    eez."eez_id" AS "EEZ ID",
    eez."name" AS "EEZ name",
    fishing_entity."fishing_entity_id" AS "Fishing entity ID",
    fishing_entity."name" AS "Fishing entity name"
  FROM master.eez
  LEFT JOIN master.fishing_entity
    ON (eez."is_home_eez_of_fishing_entity_id" = fishing_entity."fishing_entity_id")
  ORDER BY eez."eez_id" ASC;

CREATE OR REPLACE VIEW recon.v_custom_fao_area AS
  SELECT
    fao_area_id AS "FAO ID",
    "name" AS "Name",
    alternate_name AS "Alternate name"
  FROM master.fao_area
  ORDER BY "name" ASC;

CREATE OR REPLACE VIEW recon.v_custom_rfmo AS
  SELECT
    rfmo_id AS "RFMO ID",
    "name" AS "Name",
    long_name AS "Long name",
    profile_url AS "Profile URL"
  FROM master.rfmo
  ORDER BY "name" ASC;

CREATE OR REPLACE VIEW recon.v_custom_lme AS
  SELECT
    lme_id AS "LME ID",
    "name" AS "Name",
    profile_url AS "Profile URL"
  FROM master.lme
  ORDER BY "name" ASC;

CREATE OR REPLACE VIEW recon.v_custom_catch_comments AS
  SELECT
    DISTINCT fu.file AS "Filename",
    fu.comment AS "Comment",
    r.filename || ' (' || c.reference_id || ')' AS "Reference",
    fu.create_datetime AS "Create date/time"
  FROM catch c
    JOIN raw_catch rc ON (c.raw_catch_id = rc.id)
    JOIN file_upload fu ON (rc.source_file_id = fu.id)
    JOIN reference r ON (c.reference_id = r.reference_id)
  ORDER BY fu.create_datetime;

--
-- distribution errors
--

create or replace view recon.v_distribution_taxon_lat_north_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.lat_north is null;
  
create or replace view recon.v_distribution_taxon_lat_south_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.lat_south is null;
  
create or replace view recon.v_distribution_taxon_min_depth_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.min_depth is null;
  
create or replace view recon.v_distribution_taxon_max_depth_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.max_depth is null;
   
create or replace view recon.v_distribution_taxon_sl_max_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.sl_max is null;
  
create or replace view recon.v_distribution_taxon_habitat_fao_not_overlap_extent as
  select h.taxon_key as id 
    from distribution.taxon_habitat h 
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
    join distribution.taxon_extent e on (e.taxon_key = h.taxon_key and not e.fao_area_id_intersects && h.found_in_fao_area_id);

create or replace view recon.v_distribution_taxon_extent_available_but_no_habitat as
  select e.taxon_key as id 
    from distribution.taxon_extent e
    join master.taxon t on (t.taxon_key = e.taxon_key and not t.is_retired)
    left join distribution.taxon_habitat h on (h.taxon_key = e.taxon_key)
   where h.taxon_key is null;
   
create or replace view recon.v_distribution_taxon_extent_available_but_no_distribution as
  select e.taxon_key as id 
    from distribution.taxon_extent e
    join master.taxon t on (t.taxon_key = e.taxon_key and not t.is_retired)
    join distribution.taxon_habitat h on (h.taxon_key = e.taxon_key)
   where not exists (select 1 
                       from distribution.taxon_distribution d 
                      where d.taxon_key = e.taxon_key and not d.is_backfilled 
                      limit 1);

-- No distribution for taxa
-- NOTE: this view heavily relies on the index raw_catch_taxon_key_amount_idx for its performance, 
--       so if you make any change to this view the index_recon.sql script should be reviewed as well to make sure the corresponding performance-related indexes are properly setup for this view.
--
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


-- Distribution.taxon_distribution_substitute original key already has a distribution, consider removing it from the table
CREATE OR REPLACE VIEW recon.v_distribution_taxa_substitute_has_distribution AS
WITH taxa_with_distribution(taxon_key) AS (
  SELECT DISTINCT taxon_key
  FROM distribution.taxon_distribution
),
is_marked_as_automatic_substitute(original_taxon_key) AS (
  SELECT DISTINCT original_taxon_key
  FROM distribution.taxon_distribution_substitute
  WHERE is_manual_override = false
)
SELECT original_taxon_key as id
  FROM is_marked_as_automatic_substitute
  WHERE (original_taxon_key IN ( SELECT taxon_key
    FROM taxa_with_distribution));


-- Distribution.taxon_distribution_substitute suggested key does not have a distribution
CREATE OR REPLACE VIEW recon.v_distribution_taxa_substitute_has_no_distribution AS
WITH taxa_with_distribution(taxon_key) AS (
  SELECT DISTINCT taxon_key
  FROM distribution.taxon_distribution
)
SELECT use_this_taxon_key_instead as id
  FROM distribution.taxon_distribution_substitute
  WHERE NOT (use_this_taxon_key_instead IN ( SELECT taxon_key
    FROM taxa_with_distribution)); 

    
-- Distribution.taxon_distribution_substitute original key with manual override has a distribution
CREATE OR REPLACE VIEW recon.v_distribution_taxa_override_has_distribution AS
WITH taxa_with_distribution(taxon_key) AS (
  SELECT DISTINCT taxon_key
  FROM distribution.taxon_distribution
)
SELECT original_taxon_key as id
  FROM distribution.taxon_distribution_substitute
  WHERE is_manual_override AND (original_taxon_key IN ( SELECT taxon_key
    FROM taxa_with_distribution));
    
--
-- distribution warnings
--    
    
-- Distribution.taxon_distribution_substitute original key and the substitute have different FunctionalGroupIDs and may interfere with Access Agreements
CREATE OR REPLACE VIEW recon.v_distribution_taxa_substitute_has_different_functional_groups AS
WITH taxa_with_distribution(taxon_key) AS (
  SELECT DISTINCT taxon_key
  FROM distribution.taxon_distribution
)
SELECT ts.original_taxon_key as id
  FROM distribution.taxon_distribution_substitute ts
    JOIN master.taxon otk ON otk.taxon_key = ts.original_taxon_key
    JOIN master.taxon utk ON utk.taxon_key = ts.use_this_taxon_key_instead
  WHERE otk.functional_group_id IS DISTINCT FROM utk.functional_group_id;


/*
The command below should be maintained as the last command in this entire script.
*/
SELECT admin.grant_access();
