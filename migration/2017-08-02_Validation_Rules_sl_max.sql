insert into recon.validation_rule(rule_id, rule_type, name, description)
values
(420, 'E', 'v_distribution_taxon_sl_max_null', 'Distribution.taxon_habitat record with sl_max is null');

VACUUM FULL ANALYZE recon.validation_rule;

select * from recon.maintain_validation_result_partition();

create or replace view recon.v_distribution_taxon_sl_max_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.sl_max is null;
   
select recon.refresh_validation_result_partition('v_distribution_taxon_sl_max_null');

VACUUM FULL ANALYZE recon.raw_catch;

select admin.grant_access();
