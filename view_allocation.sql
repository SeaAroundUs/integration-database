CREATE MATERIALIZED VIEW allocation.allocation_error_log AS
  SELECT l.row_id as error_row_id,
	     l.data_row_id as universal_data_id,
	     c.id as catch_id,
	     c.layer as data_layer_id,
	     c.fishing_entity_id,
	     c.eez_id,
	     c.fao_area_id,
	     c.year,
	     c.taxon_key,
	     c.amount as catch_amount,
	     c.sector_type_id,
	     st.name as sector,
	     c.catch_type_id,
	     c.input_type_id,
         l.message as error_message
    FROM allocation.log_import_raw l
    JOIN recon.catch c ON (c.id = l.original_row_id)
    JOIN master.sector_type st ON (st.sector_type_id = c.sector_type_id);

CREATE OR REPLACE VIEW allocation.v_recon_catch_for_export AS SELECT c.raw_catch_id,
    c.layer,
    c.fishing_entity_id,
    c.eez_id,
    c.fao_area_id,
    c.year,
    c.taxon_key,
    c.amount,
    st.name AS sector,
    c.catch_type_id,
    c.reporting_status_id,
    it.name AS input,
    ia.ices_area,
    NULL::INT AS bigcellid,
    c.ccamlr_area,
    na.nafo_division
   FROM (((((recon.catch c
     JOIN master."time" y ON (((y.year = c.year) AND y.is_used_for_allocation)))
     JOIN master.sector_type st ON ((st.sector_type_id = c.sector_type_id)))
     JOIN master.input_type it ON ((it.input_type_id = c.input_type_id)))
     LEFT JOIN recon.ices_area ia ON ((ia.ices_area_id = c.ices_area_id)))
     LEFT JOIN recon.nafo na ON ((na.nafo_division_id = c.nafo_division_id)));

