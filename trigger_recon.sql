---
--- Triggers
---

CREATE OR REPLACE FUNCTION recon.reference_insert_trigger_handler() RETURNS TRIGGER AS
$body$
BEGIN
  IF NEW.row_id IS NULL THEN
     NEW.row_id := nextval('recon.reference_row_id_seq'); 
  END IF;
  
  IF NEW.reference_id::TEXT LIKE '%.0' THEN
    NEW.reference_id := NEW.reference_id::INT;
  END IF;
  
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER reference_before_insert_trigger BEFORE INSERT
            ON recon.reference
  FOR EACH ROW EXECUTE PROCEDURE recon.reference_insert_trigger_handler();
