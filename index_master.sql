/* Table indexes */
CREATE UNIQUE INDEX time_ak ON master.time(year ASC);

CREATE INDEX cell_fao_area_id_idx ON master.cell(fao_area_id);
CREATE INDEX cell_lme_id_idx ON master.cell(lme_id);

CREATE INDEX mariculture_entity_legacy_c_number_idx ON master.mariculture_entity(legacy_c_number);
CREATE INDEX mariculture_sub_entity_mariculture_entity_id_idx ON master.mariculture_sub_entity(mariculture_entity_id);

CREATE INDEX p_water_idx ON master.cell(percent_water) WHERE percent_water > 0;

CREATE INDEX taxon_lineage_gist_idx ON master.taxon USING GIST (lineage);
