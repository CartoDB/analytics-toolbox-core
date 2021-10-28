----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function PLACEKEY_FROMH3(STRING) to share @@SF_SHARE@@;
grant usage on function PLACEKEY_TOH3(STRING) to share @@SF_SHARE@@;
grant usage on function PLACEKEY_ISVALID(STRING) to share @@SF_SHARE@@;