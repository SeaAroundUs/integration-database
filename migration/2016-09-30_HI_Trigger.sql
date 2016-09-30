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

CREATE TRIGGER taxon_habitat_before_update_trigger_for_taxon_sync
BEFORE UPDATE ON distribution.taxon_habitat
FOR EACH ROW
WHEN (OLD.min_depth IS DISTINCT FROM NEW.min_depth OR OLD.max_depth IS DISTINCT FROM NEW.max_depth OR 
      OLD.lat_north IS DISTINCT FROM NEW.lat_north OR OLD.lat_south IS DISTINCT FROM NEW.lat_south OR
      OLD.sl_max IS DISTINCT FROM NEW.sl_max)    
EXECUTE PROCEDURE distribution.taxon_habitat_insert_update_trigger_handler();

select admin.grant_access();
