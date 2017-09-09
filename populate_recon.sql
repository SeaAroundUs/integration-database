TRUNCATE TABLE recon.validation_rule, recon.validation_result;

insert into recon.validation_rule(rule_id, rule_type, name, description)
values
-- Raw_catch error rules
(1, 'E', 'v_raw_catch_amount_zero_or_negative', 'Catch amount is zero or negative'),
(2, 'E', 'v_raw_catch_fishing_entity_and_eez_not_aligned', 'Layer is incorrect (determined by EEZ, Fishing Entity, and Taxon)'),
(3, 'E', 'v_raw_catch_input_reconstructed_reporting_status_reported', 'Input type is reconstructed and Reporting status is reported'),
(4, 'E', 'v_raw_catch_input_not_reconstructed_reporting_status_unreported', 'Input type is not reconstructed and Reporting status is unreported'),
(5, 'E', 'v_raw_catch_layer_not_in_range', 'Unknown layer'),
(6, 'E', 'v_raw_catch_lookup_mismatch', 'Lookup table mismatch'),
(7, 'E', 'v_raw_catch_missing_required_field', 'Missing required field'),
(8, 'E', 'v_raw_catch_taxa_is_rare', 'Rare taxa should be excluded'),
(10, 'E', 'v_raw_catch_antarctic_ccamlr_null', 'CCAMLR null for FAO 48, 58 or 88'),
(11, 'E', 'v_raw_catch_outside_antarctic_ccamlr_not_null', 'CCAMLR not null for catch outside of the Antarctic'),
(12, 'E', 'v_raw_catch_ccamlr_combo_mismatch', 'CCAMLR combo does not exist'),
(13, 'E', 'v_raw_catch_high_seas_mismatch', 'High Seas ID mismatch'),
(14, 'E', 'v_raw_catch_ices_null', 'ICES area null for FAO 27'),
(15, 'E', 'v_raw_catch_outside_ices_not_null', 'ICES area not null for catch outside of FAO 27'),
(16, 'E', 'v_raw_catch_nafo_null', 'NAFO area null for FAO 21'),
(17, 'E', 'v_raw_catch_outside_nafo_not_null', 'NAFO area not null for catch outside of FAO 21'),
(18, 'E', 'v_raw_catch_ices_combo_mismatch', 'ICES combo does not exist'),
(19, 'E', 'v_raw_catch_nafo_combo_mismatch', 'NAFO combo does not exist'),
(20, 'E', 'v_raw_catch_eez_ices_combo_ifa_mismatch', 'The EEZ and ICES combination for small-scale catch does not occur in an IFA area'),
(21, 'E', 'v_raw_catch_eez_nafo_combo_ifa_mismatch', 'The EEZ and NAFO combination for small-scale catch does not occur in an IFA area'),
(22, 'E', 'v_raw_catch_eez_ccamlr_combo_ifa_mismatch', 'The EEZ and CCAMLR combination for small-scale catch does not occur in an IFA area'),

-- Raw_catch warning rules
(100, 'W', 'v_raw_catch_layer_2_or_3_and_sector_not_industrial', 'Layer is 2 or 3 and Sector is not industrial'),
(101, 'W', 'v_raw_catch_amount_greater_than_threshold', 'Amount > 5e6'),
(104, 'W', 'v_raw_catch_original_country_fishing_not_null', 'Original country fishing is not null'),
(105, 'W', 'v_raw_catch_original_sector_not_null', 'Original sector is not null'),
(106, 'W', 'v_raw_catch_original_taxon_not_null', 'Original taxon name is not null'),
(107, 'W', 'v_raw_catch_peru_catch_amount_greater_than_threshold', 'Amount > 15e6 (Peru)'),
(108, 'W', 'v_raw_catch_subsistence_and_layer_not_1', 'Sector is subsistence and Layer is not 1'),
(109, 'W', 'v_raw_catch_year_max', 'Year greater than the max year'),

