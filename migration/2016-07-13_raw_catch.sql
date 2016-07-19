ALTER TABLE recon.raw_catch 
alter fishing_entity set not null, 
alter eez set not null, 
alter sector set not null, 
alter catch_type set not null, 
alter reporting_status set not null, 
alter taxon_name set not null, 
alter input_type set not null, 
alter input_type_id set not null,
alter input_type_id set DEFAULT 0;

SELECT admin.grant_access();