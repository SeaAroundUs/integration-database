CREATE TABLE log.table_edits(
  id serial primary key,
  auth_user_id int not null,
  table_name varchar(256),
  notes text,
  created timestamp not null default now()
);
