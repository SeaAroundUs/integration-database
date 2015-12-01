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
