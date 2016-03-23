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
    )
    select *
    from error1
    UNION all
    select *
    from  error2
    UNION all
    select *
    from error3;




