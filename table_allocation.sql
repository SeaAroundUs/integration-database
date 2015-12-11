CREATE TABLE allocation.ifa(
  eez_id int,
  ifa_is_located_in_this_fao int
);

CREATE TABLE allocation.ices_area(  
  ices_division varchar(255),
  ices_subdivision varchar(255),
  ices_area_id varchar(255) not null  
);

CREATE TABLE allocation.allocation_area_type (
  allocation_area_type_id smallint DEFAULT 0 PRIMARY KEY,
  name character varying(50) NOT NULL,
  remarks character varying(255) NOT NULL
);

CREATE TABLE allocation.layer (
  layer_id smallint DEFAULT 0 PRIMARY KEY,
  name character varying(255) NOT NULL
);
