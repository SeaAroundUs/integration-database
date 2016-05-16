CREATE OR REPLACE VIEW master.v_taxon AS
SELECT * FROM master.taxon WHERE NOT is_retired;

CREATE OR REPLACE VIEW master.v_retired_taxon AS
SELECT * FROM master.taxon WHERE is_retired;

CREATE OR REPLACE VIEW master.v_taxon_lineage AS
SELECT t.taxon_key, t.common_name::varchar(30), t.scientific_name::varchar(30), t.genus::varchar(30), t.species::varchar(30),
       t.taxon_level_id as level, t.phylum::varchar(30), t.cla_code, t.ord_code, t.fam_code, t.gen_code, t.spe_code, t.lineage,
       subpath(t.lineage, 0, nlevel(t.lineage)-1) as parent, 
       (td.taxon_key is not null) as is_distribution_available, 
       (te.taxon_key is not null) as is_extent_available,
       cbt.total_catch, cbt.total_value
  FROM master.taxon t
  LEFT join distribution.v_taxon_with_distribution td ON (td.taxon_key = t.taxon_key)
  LEFT join distribution.v_taxon_with_extent te ON (te.taxon_key = t.taxon_key)
  LEFT join allocation.catch_by_taxon cbt ON (cbt.taxon_key = t.taxon_key)
 WHERE NOT t.is_retired
 ORDER BY t.lineage;

/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
