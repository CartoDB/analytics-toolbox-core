----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function S2_IDFROMHILBERTQUADKEY(STRING) to share @@SF_SHARE@@;
grant usage on function S2_HILBERTQUADKEYFROMCELLID(BIGINT) to share @@SF_SHARE@@;
grant usage on function S2_IDFROMLONGLAT(DOUBLE, DOUBLE, INT) to share @@SF_SHARE@@;
grant usage on function S2_IDFROMGEOGPOINT(GEOGRAPHY, INT) to share @@SF_SHARE@@;
grant usage on function S2_BOUNDARY(BIGINT) to share @@SF_SHARE@@;
grant usage on function VERSION() to share @@SF_SHARE@@;