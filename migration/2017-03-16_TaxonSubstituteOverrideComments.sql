ALTER TABLE distribution.taxon_distribution_substitute
ADD COLUMN comments text;

VACUUM FULL ANALYZE distribution.taxon_distribution_substitute;

SELECT admin.grant_access();
