-- backup master.cell, distribution.taxon_distribution and distribution.taxon_distribution_log
-- select * into log.cell_table_2017_07_13 from master.cell;
-- select * into log.taxon_distribution_2017_07_13 from distribution.taxon_distribution;
-- select * into log.taxon_distribution_log_2017_07_13 from distribution.taxon_distribution_log;

-- master.cell dependent views
drop view if exists v_test_cell_assigned_water_area_exceeds_entire_cell_area;

-- distribution.taxon_distribution dependent views
drop view if exists distribution.v_test_taxon_distribution_substitute;
drop view if exists master.v_taxon_lineage;
drop materialized view if exists distribution.v_taxon_with_distribution;
drop view if exists recon.v_distribution_taxa_has_no_distribution;
drop view if exists recon.v_distribution_taxa_has_no_distribution_low_raw_catch;
drop view if exists recon.v_distribution_taxa_has_no_distribution_high_raw_catch;
drop view if exists recon.v_distribution_taxa_has_substitute_high_raw_catch;
drop view if exists recon.v_distribution_taxon_extent_available_but_no_distribution;

drop table distribution.taxon_distribution; -- dependent on master.cell
drop table master.cell; -- drop table to 'position' the front column beside coral

CREATE TABLE master.cell (                   
  cell_id integer PRIMARY KEY,
  lon double precision,
  lat double precision,
  cell_row int,  -- "row" is a reserved word in pgplsql
  cell_col int,  -- renamed for consistency
  total_area double precision,
  water_area double precision,
  percent_water double precision,
  ele_min int,
  ele_max int,
  ele_avg int,
  elevation_min int,
  elevation_max int,
  elevation_mean int,
  bathy_min int,
  bathy_max int,
  bathy_mean int,
  fao_area_id int,
  lme_id int,
  bgcp double precision,
  distance double precision,
  coastal_prop double precision,
  shelf double precision,
  slope double precision,
  abyssal double precision,
  estuary double precision,
  mangrove double precision,
  seamount_saup double precision,
  seamount double precision,
  coral double precision,
  front double precision,
  pprod double precision,
  ice_con double precision,
  sst double precision,
  eez_count int,
  sst_2001 double precision,
  bt_2001 double precision,
  pp_10yr_avg double precision,
  sst_avg double precision,
  pp_annual double precision
);

\copy master.cell from 'WorldTable_fronts_2017-07-13.txt' with (format csv, header, delimiter E'\t')

VACUUM FULL ANALYZE master.cell;

-- Re-create taxon distribution table; run a full distribution afterwards to re-populate table
CREATE TABLE distribution.taxon_distribution (
    taxon_distribution_id serial primary key,
    taxon_key integer not null,
    cell_id integer not null,
    relative_abundance double precision not null,
    is_backfilled boolean not null default false
);

-- can repopulate taxon distribution table with backup
-- insert into distribution.taxon_distribution select * from log.taxon_distribution_2017_07_13;

-- Re-create constraints
ALTER TABLE distribution.taxon_distribution ADD CONSTRAINT taxon_key_fk
FOREIGN KEY (taxon_key) REFERENCES master.taxon(taxon_key) ON DELETE CASCADE;

ALTER TABLE distribution.taxon_distribution ADD CONSTRAINT cell_id_fk
FOREIGN KEY (cell_id) REFERENCES master.cell(cell_id) ON DELETE CASCADE;

-- Re-create trigger
CREATE TRIGGER taxon_distribution_before_insert_trigger BEFORE INSERT
		ON distribution.taxon_distribution
FOR EACH ROW EXECUTE PROCEDURE distribution.taxon_distribution_insert_trigger_handler();

