ALTER TABLE web.country_fishery_profile
alter url_fish_mgt_plan type character varying(1024),
alter url_major_law_plan type character varying(1024),
alter url_gov_protect_marine_env type character varying(1024);

create or replace view web.v_country_profile
as
  with cntry as (
    select c.*, 
           

fp.fish_mgt_plan,fp.url_fish_mgt_plan,fp.gov_marine_fish,fp.major_law_plan,fp.url_major_law_plan,fp.gov_protect_marine_env,fp.url_gov_pr

otect_marine_env,
           array(select row_to_json(n.*) from web.country_ngo n where n.count_code = c.count_code) as ngo
      from web.country c
      left join web.country_fishery_profile fp on (fp.count_code = c.count_code)
  )
  select c.count_code, c.c_number, c.country, row_to_json(c.*) AS asjson
    from cntry c;

VACUUM FULL ANALYZE distribution.taxon_habitat;

select admin.grant_access();