CREATE OR REPLACE VIEW allocation.v_internal_generate_allocation_simple_area_table AS
 WITH active_eezs AS (
         SELECT DISTINCT eez.eez_id
           FROM eez
          WHERE eez.is_currently_used_for_reconstruction = true
        ), eezs AS (
         SELECT 12 AS marine_layer_id,
            c.reconstruction_eez_id AS area_id,
            c.fao_area_id,
            1 AS is_active,
            c.reconstruction_eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            0 AS inherited_att_is_ifa,
            (( SELECT e.allows_coastal_fishing_for_layer2_data
                   FROM eez e
                  WHERE e.eez_id = c.reconstruction_eez_id
                 LIMIT 1))::integer AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM eez_fao_combo c
          WHERE (c.reconstruction_eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        ), ifas AS (
         SELECT 14 AS marine_layer_id,
            ifa.eez_id AS area_id,
            ifa.ifa_is_located_in_this_fao AS fao_area_id,
            1 AS is_active,
            ifa.eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            1 AS inherited_att_is_ifa,
            0 AS allows_coastal_fishing_for_layer2_data
           FROM geo.ifa ifa
          WHERE (ifa.eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        ), highseas AS (
         SELECT 2 AS marine_layer_id,
            high_seas.fao_area_id AS area_id,
            high_seas.fao_area_id,
            1 AS is_active,
            0 AS inherited_att_belongs_to_reconstruction_eez_id,
            0 AS inherited_att_is_ifa,
            1 AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM high_seas
        ), ices_highseas AS (
         SELECT 15 AS marine_layer_id,
            eez_ices_combo.eez_ices_combo_id AS area_id,
            eez_ices_combo.fao_area_id,
            1 AS is_active,
            0 AS inherited_att_belongs_to_reconstruction_eez_id,
            0 AS inherited_att_is_ifa,
            1 AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM eez_ices_combo
          WHERE eez_ices_combo.eez_id = 0
        ), ices_ifas AS (
         SELECT 15 AS marine_layer_id,
            eez_ices_combo.eez_ices_combo_id AS area_id,
            eez_ices_combo.fao_area_id,
            1 AS is_active,
            eez_ices_combo.eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            eez_ices_combo.is_ifa::integer AS inherited_att_is_ifa,
            0 AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM eez_ices_combo
          WHERE eez_ices_combo.is_ifa = true AND (eez_ices_combo.eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        ), ices_eezs AS (
         SELECT 15 AS marine_layer_id,
            c.eez_ices_combo_id AS area_id,
            c.fao_area_id,
            1 AS is_active,
            c.eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            c.is_ifa::integer AS inherited_att_is_ifa,
            (( SELECT e.allows_coastal_fishing_for_layer2_data
                   FROM eez e
                  WHERE e.eez_id = c.eez_id
                 LIMIT 1))::integer AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM eez_ices_combo c
          WHERE c.is_ifa = false AND c.eez_id > 0 AND (c.eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        ), bigcells_eezs_highseas AS (
         SELECT 16 AS marine_layer_id,
            c.eez_big_cell_combo_id AS area_id,
            c.fao_area_id,
            1 AS is_active,
            c.eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            0 AS inherited_att_is_ifa,
            1 AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM eez_big_cell_combo c
          WHERE c.eez_id = 0 OR (c.eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        ), ccamlr_highseas AS (
         SELECT 17 AS marine_layer_id,
            eez_ccamlr_combo.eez_ccamlar_combo_id AS area_id,
            eez_ccamlr_combo.fao_area_id,
            1 AS is_active,
            0 AS inherited_att_belongs_to_reconstruction_eez_id,
            0 AS inherited_att_is_ifa,
            1 AS inherited_att_allows_coastal_fishing_for_layer2_data
           FROM eez_ccamlr_combo
          WHERE eez_ccamlr_combo.eez_id = 0
        ), ccamlr_eezs AS (
         SELECT 17 AS marine_layer_id,
            c.eez_ccamlar_combo_id AS area_id,
            c.fao_area_id,
            1 AS is_active,
            c.eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            c.is_ifa::integer AS inherited_att_is_ifa,
            (( SELECT e.allows_coastal_fishing_for_layer2_data
                   FROM eez e
                  WHERE e.eez_id = c.eez_id
                 LIMIT 1))::integer AS allows_coastal_fishing_for_layer2_data
           FROM eez_ccamlr_combo c
          WHERE c.is_ifa = false AND c.eez_id > 0 AND (c.eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        ), ccamlr_ifas AS (
         SELECT 17 AS marine_layer_id,
            eez_ccamlr_combo.eez_ccamlar_combo_id AS area_id,
            eez_ccamlr_combo.fao_area_id,
            1 AS is_active,
            eez_ccamlr_combo.eez_id AS inherited_att_belongs_to_reconstruction_eez_id,
            eez_ccamlr_combo.is_ifa::integer AS inherited_att_is_ifa,
            0 AS allows_coastal_fishing_for_layer2_data
           FROM eez_ccamlr_combo
          WHERE eez_ccamlr_combo.is_ifa = true AND (eez_ccamlr_combo.eez_id IN ( SELECT active_eezs.eez_id
                   FROM active_eezs))
        )
 SELECT eezs.marine_layer_id,
    eezs.area_id,
    eezs.fao_area_id,
    eezs.is_active,
    eezs.inherited_att_belongs_to_reconstruction_eez_id,
    eezs.inherited_att_is_ifa,
    eezs.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM eezs
UNION ALL
 SELECT ifas.marine_layer_id,
    ifas.area_id,
    ifas.fao_area_id,
    ifas.is_active,
    ifas.inherited_att_belongs_to_reconstruction_eez_id,
    ifas.inherited_att_is_ifa,
    ifas.allows_coastal_fishing_for_layer2_data AS inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ifas
UNION ALL
 SELECT highseas.marine_layer_id,
    highseas.area_id,
    highseas.fao_area_id,
    highseas.is_active,
    highseas.inherited_att_belongs_to_reconstruction_eez_id,
    highseas.inherited_att_is_ifa,
    highseas.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM highseas
UNION ALL
 SELECT ices_highseas.marine_layer_id,
    ices_highseas.area_id,
    ices_highseas.fao_area_id,
    ices_highseas.is_active,
    ices_highseas.inherited_att_belongs_to_reconstruction_eez_id,
    ices_highseas.inherited_att_is_ifa,
    ices_highseas.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ices_highseas
UNION ALL
 SELECT ices_ifas.marine_layer_id,
    ices_ifas.area_id,
    ices_ifas.fao_area_id,
    ices_ifas.is_active,
    ices_ifas.inherited_att_belongs_to_reconstruction_eez_id,
    ices_ifas.inherited_att_is_ifa,
    ices_ifas.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ices_ifas
UNION ALL
 SELECT ices_eezs.marine_layer_id,
    ices_eezs.area_id,
    ices_eezs.fao_area_id,
    ices_eezs.is_active,
    ices_eezs.inherited_att_belongs_to_reconstruction_eez_id,
    ices_eezs.inherited_att_is_ifa,
    ices_eezs.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ices_eezs
UNION ALL
 SELECT bigcells_eezs_highseas.marine_layer_id,
    bigcells_eezs_highseas.area_id,
    bigcells_eezs_highseas.fao_area_id,
    bigcells_eezs_highseas.is_active,
    bigcells_eezs_highseas.inherited_att_belongs_to_reconstruction_eez_id,
    bigcells_eezs_highseas.inherited_att_is_ifa,
    bigcells_eezs_highseas.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM bigcells_eezs_highseas
UNION ALL
 SELECT ccamlr_highseas.marine_layer_id,
    ccamlr_highseas.area_id,
    ccamlr_highseas.fao_area_id,
    ccamlr_highseas.is_active,
    ccamlr_highseas.inherited_att_belongs_to_reconstruction_eez_id,
    ccamlr_highseas.inherited_att_is_ifa,
    ccamlr_highseas.inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ccamlr_highseas
UNION ALL
 SELECT ccamlr_eezs.marine_layer_id,
    ccamlr_eezs.area_id,
    ccamlr_eezs.fao_area_id,
    ccamlr_eezs.is_active,
    ccamlr_eezs.inherited_att_belongs_to_reconstruction_eez_id,
    ccamlr_eezs.inherited_att_is_ifa,
    ccamlr_eezs.allows_coastal_fishing_for_layer2_data AS inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ccamlr_eezs
UNION ALL
 SELECT ccamlr_ifas.marine_layer_id,
    ccamlr_ifas.area_id,
    ccamlr_ifas.fao_area_id,
    ccamlr_ifas.is_active,
    ccamlr_ifas.inherited_att_belongs_to_reconstruction_eez_id,
    ccamlr_ifas.inherited_att_is_ifa,
    ccamlr_ifas.allows_coastal_fishing_for_layer2_data AS inherited_att_allows_coastal_fishing_for_layer2_data
   FROM ccamlr_ifas;	 
	 
/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
