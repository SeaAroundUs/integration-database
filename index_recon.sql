CREATE INDEX auth_group_name_idx ON recon.auth_group(name varchar_pattern_ops);

CREATE INDEX auth_group_permissions_group_id_idx ON recon.auth_group_permissions(group_id);

CREATE INDEX auth_group_permissions_permission_id_idx ON recon.auth_group_permissions(permission_id);

CREATE INDEX auth_permission_content_type_id_idx ON recon.auth_permission(content_type_id);

CREATE INDEX auth_user_groups_group_id_idx ON recon.auth_user_groups(group_id);

CREATE INDEX auth_user_groups_user_id_idx ON recon.auth_user_groups(user_id);

CREATE INDEX auth_user_user_permissions_permission_id_idx ON recon.auth_user_user_permissions(permission_id);

CREATE INDEX auth_user_user_permissions_user_id_idx ON recon.auth_user_user_permissions(user_id);

CREATE INDEX auth_user_username_username_idx ON recon.auth_user(username varchar_pattern_ops);

CREATE INDEX django_admin_log_content_type_id_idx ON recon.django_admin_log(content_type_id);

CREATE INDEX django_admin_log_user_id_idx ON recon.django_admin_log(user_id);

CREATE INDEX django_session_expire_date_idx ON recon.django_session(expire_date);

CREATE INDEX django_session_session_key_session_key_idx ON recon.django_session(session_key varchar_pattern_ops);

CREATE INDEX file_upload_user_id_idx ON recon.file_upload(user_id);

/* catch */
CREATE INDEX catch_eez_id_idx ON recon.catch(eez_id);

CREATE INDEX catch_nafo_division_id_idx ON recon.catch(nafo_division_id);

CREATE INDEX catch_reference_id_idx ON recon.catch(reference_id);

CREATE INDEX catch_fishing_entity_id_idx ON recon.catch(fishing_entity_id);

CREATE INDEX catch_original_country_fishing_id_idx ON recon.catch(original_country_fishing_id);

CREATE INDEX catch_original_fao_name_id_idx ON recon.catch(original_fao_name_id);

CREATE INDEX catch_sector_type_id_idx ON recon.catch(sector_type_id);

CREATE INDEX catch_fao_area_id_idx ON recon.catch(fao_area_id);

CREATE INDEX catch_catch_type_id_idx ON recon.catch(catch_type_id);

CREATE INDEX catch_taxon_key_idx ON recon.catch(taxon_key);

CREATE INDEX catch_original_taxon_name_id_idx ON recon.catch(original_taxon_name_id);

CREATE INDEX catch_ices_area_id_idx ON recon.catch(ices_area_id);

CREATE INDEX catch_raw_catch_id_idx ON recon.catch(raw_catch_id);

/* raw_catch */
CREATE INDEX raw_catch_source_file_id_idx ON recon.raw_catch(source_file_id);

CREATE INDEX raw_catch_user_id_idx ON recon.raw_catch(user_id);

CREATE INDEX raw_catch_fishing_entity_id_idx ON recon.raw_catch(fishing_entity_id);

CREATE INDEX raw_catch_eez_id_idx ON recon.raw_catch(eez_id);

CREATE INDEX raw_catch_fao_area_id_idx ON recon.raw_catch(fao_area_id);

CREATE INDEX raw_catch_year_idx ON recon.raw_catch(year);

CREATE INDEX raw_catch_taxon_key_idx ON recon.raw_catch(taxon_key);

CREATE INDEX raw_catch_reference_id_idx ON recon.raw_catch(reference_id);

CREATE INDEX raw_catch_required_field_idx ON recon.raw_catch(id) WHERE (fishing_entity || eez || fao_area || layer || sector || catch_type || "year" || amount || input_type) IS NULL;

CREATE INDEX raw_catch_taxon_name_is_null_idx ON recon.raw_catch(taxon_key) WHERE taxon_name IS NULL;

CREATE INDEX raw_catch_lookup_mismatch_idx ON recon.raw_catch(id) 
WHERE 0 = ANY(ARRAY[taxon_key, 
                     coalesce(original_taxon_name_id, -1), 
                     coalesce(original_fao_name_id, -1), 
                     catch_type_id, 
                     fishing_entity_id, 
                     coalesce(original_country_fishing_id, -1), 
                     fao_area_id, 
                     sector_type_id, 
                     coalesce(input_type_id, -1), 
                     coalesce(reference_id, -1)]) 	
    OR eez_id IS NULL;
