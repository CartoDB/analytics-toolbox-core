USE @@SF_DATABASEID@@;
CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASEID@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.VERSION() to share @@SF_SHARE_PUBLIC@@;
