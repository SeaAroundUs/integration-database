/* Reconstruction data tables */
CREATE TABLE recon.ices_eez (
    id serial primary key,
    name character varying(200) NOT NULL
);


CREATE TABLE recon.nafo (
    id serial primary key,
    name character varying(200) NOT NULL
);


CREATE TABLE recon.reference (
    id serial primary key,
    name character varying(200) NOT NULL
);

CREATE TABLE recon.template(
  fishing_entity text,
  original_country_fishing text,
  eez text,
  eez_sub_area text,
  fao_area_id int,
  sub_regional_area text,
  province text,
  ices_divison text,
  ices_subdivision text,
  nafo_division text,
  ccamlr_area text,
  layer int,
  sector text,
  original_sector text,
  catch_type text,
  year int,
  taxon_name text,
  original_taxon_name text,
  original_fao_name text,
  amount numeric,
  adjustment_factor numeric,
  gear_type gear,
  input_type text,
  forward_carry_rule text,
  disaggregation_rule text,
  layer_rule text,
  reference_id int,
  notes text
);

CREATE TABLE recon.catch (
    id integer NOT NULL,
    fishing_entity_id integer NOT NULL,
    eez_sub_area character varying(200),
    sub_regional_area character varying(200),
    province_state character varying(200),
    ccamlr_area character varying(200),
    layer integer NOT NULL,
    original_sector character varying(200),
    year integer NOT NULL,
    amount numeric(20,12) NOT NULL,
    adjustment_factor numeric(20,12),
    gear_type integer,
    input_type integer,
    forward_carry_rule integer,
    disaggregation_rule integer,
    layer_rule integer,
    notes text,
    catch_type_id integer NOT NULL,
    eez_id integer NOT NULL,
    fao_area_id integer NOT NULL,
    ices_division_id integer NOT NULL,
    ices_subdivision_id integer NOT NULL,
    nafo_division_id integer NOT NULL,
    original_country_fishing_id integer NOT NULL,
    original_fao_name_id integer NOT NULL,
    original_taxon_name_id integer NOT NULL,
    raw_catch_id integer NOT NULL,
    reference_id integer NOT NULL,
    sector_type_id integer NOT NULL,
    taxon_key integer NOT NULL
);


CREATE TABLE recon.raw_catch (
    id serial primary key,
    fishing_entity character varying(200),
    fishing_entity_id integer NOT NULL,
    original_country_fishing character varying(200),
    original_country_fishing_id integer,
    eez character varying(200),
    eez_id integer NOT NULL,
    eez_sub_area character varying(200),
    fao_area character varying(20),
    fao_area_id integer,
    subregional_area character varying(200),
    province_state character varying(200),
    ices_division character varying(200),
    ices_division_id integer,
    ices_subdivision character varying(200),
    ices_subdivision_id integer,
    nafo_division character varying(200),
    nafo_division_id integer,
    ccamlr_area character varying(200),
    layer integer NOT NULL,
    sector character varying(200),
    sector_type_id integer NOT NULL,
    original_sector character varying(200),
    catch_type character varying(200),
    catch_type_id integer NOT NULL,
    year integer NOT NULL,
    taxon_name character varying(200),
    taxon_key integer NOT NULL,
    original_taxon_name character varying(200),
    original_taxon_name_id integer,
    original_fao_name character varying(200),
    original_fao_name_id integer,
    amount numeric(20,12) NOT NULL,
    adjustment_factor numeric(20,12),
    gear_type character varying(200),
    gear_type_id integer,
    input_type character varying(200),
    input_type_id integer,
    forward_carry_rule character varying(200),
    forward_carry_rule_id integer,
    disaggregation_rule character varying(200),
    disaggregation_rule_id integer,
    layer_rule character varying(200),
    layer_rule_id integer,
    reference_id integer,
    notes text,
    source_file_id integer NOT NULL,
    user_id integer NOT NULL
);


CREATE TABLE recon.file_upload (
    id serial primary key,
    file character varying(100) NOT NULL,
    create_datetime timestamp with time zone NOT NULL,
    user_id integer
);


/* Django come alongs */
CREATE TABLE recon.auth_group (
    id serial primary key,
    name character varying(80) NOT NULL,
    CONSTRAINT auth_group_name_ak UNIQUE (name)
);


CREATE TABLE recon.auth_group_permissions (
    id serial primary key,
    group_id integer NOT NULL,
    permission_id integer NOT NULL,
    CONSTRAINT auth_group_permissions_group_id_permission_id_ak UNIQUE (group_id, permission_id)
);


CREATE TABLE recon.auth_permission (
    id serial primary key,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL,
    CONSTRAINT auth_permission_content_type_id_codename_ak UNIQUE (content_type_id, codename)
);


CREATE TABLE recon.auth_user (
    id serial primary key,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    CONSTRAINT auth_user_username_ak UNIQUE (username)
);

CREATE TABLE recon.auth_user_groups (
    id serial primary key,
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    CONSTRAINT auth_user_groups_user_id_group_id_key UNIQUE (user_id, group_id)
);


CREATE TABLE recon.auth_user_user_permissions (
    id serial primary key,
    user_id integer NOT NULL,
    permission_id integer NOT NULL,
    CONSTRAINT auth_user_user_permissions_user_id_permission_id_key UNIQUE (user_id, permission_id)
);


CREATE TABLE recon.django_admin_log (
    id serial primary key,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


CREATE TABLE recon.django_content_type (
    id serial primary key,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL,
    CONSTRAINT django_content_type_app_label_model_ak UNIQUE (app_label, model)
);


CREATE TABLE recon.django_migrations (
    id serial primary key,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


CREATE TABLE recon.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);
