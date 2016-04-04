-- recon.catch
ALTER TABLE recon.catch ADD CONSTRAINT catch_fishing_entity_id_idx 
FOREIGN KEY (fishing_entity_id) REFERENCES master.fishing_entity(fishing_entity_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_original_country_fishing_id_fk 
FOREIGN KEY (original_country_fishing_id) REFERENCES master.fishing_entity(fishing_entity_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT taxon_key_fk
FOREIGN KEY (taxon_key) REFERENCES master.taxon(taxon_key) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT eez_id_fk
FOREIGN KEY (eez_id) REFERENCES master.eez(eez_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT fao_area_id_fk
FOREIGN KEY (fao_area_id) REFERENCES master.fao_area(fao_area_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_type_id_fk
FOREIGN KEY (catch_type_id) REFERENCES master.catch_type(catch_type_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT year_fk
FOREIGN KEY (year) REFERENCES master.time(year) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_ices_area_id_fk
FOREIGN KEY (ices_area_id) REFERENCES recon.ices_area(ices_area_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_nafo_division_id_fk 
FOREIGN KEY (nafo_division_id) REFERENCES recon.nafo(nafo_division_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_raw_catch_id_fk 
FOREIGN KEY (raw_catch_id) REFERENCES recon.raw_catch(id) ON DELETE CASCADE;

--ALTER TABLE recon.catch ADD CONSTRAINT catch_reference_id_fk 
--FOREIGN KEY (reference_id) REFERENCES recon.reference(reference_id) ON DELETE CASCADE;

ALTER TABLE recon.catch ADD CONSTRAINT catch_sector_type_id_fk 
FOREIGN KEY (sector_type_id) REFERENCES master.sector_type(sector_type_id) ON DELETE CASCADE;

-- recon.template
ALTER TABLE recon.template ADD CONSTRAINT fao_area_id_fk
FOREIGN KEY (fao_area_id) REFERENCES master.fao_area(fao_area_id) ON DELETE CASCADE;

-- recon.auth_group
ALTER TABLE recon.auth_group_permissions ADD CONSTRAINT auth_group_permissio_group_id_fk 
FOREIGN KEY (group_id) REFERENCES recon.auth_group(id) ON DELETE CASCADE;

-- recon.auth_permission
ALTER TABLE recon.auth_permission ADD CONSTRAINT auth_content_type_id_fk
FOREIGN KEY (content_type_id) REFERENCES recon.django_content_type(id) ON DELETE CASCADE;

-- recon.auth_group_permissions
ALTER TABLE recon.auth_group_permissions ADD CONSTRAINT auth_group_permission_id_fk 
FOREIGN KEY (permission_id) REFERENCES recon.auth_permission(id) ON DELETE CASCADE;

-- recon.auth_user_user_permissions
ALTER TABLE recon.auth_user_user_permissions ADD CONSTRAINT auth_user__permission_id_fk 
FOREIGN KEY (permission_id) REFERENCES recon.auth_permission(id) ON DELETE CASCADE;

ALTER TABLE recon.auth_user_user_permissions ADD CONSTRAINT auth_user_user_permiss_user_id_fk 
FOREIGN KEY (user_id) REFERENCES recon.auth_user(id) ON DELETE CASCADE;

-- recon.auth_user_groups
ALTER TABLE recon.auth_user_groups ADD CONSTRAINT auth_user_groups_group_id_fk 
FOREIGN KEY (group_id) REFERENCES recon.auth_group(id) ON DELETE CASCADE;

ALTER TABLE recon.auth_user_groups ADD CONSTRAINT auth_user_groups_user_id_fk 
FOREIGN KEY (user_id) REFERENCES recon.auth_user(id) ON DELETE CASCADE;

-- recon.file_upload
ALTER TABLE recon.file_upload ADD CONSTRAINT file_upload_user_id_fk 
FOREIGN KEY (user_id) REFERENCES recon.auth_user(id) ON DELETE CASCADE;

-- recon.django_admin_log
ALTER TABLE recon.django_admin_log ADD CONSTRAINT djang_content_type_id_fk 
FOREIGN KEY (content_type_id) REFERENCES recon.django_content_type(id) ON DELETE CASCADE;

ALTER TABLE recon.django_admin_log ADD CONSTRAINT django_admin_log_user_id_fk 
FOREIGN KEY (user_id) REFERENCES recon.auth_user(id) ON DELETE CASCADE;

-- recon.raw_catch
ALTER TABLE recon.raw_catch ADD CONSTRAINT raw_catch_source_file_id_fk 
FOREIGN KEY (source_file_id) REFERENCES recon.file_upload(id) ON DELETE CASCADE;

ALTER TABLE recon.raw_catch ADD CONSTRAINT raw_catch_user_id_fk 
FOREIGN KEY (user_id) REFERENCES recon.auth_user(id) ON DELETE CASCADE;

-- recon.eez_ices
--ALTER TABLE recon.eez_ices ADD CONSTRAINT eez_ices_eez_id_fk 
--FOREIGN KEY (eez_id) REFERENCES master.eez(eez_id) ON DELETE CASCADE;

ALTER TABLE recon.eez_ices ADD CONSTRAINT eez_ices_ices_division_id_fk 
FOREIGN KEY (ices_division_id) REFERENCES recon.ices_division(ices_division_id) ON DELETE CASCADE;

ALTER TABLE recon.eez_ices ADD CONSTRAINT eez_ices_ices_subdivision_id_fk 
FOREIGN KEY (ices_subdivision_id) REFERENCES recon.ices_subdivision(ices_subdivision_id) ON DELETE CASCADE;

-- recon.eez_nafo
ALTER TABLE recon.eez_nafo ADD CONSTRAINT eez_nafo_nafo_division_id_fk 
FOREIGN KEY (nafo_division_id) REFERENCES recon.nafo(nafo_division_id) ON DELETE CASCADE;
