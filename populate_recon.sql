TRUNCATE TABLE recon.validation_rule, recon.validation_result;

insert into recon.validation_rule(rule_id, rule_type, name, description)
values
-- Raw_catch error rules
(1, 'E', 'v_raw_catch_amount_zero_or_negative', 'Catch amount is zero or negative'),
(2, 'E', 'v_raw_catch_fishing_entity_and_eez_not_aligned', 'Layer is incorrect (determined by EEZ, Fishing Entity, and Taxon)'),
(3, 'E', 'v_raw_catch_input_reconstructed_reporting_status_reported', 'Input type is reconstructed and Reporting status is reported'),
(4, 'E', 'v_raw_catch_input_not_reconstructed_reporting_staus_unreported', 'Input type is not reconstructed and Reporting status is unreported'),
(5, 'E', 'v_raw_catch_layer_not_in_range', 'Unknown layer'),
(6, 'E', 'v_raw_catch_lookup_mismatch', 'Lookup table mismatch'),
(7, 'E', 'v_raw_catch_missing_required_field', 'Missing required field'),
(8, 'E', 'v_raw_catch_taxa_is_rare', 'Rare taxa should be excluded'),

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
(309, 'W', 'v_catch_year_max', 'Year greater than the max year')
;
