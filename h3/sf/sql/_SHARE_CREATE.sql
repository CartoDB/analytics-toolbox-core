USE @@SF_DATABASEID@@;
CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASEID@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.COMPACT(ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.UNCOMPACT(ARRAY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.DISTANCE(STRING, STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.HEXRING(STRING, DOUBLE) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ISPENTAGON(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ISVALID(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.KRING(STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.LONGLAT_ASH3(DOUBLE, DOUBLE, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_ASH3(GEOGRAPHY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_ASH3_POLYFILL(GEOGRAPHY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_BOUNDARY(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOCHILDREN(STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOPARENT(STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.VERSION() to share @@SF_SHARE_PUBLIC@@;
