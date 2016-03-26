---
--- Triggers
---

CREATE OR REPLACE FUNCTION master.taxon_insert_update_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  NEW.lineage := 
    (COALESCE(NEW.phylum, 'Others') || 
     case when NEW.taxon_level_id > 1           
     then coalesce('.' || NEW.cla_code::varchar, '') || 
          case when NEW.taxon_level_id > 2
          then coalesce('.' || NEW.ord_code::varchar, '') ||
               case when NEW.taxon_level_id > 3
               then coalesce('.' || NEW.fam_code::varchar, '') ||
                    case when NEW.taxon_level_id > 4
                    then coalesce('.' || NEW.gen_code::varchar, '') ||
                         case when NEW.taxon_level_id > 5
                         then coalesce('.' || NEW.spe_code::varchar, '')
                         else ''
                         end
                    else ''
                    end
               else ''
               end
          else ''
          end
     else ''
     end)::public.ltree;
  
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER taxon_before_insert_update_trigger BEFORE INSERT OR UPDATE
            ON master.taxon
  FOR EACH ROW EXECUTE PROCEDURE master.taxon_insert_update_trigger_handler();
