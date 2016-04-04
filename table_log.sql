CREATE TABLE log.table_edits(
  id serial primary key,
  auth_user_id int not null,
  table_name varchar(256),
  notes text,
  created timestamp not null default now()
);

CREATE TABLE log.adhoc_query(
  id serial primary key,
  query text not null,
  notes text,
  is_active boolean not null default true,
  created_by_auth_user_id int not null,
  reviewed_by_auth_user_id int,
  grantee_auth_user_id int[],
  last_executed_by_auth_user_id int,
  last_executed timestamp,
  created timestamp not null default now(),
  last_modified timestamp
);

-- Not to be confused with the taxon substitution table, which is used only by allocation for distribution purposes
-- This table here is to keep track of taxon keys that has been superseeded by a new key
CREATE TABLE log.taxon_replacement(
  old_taxon_key int not null,	
  new_taxonkey int,	
  taxon_name text,
  type text,
  phylum_subphylum text,	
  class_subclass text,
  superorder_order_suborder	text,
  genus text,
  species text,
  comments_names text,
  replaced_timestamp timestamp
);

