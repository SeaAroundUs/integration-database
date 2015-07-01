CREATE TABLE admin.knittool_query
(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sql TEXT NOT NULL,
  column_width TEXT[][],
  modified TIMESTAMP NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX knittool_query_uk ON admin.knittool_query(LOWER(name));

CREATE OR REPLACE FUNCTION admin.save_knittool_query(i_name TEXT, i_sql TEXT) RETURNS INTEGER AS
$body$
DECLARE
  query_id INTEGER;
  query_sql TEXT;
BEGIN
  SELECT id, sql
    INTO query_id, query_sql
    FROM admin.knittool_query
   WHERE LOWER(name) = LOWER(i_name);
    
  IF FOUND THEN
    IF i_sql <> query_sql THEN
      UPDATE admin.knittool_query 
         SET sql = i_sql, modified = current_timestamp
       WHERE id = query_id;
    END IF;
  ELSE
    INSERT INTO admin.knittool_query(name, sql)
         VALUES (i_name, i_sql)
      RETURNING id 
           INTO query_id;
  END IF;
  
  RETURN query_id;
END;
$body$
LANGUAGE plpgsql;
