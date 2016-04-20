ALTER USER sau_int SET search_path TO admin, master, recon, distribution, geo, log, tiger, topology, tiger_data, public;
ALTER USER web_int SET search_path TO master, recon, distribution, geo, log, admin, tiger, topology, tiger_data, public;
ALTER USER recon_int SET search_path TO recon, log, master, admin, distribution, geo, tiger, topology, tiger_data, public;
ALTER USER distribution_int SET search_path TO distribution, master, admin, recon, geo, log, tiger, topology, tiger_data, public;
ALTER USER qc_int SET search_path TO master, recon, distribution, geo, log, admin, public;
ALTER USER gis_int SET search_path TO distribution, geo, log, admin, public;
