drop table geo.world;

select * into geo.world from master.cell;

SELECT admin.grant_access();
