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

-- Rare taxa should be excluded
CREATE OR REPLACE VIEW recon.v_raw_catch_taxa_is_rare AS
SELECT rc.id FROM recon.raw_catch rc, rare_taxon rt WHERE rc.taxon_key = rt.taxon_key;

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

-- FAO is 27 and ICES is null
CREATE OR REPLACE VIEW recon.v_catch_fao_27_ices_null AS
  SELECT id FROM recon.catch WHERE fao_area_id = 27 AND ices_area_id IS NULL;

-- FAO is 21 and NAFO is null
CREATE OR REPLACE VIEW recon.v_catch_fao_21_nafo_null AS
  SELECT id FROM recon.catch WHERE fao_area_id = 21 AND nafo_division_id IS NULL;

-- Sector is subsistence and Layer is not 1
CREATE OR REPLACE VIEW recon.v_catch_subsistence_and_layer_not_1 AS
  SELECT id FROM recon.catch WHERE sector_type_id = 2 AND layer != 1;

-- Layer is 2 or 3 and sector is not industrial
CREATE OR REPLACE VIEW recon.v_catch_layer_2_or_3_and_sector_not_industrial AS
  SELECT id FROM recon.catch WHERE layer IN (2,3) AND sector_type_id != 1;

-- Rare taxa should be excluded
CREATE OR REPLACE VIEW recon.v_catch_taxa_is_rare AS
  SELECT c.id FROM recon.catch c, rare_taxon rt WHERE c.taxon_key = rt.taxon_key;

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
  select taxon_key as id from master.taxon where not is_retired and lat_north is null;
  
create or replace view recon.v_distribution_taxon_lat_south_null as
  select taxon_key as id from master.taxon where not is_retired and lat_south is null;
  
create or replace view recon.v_distribution_taxon_min_depth_null as
  select taxon_key as id from master.taxon where not is_retired and min_depth is null;
  
create or replace view recon.v_distribution_taxon_max_depth_null as
  select taxon_key as id from master.taxon where not is_retired and max_depth is null;
  
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

/*
The command below should be maintained as the last command in this entire script.
*/
SELECT admin.grant_access();