-- Re-create views
CREATE OR REPLACE VIEW geo.v_test_cell_assigned_water_area_exceeds_entire_cell_area AS 
SELECT rw.marine_layer_id,                      
       rw.area_id,
       rw.fao_area_id,
       rw.cell_id,
       rw.water_area AS this_cell_assignment_water_area,
       c.water_area AS entire_water_area_of_this_cell
  FROM (geo.simple_area_cell_assignment_raw rw
  JOIN master.cell c ON ((rw.cell_id = c.cell_id)))
 WHERE ((rw.water_area > (c.water_area * (1.02)::double precision))
       -- 1.02 is used instead of 1.0 to allow some tolerance
   AND (rw.marine_layer_id <> 0)); 
   
CREATE OR REPLACE VIEW distribution.v_test_taxon_distribution_substitute as
    with taxa_with_distribution as (
    select distinct taxon_key
      from distribution.taxon_distribution
    ),
    is_marked_as_automatic_substitute as (
        select distinct original_taxon_key, use_this_taxon_key_instead
        from distribution.taxon_distribution_substitute
        where is_manual_override = false
    ),
    error1 as (
        select original_taxon_key, use_this_taxon_key_instead, 'Potential unwanted behaviour: this ''original_taxon_key'' already has a distribution, consider removing it from table ''taxon_distribution_substitute'' '::text as Err_Mesg
        FROM is_marked_as_automatic_substitute
        where original_taxon_key in (select taxon_key from taxa_with_distribution)
    ),
    error2 as (
        select original_taxon_key, use_this_taxon_key_instead, 'Error: The suggested ''use_this_taxon_key_instead'' DOES NOT have a distribution'::text as Err_Mesg
        from distribution.taxon_distribution_substitute
        where use_this_taxon_key_instead not in (select taxon_key from taxa_with_distribution)
    ),
    error3 as (
        select original_taxon_key, use_this_taxon_key_instead, 'Please review: for this manual override the ''original_taxon_key'' has a distribution'::text as err_mesg
        from distribution.taxon_distribution_substitute
        where is_manual_override = true and original_taxon_key in ((select taxon_key from taxa_with_distribution))
    ), error4 AS (
        SELECT ts.original_taxon_key,
               ts.use_this_taxon_key_instead,
               'Warning: the original_taxon_key and the substitute have different FunctionalGroupIDs (' || otk.functional_group_id || ',' || utk.functional_group_id  ||'), may interfere with Access Agreements'::text AS err_mesg
        from distribution.taxon_distribution_substitute ts
        join master.taxon otk on (otk.taxon_key = ts.original_taxon_key)
        join master.taxon utk on (utk.taxon_key = ts.use_this_taxon_key_instead)
        where otk.functional_group_id is distinct from utk.functional_group_id
    )
    select *
    from error1
    UNION all
    select *
    from  error2
    UNION all
    select *
    from error3
    UNION ALL
    SELECT *
    FROM error4;
	
create materialized view distribution.v_taxon_with_distribution as 
select distinct taxon_key from distribution.taxon_distribution with no data;
	
CREATE OR REPLACE VIEW master.v_taxon_lineage AS
SELECT t.taxon_key, t.common_name::varchar(30), t.scientific_name::varchar(30), t.genus::varchar(30), t.species::varchar(30),
       t.taxon_level_id as level, t.phylum::varchar(30), t.cla_code, t.ord_code, t.fam_code, t.gen_code, t.spe_code, t.lineage,
       (SELECT p.lineage 
          FROM master.taxon p 
         WHERE NOT p.is_retired AND p.taxon_key IS DISTINCT FROM t.taxon_key AND p.lineage @> t.lineage 
         ORDER BY nlevel(p.lineage) DESC, p.taxon_level_id DESC LIMIT 1) AS parent, 
       (td.taxon_key is not null) as is_distribution_available, 
       (te.taxon_key is not null) as is_extent_available,
       cbt.total_catch, cbt.total_value
  FROM master.taxon t
  LEFT join distribution.v_taxon_with_distribution td ON (td.taxon_key = t.taxon_key)
  LEFT join distribution.v_taxon_with_extent te ON (te.taxon_key = t.taxon_key)
  LEFT join allocation.catch_by_taxon cbt ON (cbt.taxon_key = t.taxon_key)
 WHERE NOT t.is_retired
 ORDER BY t.lineage;
 
CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_no_distribution AS 
 SELECT DISTINCT rc.taxon_key AS id
   FROM recon.raw_catch rc,
    distribution.taxon_distribution t
  WHERE rc.taxon_key <> t.taxon_key;

CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_no_distribution_low_raw_catch AS 
 WITH distributions(taxon_key) AS (
         SELECT DISTINCT taxon_distribution.taxon_key
           FROM distribution.taxon_distribution
        ), substitutions(taxon_key) AS (
         SELECT DISTINCT taxon_distribution_substitute.original_taxon_key
           FROM distribution.taxon_distribution_substitute
        )
SELECT rc.taxon_key AS id,
sum(rc.amount) AS sum
FROM recon.raw_catch rc
 LEFT JOIN distributions d ON rc.taxon_key = d.taxon_key
 LEFT JOIN substitutions s ON rc.taxon_key = s.taxon_key
WHERE d.taxon_key IS NULL AND s.taxon_key IS NULL
GROUP BY rc.taxon_key
HAVING sum(rc.amount) <= 1000::double precision;

CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_no_distribution_high_raw_catch AS 
WITH distributions(taxon_key) AS (
	 SELECT DISTINCT taxon_distribution.taxon_key
	   FROM distribution.taxon_distribution
	), substitutions(taxon_key) AS (
	 SELECT DISTINCT taxon_distribution_substitute.original_taxon_key
	   FROM distribution.taxon_distribution_substitute
	)
SELECT rc.taxon_key AS id,
sum(rc.amount) AS sum
FROM recon.raw_catch rc
 LEFT JOIN distributions d ON rc.taxon_key = d.taxon_key
 LEFT JOIN substitutions s ON rc.taxon_key = s.taxon_key
WHERE d.taxon_key IS NULL AND s.taxon_key IS NULL
GROUP BY rc.taxon_key
HAVING sum(rc.amount) > 1000::double precision;

CREATE OR REPLACE VIEW recon.v_distribution_taxa_has_substitute_high_raw_catch AS 
WITH distributions(taxon_key) AS (
	 SELECT DISTINCT taxon_distribution.taxon_key
	   FROM distribution.taxon_distribution
	), substitutions(taxon_key) AS (
	 SELECT DISTINCT taxon_distribution_substitute.original_taxon_key
	   FROM distribution.taxon_distribution_substitute
	)
SELECT rc.taxon_key AS id,
sum(rc.amount) AS sum
FROM recon.raw_catch rc
 LEFT JOIN distributions d ON rc.taxon_key = d.taxon_key
 LEFT JOIN substitutions s ON rc.taxon_key = s.taxon_key
WHERE d.taxon_key IS NULL AND s.taxon_key IS NOT NULL
GROUP BY rc.taxon_key
HAVING sum(rc.amount) > 1000::double precision;

CREATE OR REPLACE VIEW recon.v_distribution_taxon_extent_available_but_no_distribution AS 
SELECT e.taxon_key AS id
FROM distribution.taxon_extent e
 JOIN master.taxon t ON t.taxon_key = e.taxon_key AND NOT t.is_retired
 JOIN distribution.taxon_habitat h ON h.taxon_key = e.taxon_key
WHERE NOT (EXISTS ( SELECT 1
	   FROM distribution.taxon_distribution d
	  WHERE d.taxon_key = e.taxon_key AND NOT d.is_backfilled
	 LIMIT 1));
 
CREATE INDEX taxon_key_idx ON distribution.taxon_distribution(taxon_key);
CREATE UNIQUE INDEX cell_id_taxon_key_uk ON distribution.taxon_distribution(cell_id, taxon_key);
 
CREATE INDEX cell_fao_area_id_idx ON master.cell(fao_area_id);
CREATE INDEX cell_lme_id_idx ON master.cell(lme_id);
CREATE INDEX p_water_idx ON master.cell(percent_water) WHERE percent_water > 0;

-- grant access
select admin.grant_access();
