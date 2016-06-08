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
       FROM geo.v_fao f
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
