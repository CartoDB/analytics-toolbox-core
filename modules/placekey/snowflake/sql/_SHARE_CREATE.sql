----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function H3_ASPLACEKEY(STRING) to share @@SF_SHARE@@;
grant usage on function PLACEKEY_ASH3(STRING) to share @@SF_SHARE@@;
grant usage on function ISVALID(STRING) to share @@SF_SHARE@@;
grant usage on function VERSION() to share @@SF_SHARE@@;