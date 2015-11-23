--
-- raw_catch warnings (non-blocking)
--
   
-- Year greater than the max year
CREATE OR REPLACE VIEW recon.v_raw_catch_year_max AS
SELECT id FROM raw_catch WHERE year > (SELECT max(year) FROM time);

-- Original taxon name is not null
CREATE OR REPLACE VIEW recon.v_raw_catch_original_taxon_not_null  AS
SELECT id FROM raw_catch WHERE original_taxon_name IS NOT NULL; 

-- Original country fishing is not null
CREATE OR REPLACE VIEW recon.v_raw_catch_original_country_fishing_not_null AS
SELECT id FROM raw_catch WHERE original_country_fishing IS NOT NULL; 

-- Original sector is not null
CREATE OR REPLACE VIEW recon.v_raw_catch_original_sector_not_null AS
SELECT id FROM raw_catch WHERE original_sector IS NOT NULL; 

-- Catch amount greater than 15e6 for Peru
CREATE OR REPLACE VIEW recon.v_raw_catch_peru_catch_amount_greater_than_threshold AS
SELECT id FROM raw_catch WHERE amount > 15e6 AND coalesce(eez_id, 0) = 604; 

-- Catch amount greater than 5e6 for others
CREATE OR REPLACE VIEW recon.v_raw_catch_amount_greater_than_threshold AS
SELECT id FROM raw_catch WHERE amount > 5e6 AND coalesce(eez_id, 0) != 604;

-- FAO is 27 and ICES is null
CREATE OR REPLACE VIEW recon.v_raw_catch_fao_27_ices_null AS
SELECT id FROM raw_catch WHERE fao_area_id = 27 AND ices_area_id IS NULL; 

-- FAO is 21 and NAFO is null
CREATE OR REPLACE VIEW recon.v_raw_catch_fao_21_nafo_null AS
SELECT id FROM raw_catch WHERE fao_area_id = 21 AND nafo_division_id IS NULL; 

-- Sector is subsistence and Layer is not 1
CREATE OR REPLACE VIEW recon.v_raw_catch_subsistence_and_layer_not_1 AS
SELECT id FROM raw_catch WHERE sector_type_id = 2 AND layer != 1; 

-- Layer is 2 or 3 and sector is not industrial
CREATE OR REPLACE VIEW recon.v_raw_catch_layer_2_or_3_and_sector_not_industrial AS
SELECT id FROM raw_catch WHERE layer IN (2,3) AND sector_type_id != 1; 

-- Rare taxa should be excluded
CREATE OR REPLACE VIEW recon.v_raw_catch_taxa_is_rare AS
SELECT rc.id FROM raw_catch rc, rare_taxon rt WHERE rc.taxon_key = rt.taxon_key;

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
  FROM raw_catch rc 
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
  FROM raw_catch rc
  LEFT JOIN eez_fishing_entity efe ON (rc.eez_id = efe.eez_id)
  LEFT JOIN layer3_taxon l3 ON (l3.taxon_key = rc.taxon_key)
 WHERE ((COALESCE(rc.eez_id, 0) <> 0 AND rc.fishing_entity_id <> 0) OR l3.taxon_key IS NOT NULL) 
   AND rc.layer 
       IS DISTINCT FROM
       CASE WHEN l3.taxon_key IS NOT NULL THEN 3
            WHEN rc.fishing_entity_id IS NOT DISTINCT FROM efe.expected_fishing_entity THEN 1
            ELSE 2
            END
;

-- Input type is reconstructed and Catch type is reported landings
CREATE OR REPLACE VIEW recon.v_raw_catch_input_reconstructed_catch_type_reported AS
SELECT id FROM raw_catch WHERE coalesce(input_type_id, 0) = 1 AND catch_type_id = 1; 

-- Input type is not reconstructed and Catch type not reported landings
CREATE OR REPLACE VIEW recon.v_raw_catch_input_not_reconstructed_catch_type_not_reported AS
SELECT id FROM raw_catch WHERE coalesce(input_type_id, 0) != 1 AND catch_type_id != 1; 

-- Layer is not 1, 2, or 3
CREATE OR REPLACE VIEW recon.v_raw_catch_layer_not_in_range AS
SELECT id FROM raw_catch WHERE layer NOT IN (1,2,3); 

-- Catch amount is zero or negative
CREATE OR REPLACE VIEW recon.v_raw_catch_amount_zero_or_negative AS
SELECT id FROM raw_catch WHERE amount <= 0; 

-- Lookup table mismatch
CREATE OR REPLACE VIEW recon.v_raw_catch_lookup_mismatch AS
SELECT rc.id 
  FROM raw_catch rc        
 WHERE 0 = ANY(ARRAY[taxon_key, 
                     coalesce(original_taxon_name_id, -1), 
                     coalesce(original_fao_name_id, -1), 
                     catch_type_id, 
                     fishing_entity_id, 
                     coalesce(original_country_fishing_id, -1), 
                     fao_area_id, 
                     sector_type_id, 
                     coalesce(input_type_id, -1), 
                     coalesce(reference_id, -1)]) 	
    OR eez_id IS NULL 	
    OR "year" NOT IN (SELECT t.year FROM "time" t); 

