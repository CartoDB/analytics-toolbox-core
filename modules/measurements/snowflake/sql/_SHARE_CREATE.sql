----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function ST_MINKOWSKIDISTANCE(ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_MINKOWSKIDISTANCE(ARRAY, DOUBLE) to share @@SF_SHARE@@;