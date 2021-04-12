USE @@SF_DATABASEID@@;
CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASEID@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.ID_FROMHILBERTQUADKEY(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.HILBERTQUADKEY_FROMID(BIGINT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.LONGLAT_ASID(DOUBLE, DOUBLE, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.ST_ASID(GEOGRAPHY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.ST_BOUNDARY(BIGINT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.VERSION() to share @@SF_SHARE_PUBLIC@@;