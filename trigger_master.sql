---
--- Triggers
---

CREATE OR REPLACE FUNCTION master.taxon_insert_update_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  NEW.lineage := rtrim(
         format('%s.%s.%s.%s.%s.%s.%s.%s.%s.%s', 
                 master.lineage_pretty(NEW.phylum), master.lineage_pretty(NEW.sub_phylum),
                 master.lineage_pretty(NEW.super_class), master.lineage_pretty(NEW.class),
                 master.lineage_pretty(NEW.super_order), master.lineage_pretty(NEW."order"), master.lineage_pretty(NEW.suborder_infraorder),
                 master.lineage_pretty(NEW.family), 
                 master.lineage_pretty(NEW.genus),
                 master.lineage_pretty(NEW.species)
                )
         ,
         '.NA'
       )::public.ltree;
  
  IF NEW.lineage = '' THEN 
    NEW.lineage := NULL::LTREE;
  END IF;
  
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER taxon_before_insert_update_trigger BEFORE INSERT OR UPDATE
            ON master.taxon
  FOR EACH ROW EXECUTE PROCEDURE master.taxon_insert_update_trigger_handler();
