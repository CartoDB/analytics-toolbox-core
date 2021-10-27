----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function COMPACT(ARRAY) to share @@SF_SHARE@@;
grant usage on function UNCOMPACT(ARRAY, INT) to share @@SF_SHARE@@;
grant usage on function DISTANCE(STRING, STRING) to share @@SF_SHARE@@;
grant usage on function HEXRING(STRING, INT) to share @@SF_SHARE@@;
grant usage on function ISPENTAGON(STRING) to share @@SF_SHARE@@;
grant usage on function ISVALID(STRING) to share @@SF_SHARE@@;
grant usage on function KRING(STRING, INT) to share @@SF_SHARE@@;
grant usage on function LONGLAT_ASH3(DOUBLE, DOUBLE, INT) to share @@SF_SHARE@@;
grant usage on function ST_ASH3(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function ST_ASH3_POLYFILL(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function ST_BOUNDARY(STRING) to share @@SF_SHARE@@;
grant usage on function TOCHILDREN(STRING, INT) to share @@SF_SHARE@@;
grant usage on function TOPARENT(STRING, INT) to share @@SF_SHARE@@;
grant usage on function VERSION() to share @@SF_SHARE@@;