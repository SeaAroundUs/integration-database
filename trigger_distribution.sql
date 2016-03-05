---
--- Triggers
---

CREATE OR REPLACE FUNCTION distribution.taxon_extent_insert_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  IF NEW.gid IS NULL THEN
     NEW.gid := nextval('distribution.taxon_extent_gid_seq'); 
  END IF;
  
  NEW.geom := public.ST_ForceRHR(NEW.geom);
  
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER taxon_extent_before_insert_trigger BEFORE INSERT
            ON distribution.taxon_extent
  FOR EACH ROW EXECUTE PROCEDURE distribution.taxon_extent_insert_trigger_handler();
