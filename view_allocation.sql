CREATE OR REPLACE view allocation.v_internal_generate_Allocation_Simple_Area_Table AS
  with active_eezs as (
        select distinct EEZ_ID
        from master.eez
        where is_currently_used_for_reconstruction = TRUE
  ),
    EEZs as (
        SELECT
          12                    AS Marine_Layer_ID,
          Reconstruction_EEZ_ID AS Area_ID,
          FAO_Area_ID,
          1                     AS Is_Active,
          Reconstruction_EEZ_ID AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          0                     AS Inherited_Att_Is_IFA,
          (SELECT allows_coastal_fishing_for_layer2_data
           FROM master.EEZ e
           WHERE e.EEZ_ID = c.Reconstruction_EEZ_ID
           LIMIT 1) :: INT      AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM geo.EEZ_FAO_Combo c
        WHERE Reconstruction_EEZ_ID IN (SELECT EEZ_ID
                                        FROM active_eezs)
    ),

    IFAs as (
        SELECT
          14                         AS Marine_Layer_ID,
          EEZ_ID                     AS Area_ID,
          ifa_is_located_in_this_fao AS FAO_Area_ID,
          1                          AS Is_Active,
          EEZ_ID                     AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          1                          AS Inherited_Att_Is_IFA,
          0                          AS allows_coastal_fishing_for_layer2_data
        FROM geo.IFA_fao
        WHERE EEZ_ID IN (SELECT EEZ_ID
                         FROM active_eezs)
    ),

    HighSeas as (
        SELECT
          2           AS Marine_Layer_ID,
          FAO_Area_ID AS Area_ID,
          FAO_Area_ID AS FAO_Area_ID,
          1           AS Is_Active,
          0           AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          0           AS Inherited_Att_Is_IFA,
          1           AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM master.high_seas
    ),

    ICES_HighSeas as (
        SELECT
          15                AS Marine_Layer_ID,
          EEZ_ICES_Combo_ID AS Area_ID,
          FAO_Area_ID       AS FAO_Area_ID,
          1                 AS Is_Active,
          0                 AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          0                 AS Inherited_Att_Is_IFA,
          1                 AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM geo.eez_ices_combo
        WHERE EEZ_ID = 0
    ),

    ICES_IFAs as (
        SELECT
          15                AS Marine_Layer_ID,
          EEZ_ICES_Combo_ID AS Area_ID,
          FAO_Area_ID       AS FAO_Area_ID,
          1                 AS Is_Active,
          EEZ_ID            AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT     AS Inherited_Att_Is_IFA,
          0                 AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM geo.eez_ices_combo
        WHERE is_IFA = TRUE AND EEZ_ID IN (SELECT EEZ_ID
                                           FROM active_eezs)
    ),

    ICES_EEZs as (
        SELECT
          15                AS Marine_Layer_ID,
          EEZ_ICES_Combo_ID AS Area_ID,
          FAO_Area_ID       AS FAO_Area_ID,
          1                 AS Is_Active,
          EEZ_ID            AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT     AS Inherited_Att_Is_IFA,
          (SELECT allows_coastal_fishing_for_layer2_data
           FROM master.EEZ e
           WHERE e.EEZ_ID = c.EEZ_ID
           LIMIT 1) :: INT  AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM geo.eez_ices_combo c
        WHERE is_IFA = FALSE AND EEZ_ID > 0 AND EEZ_ID IN (SELECT EEZ_ID
                                                           FROM active_eezs)
    ),

    BigCells_EEZs_HighSeas as (
        SELECT
          16                    AS Marine_Layer_ID,
          eez_big_cell_combo_id AS Area_ID,
          FAO_Area_ID           AS FAO_Area_ID,
          1                     AS Is_Active,
          EEZ_ID                AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          0                     AS Inherited_Att_Is_IFA,
          1                     AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data -- redundant
        FROM geo.eez_big_cell_combo c
        WHERE EEZ_ID = 0 OR EEZ_ID IN (SELECT EEZ_ID
                                       FROM active_eezs)
    ),

    CCAMLR_HighSeas as (
        SELECT
          17                   AS Marine_Layer_ID,
          eez_ccamlar_combo_id AS Area_ID,
          FAO_Area_ID          AS FAO_Area_ID,
          1                    AS Is_Active,
          0                    AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          0                    AS Inherited_Att_Is_IFA,
          1                    AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM geo.eez_ccamlr_combo
        WHERE EEZ_ID = 0
    ),

    CCAMLR_EEZs as (
        SELECT
          17                   AS Marine_Layer_ID,
          eez_ccamlar_combo_id AS Area_ID,
          FAO_Area_ID          AS FAO_Area_ID,
          1                    AS Is_Active,
          EEZ_ID               AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT        AS Inherited_Att_Is_IFA,
          (SELECT allows_coastal_fishing_for_layer2_data
           FROM master.EEZ e
           WHERE e.EEZ_ID = C.EEZ_ID
           LIMIT 1) :: INT     AS allows_coastal_fishing_for_layer2_data
        FROM geo.eez_ccamlr_combo C
        WHERE is_IFA = FALSE AND EEZ_ID > 0 AND EEZ_ID IN (SELECT EEZ_ID
                                                           FROM active_eezs)
    ),

    CCAMLR_IFAs as (
        SELECT
          17                   AS Marine_Layer_ID,
          eez_ccamlar_combo_id AS Area_ID,
          FAO_Area_ID          AS FAO_Area_ID,
          1                    AS Is_Active,     
          EEZ_ID               AS Inherited_Att_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT        AS Inherited_Att_Is_IFA,
          0                    AS allows_coastal_fishing_for_layer2_data
        FROM geo.eez_ccamlr_combo
        WHERE is_IFA = TRUE AND EEZ_ID IN (SELECT EEZ_ID
                                           FROM active_eezs)
    )

  select *
  from eezs
  union all
  select *
  from IFAs
 union all
  select *
  from HighSeas
  union all
  select *
  from ICES_HighSeas
union all
  select *
  from ICES_IFAs
union all
  select *
  from ICES_EEZs
union all
  select *
  from BigCells_EEZs_HighSeas
union all
  select *
  from CCAMLR_HighSeas
union all
  select *
  from CCAMLR_EEZs
union all
  select *
  from CCAMLR_IFAs;

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

/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
