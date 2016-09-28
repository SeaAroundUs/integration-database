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

-- Raw_catch warning rules
(100, 'W', 'v_raw_catch_layer_2_or_3_and_sector_not_industrial', 'Layer is 2 or 3 and Sector is not industrial'),
(101, 'W', 'v_raw_catch_amount_greater_than_threshold', 'Amount > 5e6'),
(102, 'W', 'v_raw_catch_fao_21_nafo_null', 'Null NAFO for FAO 21'),
(103, 'W', 'v_raw_catch_fao_27_ices_null', 'Null ICES for FAO 27'),
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

-- Catch warning rules
(300, 'W', 'v_catch_layer_2_or_3_and_sector_not_industrial', 'Layer is 2 or 3 and Sector is not industrial'),
(301, 'W', 'v_catch_amount_greater_than_threshold', 'Amount > 5e6'),
(302, 'W', 'v_catch_fao_21_nafo_null', 'Null NAFO for FAO 21'),
(303, 'W', 'v_catch_fao_27_ices_null', 'Null ICES for FAO 27'),
(304, 'W', 'v_catch_original_country_fishing_not_null', 'Original country fishing is not null'),
(305, 'W', 'v_catch_original_sector_not_null', 'Original sector is not null'),
(306, 'W', 'v_catch_original_taxon_not_null', 'Original taxon name is not null'),
(307, 'W', 'v_catch_peru_catch_amount_greater_than_threshold', 'Amount > 15e6 (Peru)'),
(308, 'W', 'v_catch_subsistence_and_layer_not_1', 'Sector is subsistence and Layer is not 1'),
(309, 'W', 'v_catch_year_max', 'Year greater than the max year'),

-- Distribution error rules
(400, 'E', 'v_distribution_taxon_lat_north_null', 'Master.taxon record with lat_north is null'),
(401, 'E', 'v_distribution_taxon_lat_south_null', 'Master.taxon record with lat_south is null'),
(402, 'E', 'v_distribution_taxon_min_depth_null', 'Master.taxon record with min_depth is null'),
(403, 'E', 'v_distribution_taxon_max_depth_null', 'Master.taxon record with max_depth is null'),
(410, 'E', 'v_distribution_taxon_habitat_fao_not_overlap_extent', 'Distribution.taxon_habitat record found_in_fao_area_id not overlapping with taxon extent'),
(411, 'E', 'v_distribution_taxon_extent_available_but_no_habitat', 'Distribution.taxon_extent record available, but no corresponding taxon habitat found'),
(412, 'E', 'v_distribution_taxon_extent_available_but_no_distribution', 'Distribution.taxon_extent record available, but no distribution generated yet'),
(413, 'E', 'v_distribution_taxa_has_no_distribution_low_catch', 'No distribution for taxa and catch <= 1000'),
(414, 'E', 'v_distribution_taxa_has_no_distribution_high_catch', 'No distribution for taxa and catch > 1000')
;
