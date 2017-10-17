/* Table indexes */
CREATE UNIQUE INDEX time_ak ON master.time(year ASC);

CREATE INDEX cell_fao_area_id_idx ON master.cell(fao_area_id);
CREATE INDEX cell_lme_id_idx ON master.cell(lme_id);
CREATE INDEX cell_meow_id_idx ON master.cell(meow_id);

CREATE INDEX country_fishery_profile_count_code_idx ON master.country_fishery_profile(count_code);

CREATE INDEX mariculture_entity_legacy_c_number_idx ON master.mariculture_entity(legacy_c_number);
CREATE INDEX mariculture_sub_entity_mariculture_entity_id_idx ON master.mariculture_sub_entity(mariculture_entity_id);

CREATE INDEX p_water_idx ON master.cell(percent_water) WHERE percent_water > 0;

CREATE INDEX taxon_lineage_gist_idx ON master.taxon USING GIST (lineage);
CREATE INDEX taxon_lower_trim_scientific_name_idx ON master.taxon(lower(trim(scientific_name)));
CREATE INDEX taxon_lower_trim_common_name_idx ON master.taxon(lower(trim(common_name)));

CREATE INDEX access_agreement_fishing_entity_id_idx ON master.access_agreement(fishing_entity_id);

