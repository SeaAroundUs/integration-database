alter table master.taxon 
alter common_name set NOT NULL;

vacuum analyze master.taxon;

SELECT admin.grant_access();
