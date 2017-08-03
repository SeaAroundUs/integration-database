insert into recon.validation_rule(rule_id, rule_type, name, description)
values
(416, 'E', 'v_distribution_taxa_substitute_has_distribution', 'Original_taxon_key already has a distribution, consider removing it from table taxon_distribution_substitute'), 
(417, 'E', 'v_distribution_taxa_substitute_has_no_distribution', 'The suggested use_this_taxon_key_instead does not have a distribution'),
(418, 'E', 'v_distribution_taxa_override_has_distribution', 'The original_taxon_key with manual override has a distribution'),
(419, 'E', 'v_distribution_taxa_substitute_has_different_functional_groups', 'The original_taxon_key and the substitute have different FunctionalGroupIDs and may interfere with Access Agreements');

VACUUM FULL ANALYZE recon.validation_rule;

select * from recon.maintain_validation_result_partition();

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

select recon.refresh_validation_result_partition('v_distribution_taxa_substitute_has_distribution');

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

select recon.refresh_validation_result_partition('v_distribution_taxa_substitute_has_no_distribution');
    
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
    
select recon.refresh_validation_result_partition('v_distribution_taxa_override_has_distribution');
    
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
  
select recon.refresh_validation_result_partition('v_distribution_taxa_substitute_has_different_functional_groups');

VACUUM FULL ANALYZE recon.raw_catch;

select admin.grant_access();
