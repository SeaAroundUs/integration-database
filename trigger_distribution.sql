---
--- Triggers
---

CREATE OR REPLACE FUNCTION distribution.taxon_extent_insert_update_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  IF NEW.gid IS NULL THEN
     NEW.gid := nextval('distribution.taxon_extent_gid_seq'); 
  END IF;
  
  NEW.geom := public.ST_ForceRHR(public.ST_MAKEVALID(NEW.geom));
  
  NEW.fao_area_id_intersects := 
    (SELECT array_agg(f.fao_area_id) 
       FROM geo.fao_simplified f
      WHERE st_intersects(f.geom, NEW.geom) and not st_touches(f.geom, NEW.geom));
  
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER taxon_extent_before_insert_update_trigger BEFORE UPDATE OF geom OR INSERT
            ON distribution.taxon_extent
  FOR EACH ROW EXECUTE PROCEDURE distribution.taxon_extent_insert_update_trigger_handler();

CREATE OR REPLACE FUNCTION distribution.taxon_distribution_insert_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  -- Ignore the insert if the record has 0 relative abundance
  IF NEW.relative_abundance = 0.0 THEN
    RETURN NULL;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER taxon_distribution_before_insert_trigger BEFORE INSERT
            ON distribution.taxon_distribution
  FOR EACH ROW EXECUTE PROCEDURE distribution.taxon_distribution_insert_trigger_handler();

------

CREATE OR REPLACE FUNCTION distribution.taxon_habitat_insert_update_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND TG_NAME = 'taxon_habitat_before_update_trigger_for_hdi') THEN
    NEW.habitat_diversity_index := 
      (SELECT COUNT(*)/5.0 
         FROM unnest(ARRAY[COALESCE(NEW.estuaries, 0) > 0,
                           COALESCE(NEW.coral, 0) > 0,
                           COALESCE(NEW.sea_grass, 0) > 0,
                           COALESCE(NEW.sea_mount, 0) > 0,
                           COALESCE(NEW.others, 0) > 0]) AS t(f)  
       WHERE t.f
      );
  END IF;
                    
  IF NEW.sl_max IS NOT NULL AND NEW.habitat_diversity_index IS NOT NULL THEN
    NEW.effective_distance := distribution.effective_distance(NEW.sl_max, NEW.habitat_diversity_index);
  END IF;
                              
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER taxon_habitat_before_insert_trigger 
BEFORE INSERT ON distribution.taxon_habitat
FOR EACH ROW 
  EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();

CREATE TRIGGER taxon_habitat_before_update_trigger_for_hdi 
BEFORE UPDATE ON distribution.taxon_habitat
FOR EACH ROW
WHEN (OLD.estuaries IS DISTINCT FROM NEW.estuaries OR 
      OLD.coral IS DISTINCT FROM NEW.coral OR 
      OLD.sea_grass IS DISTINCT FROM NEW.sea_grass OR 
      OLD.sea_mount IS DISTINCT FROM NEW.sea_mount OR 
      OLD.others IS DISTINCT FROM NEW.others)    
EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();

CREATE TRIGGER taxon_habitat_before_update_trigger_for_ed
BEFORE UPDATE ON distribution.taxon_habitat
FOR EACH ROW
WHEN (OLD.sl_max IS DISTINCT FROM NEW.sl_max OR OLD.habitat_diversity_index IS DISTINCT FROM NEW.habitat_diversity_index)    
EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();