-- Catch error rules
(200, 'E', 'v_catch_amount_zero_or_negative', 'Catch amount is zero or negative'),
(201, 'E', 'v_catch_fishing_entity_and_eez_not_aligned', 'Layer is incorrect (determined by EEZ, Fishing Entity, and Taxon)'),
(202, 'E', 'v_catch_input_reconstructed_reporting_status_reported', 'Input type is reconstructed and Reporting status is reported'),
(203, 'E', 'v_catch_input_not_reconstructed_reporting_status_unreported', 'Input type is not reconstructed and Reporting status is unreported'),
(204, 'E', 'v_catch_layer_not_in_range', 'Unknown layer'),
(205, 'E', 'v_catch_taxa_is_rare', 'Rare taxa should be excluded'),     
(206, 'E', 'v_catch_no_corresponding_aa_found', 'No matching access_agreement records found'),
(208, 'E', 'v_catch_antarctic_ccamlr_null', 'CCAMLR null for FAO 48, 58 or 88'),
(209, 'E', 'v_catch_outside_antarctic_ccamlr_not_null', 'CCAMLR not null for catch outside of the Antarctic'),
(210, 'E', 'v_catch_ccamlr_combo_mismatch', 'CCAMLR combo does not exist'),
(211, 'E', 'v_catch_ices_null', 'ICES area null for FAO 27'),
(212, 'E', 'v_catch_outside_ices_not_null', 'ICES area not null for catch outside of FAO 27'),
(213, 'E', 'v_catch_nafo_null', 'NAFO area null for FAO 21'),
(214, 'E', 'v_catch_outside_nafo_not_null', 'NAFO area not null for catch outside of FAO 21'),

-- Catch warning rules
(300, 'W', 'v_catch_layer_2_or_3_and_sector_not_industrial', 'Layer is 2 or 3 and Sector is not industrial'),
(301, 'W', 'v_catch_amount_greater_than_threshold', 'Amount > 5e6'),
(304, 'W', 'v_catch_original_country_fishing_not_null', 'Original country fishing is not null'),
(305, 'W', 'v_catch_original_sector_not_null', 'Original sector is not null'),
(306, 'W', 'v_catch_original_taxon_not_null', 'Original taxon name is not null'),
(307, 'W', 'v_catch_peru_catch_amount_greater_than_threshold', 'Amount > 15e6 (Peru)'),
(308, 'W', 'v_catch_subsistence_and_layer_not_1', 'Sector is subsistence and Layer is not 1'),
(309, 'W', 'v_catch_year_max', 'Year greater than the max year'),

-- Distribution error rules
(400, 'E', 'v_distribution_taxon_lat_north_null', 'Distribution.taxon_habitat record with lat_north is null'),
(401, 'E', 'v_distribution_taxon_lat_south_null', 'Distribution.taxon_habitat record with lat_south is null'),
(402, 'E', 'v_distribution_taxon_min_depth_null', 'Distribution.taxon_habitat record with min_depth is null'),
(403, 'E', 'v_distribution_taxon_max_depth_null', 'Distribution.taxon_habitat record with max_depth is null'),
(410, 'E', 'v_distribution_taxon_habitat_fao_not_overlap_extent', 'Distribution.taxon_habitat record found_in_fao_area_id not overlapping with taxon extent'),
(411, 'E', 'v_distribution_taxon_extent_available_but_no_habitat', 'Distribution.taxon_extent record available, but no corresponding taxon habitat found'),
(412, 'E', 'v_distribution_taxon_extent_available_but_no_distribution', 'Distribution.taxon_extent record available, but no distribution generated yet'),
(413, 'E', 'v_distribution_taxa_has_no_distribution_low_raw_catch', 'Distribution.taxon_distribution record unavailable, but raw catch <= 1000 (add taxa to substitute table)'),
(414, 'E', 'v_distribution_taxa_has_no_distribution_high_raw_catch', 'Distribution.taxon_distribution record unavailable and raw catch > 1000 (create extent/distribution)'),
(415, 'E', 'v_distribution_taxa_has_substitute_high_raw_catch', 'Distribution.taxon_distribution_substitute available and raw catch > 1000 (create extent/distribution)'),
(416, 'E', 'v_distribution_taxa_substitute_has_distribution', 'Distribution.taxon_distribution_substitute original key already has a distribution, consider removing it from the table'), 
(417, 'E', 'v_distribution_taxa_substitute_has_no_distribution', 'Distribution.taxon_distribution_substitute suggested key does not have a distribution'),
(418, 'E', 'v_distribution_taxa_override_has_distribution', 'Distribution.taxon_distribution_substitute original key with manual override has a distribution'),
(420, 'E', 'v_distribution_taxon_sl_max_null', 'Distribution.taxon_habitat record with sl_max is null'),

-- Distribution warning rules
(500, 'W', 'v_distribution_taxa_substitute_has_different_functional_groups', 'Distribution.taxon_distribution_substitute original key and the substitute have different FunctionalGroupIDs and may interfere with Access Agreements')
;                    
