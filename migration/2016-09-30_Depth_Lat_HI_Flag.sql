UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with lat_north is null' WHERE rule_id = 400;
UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with lat_south is null' WHERE rule_id = 401;
UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with min_depth is null' WHERE rule_id = 402;
UPDATE recon.validation_rule SET description = 'Distribution.taxon_habitat record with max_depth is null' WHERE rule_id = 403;

VACUUM FULL ANALYZE recon.validation_rule;

select * from recon.maintain_validation_result_partition();

create or replace view recon.v_distribution_taxon_lat_north_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.lat_north is null;
  
select recon.refresh_validation_result_partition('v_distribution_taxon_lat_north_null');

create or replace view recon.v_distribution_taxon_lat_south_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.lat_south is null;
  
select recon.refresh_validation_result_partition('v_distribution_taxon_lat_south_null');

create or replace view recon.v_distribution_taxon_min_depth_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.min_depth is null;
  
select recon.refresh_validation_result_partition('v_distribution_taxon_min_depth_null');

create or replace view recon.v_distribution_taxon_max_depth_null as
  select h.taxon_key as id 
    from distribution.taxon_habitat h
    join master.taxon t on (t.taxon_key = h.taxon_key and not t.is_retired)
   where h.max_depth is null;

select recon.refresh_validation_result_partition('v_distribution_taxon_max_depth_null');

select admin.grant_access();
