insert into recon.validation_rule(rule_id, rule_type, name, description)
values
(14, 'E', 'v_raw_catch_ices_null', 'ICES area null for FAO 27'),
(15, 'E', 'v_raw_catch_outside_ices_not_null', 'ICES area not null for catch outside of FAO 27'),
(16, 'E', 'v_raw_catch_nafo_null', 'NAFO area null for FAO 21'),
(17, 'E', 'v_raw_catch_outside_nafo_not_null', 'NAFO area not null for catch outside of FAO 21'),
(211, 'E', 'v_catch_ices_null', 'ICES area null for FAO 27'),
(212, 'E', 'v_catch_outside_ices_not_null', 'ICES area not null for catch outside of FAO 27'),
(213, 'E', 'v_catch_nafo_null', 'NAFO area null for FAO 21'),
(214, 'E', 'v_catch_outside_nafo_not_null', 'NAFO area not null for catch outside of FAO 21');

-- Converting from Warning to Error
delete from recon.validation_rule where rule_id in (102, 103, 302, 303);

VACUUM FULL ANALYZE recon.validation_rule;

select * from recon.maintain_validation_result_partition();

-- ICES area null for FAO 27
CREATE OR REPLACE VIEW recon.v_raw_catch_ices_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id = 27 and ices_area is null;

select recon.refresh_validation_result_partition('v_raw_catch_ices_null');

-- ICES area not null for catch outside of FAO 27
CREATE OR REPLACE VIEW recon.v_raw_catch_outside_ices_not_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id <> 27 and ices_area is not null;

select recon.refresh_validation_result_partition('v_raw_catch_outside_ices_not_null');

-- NAFO area null for FAO 21
CREATE OR REPLACE VIEW recon.v_raw_catch_nafo_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id = 21 and nafo_division is null;

select recon.refresh_validation_result_partition('v_raw_catch_nafo_null');

-- NAFO area not null for catch outside of FAO 21
CREATE OR REPLACE VIEW recon.v_raw_catch_outside_nafo_not_null AS
SELECT id FROM recon.raw_catch WHERE fao_area_id <> 21 and nafo_division is not null;

select recon.refresh_validation_result_partition('v_raw_catch_outside_nafo_not_null');

-- ICES area null for FAO 27
CREATE OR REPLACE VIEW recon.v_catch_ices_null AS
SELECT id FROM recon.catch WHERE fao_area_id = 27 and ices_area_id is null;

select recon.refresh_validation_result_partition('v_catch_ices_null');

-- ICES area not null for catch outside of FAO 27
CREATE OR REPLACE VIEW recon.v_catch_outside_ices_not_null AS
SELECT id FROM recon.catch WHERE fao_area_id <> 27 and ices_area_id is not null;

select recon.refresh_validation_result_partition('v_catch_outside_ices_not_null');

-- NAFO area null for FAO 21
CREATE OR REPLACE VIEW recon.v_catch_nafo_null AS
SELECT id FROM recon.catch WHERE fao_area_id = 21 and nafo_division_id is null;

select recon.refresh_validation_result_partition('v_catch_nafo_null');

-- NAFO area not null for catch outside of FAO 21
CREATE OR REPLACE VIEW recon.v_catch_outside_nafo_not_null AS
SELECT id FROM recon.catch WHERE fao_area_id <> 21 and nafo_division_id is not null;   

select recon.refresh_validation_result_partition('v_catch_outside_nafo_not_null');

VACUUM FULL ANALYZE recon.raw_catch;

select admin.grant_access();
