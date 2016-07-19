create or replace function recon.normalize_raw_catch_by_ids(i_raw_catch_ids int[]) returns void as
$body$
  update recon.raw_catch rc
     set fishing_entity_id = coalesce(fe.fishing_entity_id, 0),
         original_country_fishing_id = ofe.fishing_entity_id, 
         eez_id = coalesce(e.eez_id, 0),
         fao_area_id = coalesce(fa.fao_area_id, 0),
         sector_type_id = coalesce(st.sector_type_id, 0),
         input_type_id = coalesce(it.input_type_id, 0),
         catch_type_id = coalesce(ct.catch_type_id, 0),
         reporting_status_id = coalesce(rs.reporting_status_id, 0),
         nafo_division_id = case 
                            when coalesce(r.nafo_division, '') = '' then null::int 
                            else coalesce(nf.nafo_division_id, 0)
                             end,
         taxon_key = case 
                     when tds.original_taxon_key is not null then tds.use_this_taxon_key_instead 
                     else coalesce(tx.taxon_key, coalesce(cx.taxon_key), 0)
                     end,
         original_taxon_name_id = otn.taxon_key,
         original_fao_name_id = ofn.taxon_key,
         ices_area_id = case
                        when coalesce(r.ices_area, '') = '' then null::int
                        else coalesce(ia.ices_area_id, 0)
                        end,
         last_modified = now()
    from recon.raw_catch r
    left join master.fishing_entity fe on (lower(trim(fe.name)) = lower(trim(r.fishing_entity)))
    left join master.fishing_entity ofe on (lower(trim(ofe.name)) = lower(trim(r.original_country_fishing)))
    left join master.eez e on (lower(trim(e.name)) = lower(trim(r.eez)))
    left join master.fao_area fa on (lower(trim(fa.name)) = lower(trim(r.fao_area)))
    left join master.sector_type st on (lower(trim(st.name)) = lower(trim(r.sector)))
    left join master.input_type it on (lower(trim(it.name)) = lower(trim(r.input_type)))
    left join master.catch_type ct on (lower(trim(ct.name)) = lower(trim(r.catch_type)))
    left join master.reporting_status rs on (lower(trim(rs.name)) = lower(trim(r.reporting_status)))
    left join recon.nafo nf on (lower(trim(nf.nafo_division)) = lower(trim(r.nafo_division)))
    left join master.taxon otn on (lower(trim(otn.scientific_name)) = lower(trim(r.original_taxon_name)))
    left join master.taxon ofn on (lower(trim(ofn.scientific_name)) = lower(trim(r.original_fao_name)))
    left join master.taxon tx on (lower(trim(tx.scientific_name)) = lower(trim(r.taxon_name)) and not tx.is_retired)
    left join master.taxon cx on (lower(trim(cx.common_name)) = lower(trim(r.taxon_name)) and not cx.is_retired)
    left join distribution.taxon_distribution_substitute tds on (tds.original_taxon_key = tx.taxon_key)
    left join recon.ices_area ia on (lower(trim(ia.ices_area)) = lower(replace(trim(r.ices_area), '.0', '')))
   where r.id = any(i_raw_catch_ids)
     and rc.id = r.id;
     
   update recon.raw_catch rc
      set layer = case 
                  when e.eez_id is null then 0
                  when e.is_home_eez_of_fishing_entity_id = r.fishing_entity_id then 1
                  else 2
                  end
     from recon.raw_catch r
     left join master.eez e on (e.eez_id = r.eez_id and not e.is_retired)
    where r.id = any(i_raw_catch_ids)
      and rc.id = r.id
      and rc.eez_id is not null
      and rc.fishing_entity_id is distinct from 0
      and rc.layer is not distinct from 0;
$body$
language sql;

SELECT admin.grant_access();
