----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function @@SF_PREFIX@@s2.ID_FROMHILBERTQUADKEY(STRING) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@s2.HILBERTQUADKEY_FROMID(BIGINT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@s2.LONGLAT_ASID(DOUBLE, DOUBLE, INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@s2.ST_ASID(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@s2.ST_BOUNDARY(BIGINT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@s2.VERSION() to share @@SF_SHARE@@;