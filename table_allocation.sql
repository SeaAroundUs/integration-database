CREATE TABLE allocation.ifa(
  eez_id int,
  ifa_is_located_in_this_fao int
);

CREATE TABLE allocation.ices_area(  
  ices_division varchar(255),
  ices_subdivision varchar(255),
  ices_area_id varchar(255) not null  
);
