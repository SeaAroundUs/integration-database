CREATE INDEX table_edits_auth_user_id_idx ON log.table_edits(auth_user_id);
CREATE INDEX table_edits_table_name_idx ON log.table_edits(table_name);
CREATE INDEX table_edits_created_idx ON log.table_edits(created);
