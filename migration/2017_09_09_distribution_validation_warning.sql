UPDATE recon.validation_rule SET rule_type = 'W' WHERE rule_id = 419;
UPDATE recon.validation_rule SET rule_id = 500 WHERE rule_id = 419;

VACUUM FULL ANALYZE recon.validation_rule;

select * from recon.maintain_validation_result_partition();

select recon.refresh_validation_result_partition('v_distribution_taxa_substitute_has_different_functional_groups');

select * from admin.grant_access();
