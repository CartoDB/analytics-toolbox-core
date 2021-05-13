USE @@SF_DATABASEID@@;
CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASEID@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASEID@@.@@SF_SCHEMA@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_PREFIX@@placekey.H3_ASPLACEKEY(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@placekey.PLACEKEY_ASH3(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@placekey.ISVALID(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@placekey.VERSION() to share @@SF_SHARE_PUBLIC@@;
