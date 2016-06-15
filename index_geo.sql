CREATE INDEX eez_wkb_geometry_geom_idx ON geo.eez USING gist(wkb_geometry);
CREATE INDEX eez_eez_id_idx ON geo.eez(eez_id);

CREATE UNIQUE INDEX rfmo_rfmo_id_idx ON geo.rfmo(rfmo_id);
CREATE INDEX rfmo_geom_idx ON geo.rfmo USING gist(geom);

CREATE INDEX ifa_eez_id_idx ON geo.ifa(eez_id);
CREATE INDEX ifa_geom_idx ON geo.ifa USING gist(geom);

CREATE INDEX fao_geom_geom_idx ON geo.fao USING gist(geom);
CREATE INDEX fao_fao_area_id_idx ON geo.fao(fao_area_id);

CREATE INDEX mariculture_entity_eez_id_idx ON geo.mariculture_entity(eez_id);

CREATE INDEX mariculture_c_number_idx ON geo.mariculture(c_number);
CREATE INDEX mariculture_taxon_key_idx ON geo.mariculture(taxon_key);
CREATE INDEX mariculture_geom_idx ON geo.mariculture USING gist(geom);

CREATE INDEX mariculture_points_c_number_idx on geo.mariculture_points(c_number);
CREATE INDEX mariculture_points_entity_id_idx on geo.mariculture_points(entity_id);
CREATE INDEX mariculture_points_sub_entity_id_idx on geo.mariculture_points(sub_entity_id);

CREATE INDEX simple_area_cell_assignment_raw_cell_id_idx ON geo.simple_area_cell_assignment_raw(cell_id);
CREATE INDEX simple_area_cell_assignment_raw_marine_layer_id_idx ON geo.simple_area_cell_assignment_raw(marine_layer_id);

CREATE UNIQUE INDEX v_fao_fao_area_id_idx ON geo.v_fao(fao_area_id);
CREATE INDEX v_fao_geom_idx ON geo.v_fao USING gist(geom);

CREATE INDEX worldsq_geom_idx ON geo.worldsq USING gist(geom);

CREATE UNIQUE INDEX area_area_key_idx ON geo.area(area_key);

CREATE INDEX high_seas_geom_geom_idx ON geo.high_seas USING gist(geom);
CREATE INDEX high_seas_fao_area_id_idx ON geo.high_seas(fao_area_id);