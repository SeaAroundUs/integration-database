ALTER USER sau_int SET search_path TO admin, master, recon, distribution, log, tiger, topology, tiger_data, public;
ALTER USER web_int SET search_path TO master, recon, distribution, log, admin, tiger, topology, tiger_data, public;
ALTER USER recon_int SET search_path TO recon, log, master, admin, distribution, tiger, topology, tiger_data, public;
ALTER USER distribution_int SET search_path TO distribution, master, admin, recon, log, tiger, topology, tiger_data, public;
ALTER USER qc_int SET search_path TO master, recon, distribution, log, admin, public;
ALTER USER gis_int SET search_path TO distribution, log, admin, public;
