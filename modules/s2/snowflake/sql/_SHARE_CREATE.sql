----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function ID_FROMHILBERTQUADKEY(STRING) to share @@SF_SHARE@@;
grant usage on function HILBERTQUADKEY_FROMID(BIGINT) to share @@SF_SHARE@@;
grant usage on function LONGLAT_ASID(DOUBLE, DOUBLE, INT) to share @@SF_SHARE@@;
grant usage on function ST_ASID(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function ST_BOUNDARY(BIGINT) to share @@SF_SHARE@@;
grant usage on function VERSION() to share @@SF_SHARE@@;