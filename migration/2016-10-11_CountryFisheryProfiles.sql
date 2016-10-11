CREATE TABLE master.country_fishery_profile(
  profile_id serial PRIMARY KEY,
  c_number int NULL,
  count_code varchar(4) NOT NULL,
  country_name varchar(50) NULL,
  fish_mgt_plan text NULL,
  url_fish_mgt_plan text NULL,
  gov_marine_fish text NULL,
  major_law_plan text NULL,
  url_major_law_plan text NULL,
  gov_protect_marine_env text NULL,
  url_gov_protect_marine_env text NULL
);

CREATE INDEX country_fishery_profile_count_code_idx ON master.country_fishery_profile(count_code);

\copy master.country_fishery_profile from 'country_fishery_profile_updated_2016-10-11.txt' with (format csv, header, delimiter E'\t')

select admin.grant_access();
