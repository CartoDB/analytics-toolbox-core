USE @@SF_DATABASEID@@;
CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASEID@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@.H3_ASPLACEKEY(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@.PLACEKEY_ASH3(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@.ISVALID(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@.VERSION() to share @@SF_SHARE_PUBLIC@@;
