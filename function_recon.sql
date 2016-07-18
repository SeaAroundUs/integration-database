create or replace function recon.normalize_raw_catch_by_ids(i_raw_catch_ids int[]) returns void as
$body$
  update recon.raw_catch rc
     set fishing_entity_id = coalesce(fe.fishing_entity_id, 0),
         original_country_fishing_id = ofe.fishing_entity_id, 
         eez_id = coalesce(e.eez_id, 0),
         fao_area_id = coalesce(fa.fao_area_id, 0),
         sector_type_id = coalesce(st.sector_type_id, 0),
         input_type_id = coalesce(it.input_type_id, 0),
         catch_type_id = coalesce(ct.catch_type_id, 0),
         reporting_status_id = coalesce(rs.reporting_status_id, 0),
         nafo_division_id = case 
                            when coalesce(r.nafo_division, '') = '' then null::int 
                            else coalesce(nf.nafo_division_id, 0)
                             end,
         taxon_key = case 
                     when tds.original_taxon_key is not null then tds.use_this_taxon_key_instead 
                     else coalesce(tx.taxon_key, coalesce(cx.taxon_key), 0)
                     end,
         original_taxon_name_id = otn.taxon_key,
         original_fao_name_id = ofn.taxon_key,
         ices_area_id = case
                        when coalesce(r.ices_area, '') = '' then null::int
                        else coalesce(ia.ices_area_id, 0)
                        end,
         last_modified = now()
    from recon.raw_catch r
    left join master.fishing_entity fe on (lower(trim(fe.name)) = lower(trim(r.fishing_entity)))
    left join master.fishing_entity ofe on (lower(trim(ofe.name)) = lower(trim(r.original_country_fishing)))
    left join master.eez e on (lower(trim(e.name)) = lower(trim(r.eez)))
    left join master.fao_area fa on (lower(trim(fa.name)) = lower(trim(r.fao_area)))
    left join master.sector_type st on (lower(trim(st.name)) = lower(trim(r.sector)))
    left join master.input_type it on (lower(trim(it.name)) = lower(trim(r.input_type)))
    left join master.catch_type ct on (lower(trim(ct.name)) = lower(trim(r.catch_type)))
    left join master.reporting_status rs on (lower(trim(rs.name)) = lower(trim(r.reporting_status)))
    left join recon.nafo nf on (lower(trim(nf.nafo_division)) = lower(trim(r.nafo_division)))
    left join master.taxon otn on (lower(trim(otn.scientific_name)) = lower(trim(r.original_taxon_name)))
    left join master.taxon ofn on (lower(trim(ofn.scientific_name)) = lower(trim(r.original_fao_name)))
    left join master.taxon tx on (lower(trim(tx.scientific_name)) = lower(trim(r.taxon_name)) and not tx.is_retired)
    left join master.taxon cx on (lower(trim(cx.common_name)) = lower(trim(r.taxon_name)) and not cx.is_retired)
    left join distribution.taxon_distribution_substitute tds on (tds.original_taxon_key = tx.taxon_key)
    left join recon.ices_area ia on (lower(trim(ia.ices_area)) = lower(replace(trim(r.ices_area), '.0', '')))
   where r.id = any(i_raw_catch_ids)
     and rc.id = r.id;
     
   update recon.raw_catch rc
      set layer = case 
                  when e.eez_id is null then 0
                  when e.is_home_eez_of_fishing_entity_id = r.fishing_entity_id then 1
                  else 2
                  end
     from recon.raw_catch r
     left join master.eez e on (e.eez_id = r.eez_id and not e.is_retired)
    where r.id = any(i_raw_catch_ids)
      and rc.id = r.id
      and rc.eez_id is not null
      and rc.fishing_entity_id is distinct from 0
      and rc.layer is not distinct from 0;
$body$
language sql;

CREATE OR REPLACE FUNCTION recon.maintain_validation_result_partition() 
RETURNS TABLE(created INT, dropped INT) AS
$body$
DECLARE 
  partitions_created INT := 0;
  partitions_dropped INT := 0;
  pid INT;
  partition_name VARCHAR(100);
  action VARCHAR(10);
BEGIN
  FOR pid, action IN 
    SELECT COALESCE(vr.rule_id, p.rule_id),
           CASE 
           WHEN vr.rule_id IS NULL THEN
             'drop'
           WHEN p.rule_id IS NULL THEN
             'create'
           ELSE
             'nop'
            END
      FROM recon.validation_rule AS vr
      FULL JOIN (SELECT SPLIT_PART(table_name, '_', 3)::INT AS rule_id FROM schema_v('validation_partition') WHERE table_name NOT LIKE 'TOTALS%') AS p ON (p.rule_id = vr.rule_id)
  LOOP
    partition_name := format('validation_result_%s', pid);
    
    IF action = 'create' THEN
      EXECUTE format('CREATE TABLE validation_partition.%s(CHECK(rule_id = %s)) INHERITS (recon.validation_result)', partition_name, pid);
      EXECUTE format('ALTER TABLE validation_partition.%s SET (autovacuum_enabled = false)', partition_name);
      EXECUTE format('CREATE INDEX %s_%s_idx ON validation_partition.%1$s(%2$s)', partition_name, 'id');
      partitions_created := partitions_created + 1;
    ELSIF action = 'drop' THEN
      EXECUTE format('DROP TABLE validation_partition.%s', partition_name); 
      partitions_dropped := partitions_dropped + 1;
    END IF;
  END LOOP;
  
  IF partitions_created > 0 THEN 
    PERFORM admin.grant_access();
  END IF;
  
  RETURN QUERY SELECT partitions_created, partitions_dropped;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION recon.refresh_validation_result_partition(i_rule_id int) 
RETURNS TIMESTAMP AS
$body$
DECLARE 
  partition_name VARCHAR(100);
  rule_name TEXT;
  executed_ts TIMESTAMP := NULL;
BEGIN
  FOR rule_name, partition_name IN 
    SELECT name, 'validation_result_' || vr.rule_id
      FROM recon.validation_rule AS vr
     WHERE vr.rule_id = i_rule_id
  LOOP
    EXECUTE format('TRUNCATE TABLE validation_partition.%s', partition_name);
    EXECUTE format('INSERT INTO validation_partition.%s SELECT %s, id FROM recon.%s', partition_name, i_rule_id, rule_name);
    EXECUTE format('ANALYZE validation_partition.%s', partition_name);
    executed_ts := CURRENT_TIMESTAMP;
    EXECUTE format('UPDATE validation_rule SET last_executed = ''%s''::TIMESTAMP WHERE rule_id = %s', executed_ts, i_rule_id);
  END LOOP;
  
  RETURN executed_ts;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION recon.refresh_validation_result_partition(i_rule_name text) 
RETURNS TIMESTAMP AS
$body$
  SELECT recon.refresh_validation_result_partition(vr.rule_id) 
    FROM recon.validation_rule vr 
   WHERE vr.name = i_rule_name; 
$body$
LANGUAGE sql;

/*
The command below should be maintained as the last command in this entire script.
*/
SELECT admin.grant_access();
