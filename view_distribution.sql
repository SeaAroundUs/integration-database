CREATE OR REPLACE VIEW distribution.v_test_taxon_distribution_substitute as
    with taxa_with_distribution as (
    select distinct taxon_key
      from taxon_distribution
    ),
    is_marked_as_automatic_substitute as (
        select distinct original_taxon_key, use_this_taxon_key_instead
        from taxon_distribution_substitute
        where is_manual_override = false
    ),
    error1 as (
        select original_taxon_key, use_this_taxon_key_instead, 'Potential unwanted behaviour: this ''original_taxon_key'' already has a distribution, consider removing it from table ''taxon_distribution_substitute'' '::text as Err_Mesg
        FROM is_marked_as_automatic_substitute
        where original_taxon_key in (select taxon_key from taxa_with_distribution)
    ),
    error2 as (
        select original_taxon_key, use_this_taxon_key_instead, 'Error: The suggested ''use_this_taxon_key_instead'' DOES NOT have a distribution'::text as Err_Mesg
        from taxon_distribution_substitute
        where use_this_taxon_key_instead not in (select taxon_key from taxa_with_distribution)
    ),
    error3 as (
        select original_taxon_key, use_this_taxon_key_instead, 'Please review: for this manual override the ''original_taxon_key'' has a distribution'::text as err_mesg
        from taxon_distribution_substitute
        where is_manual_override = true and original_taxon_key in ((select taxon_key from taxa_with_distribution))
    ), error4 AS (
        SELECT ts.original_taxon_key,
               ts.use_this_taxon_key_instead,
               'Warning: the original_taxon_key and the substitute have different FunctionalGroupIDs (' || otk.functional_group_id || ',' || utk.functional_group_id  ||'), may interfere with Access Agreements'::text AS err_mesg
        from taxon_distribution_substitute ts
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

-- Materialized views
create materialized view distribution.v_taxon_with_distribution as 
select distinct taxon_key from distribution.taxon_distribution with no data;

create materialized view distribution.v_taxon_with_extent as 
select distinct taxon_key from distribution.taxon_extent with no data;

/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