-- Missing required field
CREATE OR REPLACE VIEW recon.v_raw_catch_missing_required_field AS
SELECT id                
  FROM raw_catch 
 WHERE (fishing_entity || eez || fao_area || layer || sector || catch_type || "year" || taxon_name || amount || input_type) IS NULL;

--
-- catch warnings
--

-- Year greater than the max year
CREATE OR REPLACE VIEW recon.v_catch_year_max AS
  SELECT id FROM catch WHERE year > (SELECT max(year) FROM time);

-- Original taxon name is not null
CREATE OR REPLACE VIEW recon.v_catch_original_taxon_not_null  AS
  SELECT id FROM catch WHERE original_taxon_name_id IS NOT NULL;

-- Original country fishing is not null
CREATE OR REPLACE VIEW recon.v_catch_original_country_fishing_not_null AS
  SELECT id FROM catch WHERE original_country_fishing_id IS NOT NULL;

-- Original sector is not null
CREATE OR REPLACE VIEW recon.v_catch_original_sector_not_null AS
  SELECT id FROM catch WHERE original_sector IS NOT NULL;

-- Catch amount greater than 15e6 for Peru
CREATE OR REPLACE VIEW recon.v_catch_peru_catch_amount_greater_than_threshold AS
  SELECT id FROM catch WHERE amount > 15e6 AND eez_id = 604;

-- Catch amount greater than 5e6 for others
CREATE OR REPLACE VIEW recon.v_catch_amount_greater_than_threshold AS
  SELECT id FROM catch WHERE amount > 5e6 AND eez_id != 604;

-- FAO is 27 and ICES is null
CREATE OR REPLACE VIEW recon.v_catch_fao_27_ices_null AS
  SELECT id FROM catch WHERE fao_area_id = 27 AND ices_area_id IS NULL;

-- FAO is 21 and NAFO is null
CREATE OR REPLACE VIEW recon.v_catch_fao_21_nafo_null AS
  SELECT id FROM catch WHERE fao_area_id = 21 AND nafo_division_id IS NULL;

-- Sector is subsistence and Layer is not 1
CREATE OR REPLACE VIEW recon.v_catch_subsistence_and_layer_not_1 AS
  SELECT id FROM catch WHERE sector_type_id = 2 AND layer != 1;

-- Layer is 2 or 3 and sector is not industrial
CREATE OR REPLACE VIEW recon.v_catch_layer_2_or_3_and_sector_not_industrial AS
  SELECT id FROM catch WHERE layer IN (2,3) AND sector_type_id != 1;

-- Rare taxa should be excluded
CREATE OR REPLACE VIEW recon.v_catch_taxa_is_rare AS
  SELECT c.id FROM catch c, rare_taxon rt WHERE c.taxon_key = rt.taxon_key;

--
-- catch errors
--

CREATE OR REPLACE VIEW recon.v_catch_fishing_entity_and_eez_not_aligned AS
  WITH eez_fishing_entity AS (
      SELECT eez.eez_id, eez.is_home_eez_of_fishing_entity_id AS expected_fishing_entity FROM eez
  )
  SELECT c.id
  FROM catch c
    LEFT JOIN eez_fishing_entity efe ON (c.eez_id = efe.eez_id)
    LEFT JOIN layer3_taxon l3 ON (l3.taxon_key = c.taxon_key)
  WHERE ((c.eez_id <> 0 AND c.fishing_entity_id <> 0) OR l3.taxon_key IS NOT NULL)
        AND c.layer
            IS DISTINCT FROM
            CASE WHEN l3.taxon_key IS NOT NULL THEN 3
            WHEN c.fishing_entity_id IS NOT DISTINCT FROM efe.expected_fishing_entity THEN 1
            ELSE 2
            END
;

-- Input type is reconstructed and Catch type is reported landings
CREATE OR REPLACE VIEW recon.v_catch_input_reconstructed_catch_type_reported AS
  SELECT id FROM catch WHERE input_type_id = 1 AND catch_type_id = 1;

-- Input type is not reconstructed and Catch type not reported landings
CREATE OR REPLACE VIEW recon.v_catch_input_not_reconstructed_catch_type_not_reported AS
  SELECT id FROM catch WHERE input_type_id != 1 AND catch_type_id != 1;

-- Layer is not 1, 2, or 3
CREATE OR REPLACE VIEW recon.v_catch_layer_not_in_range AS
  SELECT id FROM catch WHERE layer NOT IN (1,2,3);

-- Catch amount is zero or negative
CREATE OR REPLACE VIEW recon.v_catch_amount_zero_or_negative AS
  SELECT id FROM catch WHERE amount <= 0;

/*
The command below should be maintained as the last command in this entire script.
*/
SELECT admin.grant_access();
