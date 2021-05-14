----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_PREFIX@@h3.COMPACT(ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.UNCOMPACT(ARRAY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.DISTANCE(STRING, STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.HEXRING(STRING, DOUBLE) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.ISPENTAGON(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.ISVALID(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.KRING(STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.LONGLAT_ASH3(DOUBLE, DOUBLE, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.ST_ASH3(GEOGRAPHY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.ST_ASH3_POLYFILL(GEOGRAPHY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.ST_BOUNDARY(STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.TOCHILDREN(STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.TOPARENT(STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@h3.VERSION() to share @@SF_SHARE_PUBLIC@@;