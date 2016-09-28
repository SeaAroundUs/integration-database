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
    NULL AS bigcellid,
    c.ccamlr_area,
    na.nafo_division
   FROM (((((recon.catch c
     JOIN master."time" y ON (((y.year = c.year) AND y.is_used_for_allocation)))
     JOIN master.sector_type st ON ((st.sector_type_id = c.sector_type_id)))
     JOIN master.input_type it ON ((it.input_type_id = c.input_type_id)))
     LEFT JOIN recon.ices_area ia ON ((ia.ices_area_id = c.ices_area_id)))
     LEFT JOIN recon.nafo na ON ((na.nafo_division_id = c.nafo_division_id)));

/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
