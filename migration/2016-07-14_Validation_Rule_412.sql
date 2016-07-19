insert into recon.validation_rule(rule_id, rule_type, name, description)
values
(412, 'E', 'v_distribution_taxon_extent_available_but_no_distribution', 'Distribution.taxon_extent record available, but no distribution generated yet');

VACUUM FULL ANALYZE recon.validation_rule;

create or replace view recon.v_distribution_taxon_extent_available_but_no_distribution as
  select e.taxon_key as id 
    from distribution.taxon_extent e
    join master.taxon t on (t.taxon_key = e.taxon_key and not t.is_retired)
    join distribution.taxon_habitat h on (h.taxon_key = e.taxon_key)
   where not exists (select 1 
                       from distribution.taxon_distribution d 
                      where d.taxon_key = e.taxon_key and not d.is_backfilled 
                      limit 1);

select * from recon.maintain_validation_result_partition();

SELECT admin.grant_access();
