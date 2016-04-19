CREATE OR REPLACE VIEW geo.v_test_cell_assigned_water_area_exceeds_entire_cell_area AS SELECT rw.marine_layer_id,
    rw.area_id,
    rw.fao_area_id,
    rw.cell_id,
    rw.water_area AS this_cell_assignment_water_area,
    c.water_area AS entire_water_area_of_this_cell
   FROM (simple_area_cell_assignment_raw rw
     JOIN cell c ON ((rw.cell_id = c.cell_id)))
  WHERE ((rw.water_area > (c.water_area * (1.02)::double precision))
         -- 1.02 is used instead of 1.0 to allow some tolerance
         AND (rw.marine_layer_id <> 0)); 

CREATE OR REPLACE view v_internal_generate_Allocation_Simple_Area_Table AS
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
          Reconstruction_EEZ_ID AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          0                     AS InheritedAtt_Is_IFA,
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
        FROM geo.IFA
        WHERE EEZ_ID IN (SELECT EEZ_ID
                         FROM active_eezs)
    ),

    HighSeas as (
        SELECT
          2           AS Marine_Layer_ID,
          FAO_Area_ID AS Area_ID,
          FAO_Area_ID AS FAO_Area_ID,
          1           AS Is_Active,
          0           AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          0           AS InheritedAtt_Is_IFA,
          1           AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM master.high_seas
    ),

    ICES_HighSeas as (
        SELECT
          15                AS Marine_Layer_ID,
          EEZ_ICES_Combo_ID AS Area_ID,
          FAO_Area_ID       AS FAO_Area_ID,
          1                 AS Is_Active,
          0                 AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          0                 AS InheritedAtt_Is_IFA,
          1                 AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM eez_ices_combo
        WHERE EEZ_ID = 0
    ),

    ICES_IFAs as (
        SELECT
          15                AS Marine_Layer_ID,
          EEZ_ICES_Combo_ID AS Area_ID,
          FAO_Area_ID       AS FAO_Area_ID,
          1                 AS Is_Active,
          EEZ_ID            AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT     AS InheritedAtt_Is_IFA,
          0                 AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM eez_ices_combo
        WHERE is_IFA = TRUE AND EEZ_ID IN (SELECT EEZ_ID
                                           FROM active_eezs)
    ),

    ICES_EEZs as (
        SELECT
          15                AS Marine_Layer_ID,
          EEZ_ICES_Combo_ID AS Area_ID,
          FAO_Area_ID       AS FAO_Area_ID,
          1                 AS Is_Active,
          EEZ_ID            AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT     AS InheritedAtt_Is_IFA,
          (SELECT allows_coastal_fishing_for_layer2_data
           FROM master.EEZ e
           WHERE e.EEZ_ID = c.EEZ_ID
           LIMIT 1) :: INT  AS Inherited_Att_Allows_Coastal_Fishing_For_Layer2_Data
        FROM eez_ices_combo c
        WHERE is_IFA = FALSE AND EEZ_ID > 0 AND EEZ_ID IN (SELECT EEZ_ID
                                                           FROM active_eezs)
    ),

    BigCells_EEZs_HighSeas as (
        SELECT
          16                    AS Marine_Layer_ID,
          eez_big_cell_combo_id AS Area_ID,
          FAO_Area_ID           AS FAO_Area_ID,
          1                     AS Is_Active,
          EEZ_ID                AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          0                     AS InheritedAtt_Is_IFA,
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
          0                    AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          0                    AS InheritedAtt_Is_IFA,
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
          EEZ_ID               AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT        AS InheritedAtt_Is_IFA,
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
          EEZ_ID               AS InheritedAtt_Belongs_To_Reconstruction_EEZ_ID,
          Is_IFA :: INT        AS InheritedAtt_Is_IFA,
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
/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
