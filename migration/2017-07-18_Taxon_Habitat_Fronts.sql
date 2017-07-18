-- dependent views; temporarily remove
drop view if exists master.habitat_index;
drop view if exists recon.v_distribution_taxon_habitat_fao_not_overlap_extent;
drop view if exists recon.v_distribution_taxon_extent_available_but_no_habitat;
drop view if exists recon.v_distribution_taxon_extent_available_but_no_distribution;
drop view if exists recon.v_distribution_taxon_lat_south_null;
drop view if exists recon.v_distribution_taxon_lat_north_null;
drop view if exists recon.v_distribution_taxon_min_depth_null;
drop view if exists recon.v_distribution_taxon_max_depth_null;

drop table distribution.taxon_habitat; -- front column to be positioned between coral/sea_grass

CREATE TABLE distribution.taxon_habitat (
    taxon_key int primary key,
    taxon_name character varying(255),
    common_name character varying(255),
    cla_code integer,
    ord_code integer,
    fam_code integer,
    gen_code integer,
    spe_code integer,
    effective_distance double precision,
    habitat_diversity_index double precision,
    estuaries double precision not null,
    coral double precision not null,
    front double precision not null,
    sea_grass double precision,
    sea_mount double precision not null,
    others double precision not null,
    slope double precision not null,
    shelf double precision not null,
    abyssal double precision not null,
    inshore double precision not null,
    offshore double precision not null,
    max_depth integer,
    min_depth integer,
	true_max_depth integer,
	water_column_position character varying(255),
	intertidal boolean,
    lat_north integer,
    lat_south integer,
    found_in_fao_area_id int[] not null,
    fao_limits smallint,
    sl_max double precision,
    temperature double precision,
    general_comments text
);

\copy distribution.taxon_habitat from 'TaxonHabitat_2017-07-18.txt' with (format csv, header, delimiter E'\t')

VACUUM FULL ANALYZE distribution.taxon_habitat;

-- re-create views
CREATE OR REPLACE VIEW master.habitat_index AS
SELECT taxon_key,
       taxon_name,
       common_name,
       sl_max,
       cla_code,
       ord_code,
       fam_code,
       gen_code,
       spe_code,
       habitat_diversity_index,
       effective_distance as effective_d,
       estuaries,
       coral,
	   front,
       sea_grass as seagrass,
       sea_mount as seamount,
       others,
       shelf,
       slope,
       abyssal,
       inshore,
       offshore,
	   temperature
FROM distribution.taxon_habitat;

create or replace view recon.v_distribution_taxon_habitat_fao_not_overlap_extent as
  select h.taxon_key as id 
    from distribution.taxon_habitat h 
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
join distribution.taxon_extent e on (e.taxon_key = h.taxon_key and not e.fao_area_id_intersects && h.found_in_fao_area_id);

create or replace view recon.v_distribution_taxon_extent_available_but_no_habitat as
  select e.taxon_key as id 
    from distribution.taxon_extent e
    join master.taxon t on (t.taxon_key = e.taxon_key and not t.is_retired)
    left join distribution.taxon_habitat h on (h.taxon_key = e.taxon_key)
where h.taxon_key is null;

create or replace view recon.v_distribution_taxon_extent_available_but_no_distribution as
  select e.taxon_key as id 
    from distribution.taxon_extent e
    join master.taxon t on (t.taxon_key = e.taxon_key and not t.is_retired)
    join distribution.taxon_habitat h on (h.taxon_key = e.taxon_key)
   where not exists (select 1 
                       from distribution.taxon_distribution d 
                      where d.taxon_key = e.taxon_key and not d.is_backfilled 
limit 1);

create or replace view recon.v_distribution_taxon_lat_north_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.lat_north is null;
  
create or replace view recon.v_distribution_taxon_lat_south_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.lat_south is null;
  
create or replace view recon.v_distribution_taxon_min_depth_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.min_depth is null;
  
create or replace view recon.v_distribution_taxon_max_depth_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.max_depth is null;

-- modify triggers to include front
CREATE OR REPLACE FUNCTION distribution.taxon_habitat_insert_update_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND TG_NAME = 'taxon_habitat_before_update_trigger_for_hdi') THEN
    NEW.habitat_diversity_index := 
      (SELECT COUNT(*)/5.0 
         FROM unnest(ARRAY[COALESCE(NEW.estuaries, 0) > 0,
                           COALESCE(NEW.coral, 0) > 0,
                           COALESCE(NEW.front, 0) > 0,
                           -- COALESCE(NEW.sea_grass, 0) > 0,
                           COALESCE(NEW.sea_mount, 0) > 0,
                           COALESCE(NEW.others, 0) > 0]) AS t(f)  
       WHERE t.f
      );
  END IF;
                    
  IF NEW.sl_max IS NOT NULL AND NEW.habitat_diversity_index IS NOT NULL THEN
    NEW.effective_distance := distribution.effective_distance(NEW.sl_max, NEW.habitat_diversity_index);
  END IF;
                              
  IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND TG_NAME = 'taxon_habitat_before_update_trigger_for_taxon_sync') THEN
    UPDATE master.taxon t
       SET sl_max = NEW.sl_max,
           lat_north = NEW.lat_north, 
           lat_south = NEW.lat_south,            
           min_depth = NEW.min_depth, 
           max_depth = NEW.max_depth
     WHERE t.taxon_key = NEW.taxon_key;
  END IF;
  
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

-- Re-create index
CREATE INDEX found_in_fao_area_id_idx ON distribution.taxon_habitat(found_in_fao_area_id);

-- DROP TRIGGER IF EXISTS taxon_habitat_before_update_trigger_for_hdi ON distribution.taxon_habitat;

-- Re-create triggers
CREATE TRIGGER taxon_habitat_before_update_trigger_for_hdi 
BEFORE UPDATE ON distribution.taxon_habitat
FOR EACH ROW
WHEN (OLD.estuaries IS DISTINCT FROM NEW.estuaries OR 
      OLD.coral IS DISTINCT FROM NEW.coral OR 
      OLD.front IS DISTINCT FROM NEW.front OR 
      -- OLD.sea_grass IS DISTINCT FROM NEW.sea_grass OR 
      OLD.sea_mount IS DISTINCT FROM NEW.sea_mount OR 
      OLD.others IS DISTINCT FROM NEW.others)    
EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();

CREATE TRIGGER taxon_habitat_before_insert_trigger 
BEFORE INSERT ON distribution.taxon_habitat
FOR EACH ROW 
  EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();

CREATE TRIGGER taxon_habitat_before_update_trigger_for_ed
BEFORE UPDATE ON distribution.taxon_habitat
FOR EACH ROW
WHEN (OLD.sl_max IS DISTINCT FROM NEW.sl_max OR OLD.habitat_diversity_index IS DISTINCT FROM NEW.habitat_diversity_index)    
EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();

CREATE TRIGGER taxon_habitat_before_update_trigger_for_taxon_sync
BEFORE UPDATE ON distribution.taxon_habitat
FOR EACH ROW
WHEN (OLD.min_depth IS DISTINCT FROM NEW.min_depth OR OLD.max_depth IS DISTINCT FROM NEW.max_depth OR 
      OLD.lat_north IS DISTINCT FROM NEW.lat_north OR OLD.lat_south IS DISTINCT FROM NEW.lat_south OR
      OLD.sl_max IS DISTINCT FROM NEW.sl_max)    
EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();
  
-- grant access
select admin.grant_access();
