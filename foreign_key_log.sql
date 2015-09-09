-- log.table_edits
ALTER TABLE log.table_edits ADD CONSTRAINT table_edits_auth_user_id_idx 
FOREIGN KEY (auth_user_id) REFERENCES recon.auth_user(id) ON DELETE CASCADE;
