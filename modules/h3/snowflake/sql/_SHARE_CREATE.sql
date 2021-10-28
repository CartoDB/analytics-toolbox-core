----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function H3_COMPACT(ARRAY) to share @@SF_SHARE@@;
grant usage on function H3_UNCOMPACT(ARRAY, INT) to share @@SF_SHARE@@;
grant usage on function H3_DISTANCE(STRING, STRING) to share @@SF_SHARE@@;
grant usage on function H3_HEXRING(STRING, INT) to share @@SF_SHARE@@;
grant usage on function H3_ISPENTAGON(STRING) to share @@SF_SHARE@@;
grant usage on function H3_ISVALID(STRING) to share @@SF_SHARE@@;
grant usage on function H3_KRING(STRING, INT) to share @@SF_SHARE@@;
grant usage on function H3_KRING_DISTANCES(STRING, INT) to share @@SF_SHARE@@;
grant usage on function H3_FROMLONGLAT(DOUBLE, DOUBLE, INT) to share @@SF_SHARE@@;
grant usage on function H3_FROMGEOGPOINT(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function H3_POLYFILL(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function H3_BOUNDARY(STRING) to share @@SF_SHARE@@;
grant usage on function H3_TOCHILDREN(STRING, INT) to share @@SF_SHARE@@;
grant usage on function H3_TOPARENT(STRING, INT) to share @@SF_SHARE@@;